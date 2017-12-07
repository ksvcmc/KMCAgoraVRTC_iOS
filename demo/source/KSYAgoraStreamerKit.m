
#import <libksygpulive/KSYGPUPicOutput.h>
#import <libksygpulive/libksystreamerengine.h>

#import <KMCAgoraVRTC/KMCAgoraVRTC.h>
#import <GPUImage/GPUImage.h>
#import "KSYAgoraStreamerKit.h"
#import <mach/mach_time.h>

static inline void fillAsbd(AudioStreamBasicDescription*asbd,BOOL bFloat, UInt32 size) {
    bzero(asbd, sizeof(AudioStreamBasicDescription));
    asbd->mSampleRate       = 44100;
    asbd->mFormatID         = kAudioFormatLinearPCM;
    if (bFloat) {
        asbd->mFormatFlags      = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
    }
    else {
        asbd->mFormatFlags      = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    }
    asbd->mBitsPerChannel   = 8 * size;
    asbd->mBytesPerFrame    = size;
    asbd->mBytesPerPacket   = size;
    asbd->mFramesPerPacket  = 1;
    asbd->mChannelsPerFrame = 1;
}

@interface KSYAgoraStreamerKit() {
    AudioStreamBasicDescription _asbd;  // format description for audio data
//    BOOL  kmcAuthPassed;
}

@property KSYGPUPicOutput *     beautyOutput;
@property KSYGPUYUVInput  *     rtcYuvInput;
@property GPUImageUIElement *   uiElementInput;
@property GPUImageMaskFilter *  maskingFilter;
@property GPUImageFilter *  maskingShieldFilter;//用于mask隔离，防止残影发生
@property CMTime localAudioPts;
@property CMTime videoPts;

@end

@implementation KSYAgoraStreamerKit

/**
 @abstract 初始化方法
 @discussion 初始化，创建带有默认参数的 KSYStreamerBase
 
 @warning KSYStreamer只支持单实例推流，构造多个实例会出现异常
 */
- (instancetype) initWithDefaultCfg:(id<KMCRtcDelegate>)delegate
{
    self = [super initWithDefaultCfg];
    
    __weak typeof(self) weakSelf = self;

    _agoraKit = [[KMCAgoraVRTC alloc] initWithToken:@"7920903db27923b537ce1beedb976cd1" delegate:delegate];
    _agoraKit.maxRetryAuthCnt = 3;
    _beautyOutput = nil;
    _callstarted = NO;
    _maskPicture = nil;
    _maskingShieldFilter = [[GPUImageFilter alloc]init];
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height)];
    _contentView.backgroundColor = [UIColor clearColor];
    _curfilter = self.filter;
    _localAudioPts = kCMTimeInvalid;
    
    fillAsbd(&_asbd, YES, sizeof(Float32));

    self.videoProcessingCallback = ^(CMSampleBufferRef buf){
        weakSelf.videoPts= CMSampleBufferGetPresentationTimeStamp(buf);
    };

    __weak KSYAgoraStreamerKit * weak_kit = self;
    //加入channel成功回调,开始发送数据
    _agoraKit.joinChannelBlock = ^(NSString* channel, NSUInteger uid, NSInteger elapsed){
        if(channel)
        {
            if(!weak_kit.beautyOutput)
            {
                [weak_kit setupBeautyOutput];
                [weak_kit setupRtcFilter:weak_kit.curfilter];
            }
            
            //切换到声网音频采集
            [weak_kit.aCapDev stopCapture];
            [weak_kit.aMixer processAudioData:NULL nbSample:0 withFormat:NULL timeinfo:(CMTimeMake(0, 0)) of:0];
            [weak_kit.aMixer setTrack:1 enable:YES];
            [weak_kit.aMixer setMixVolume:1.0 of:1];
            weak_kit.localAudioPts = kCMTimeInvalid;
            
            if(weak_kit.onChannelJoin)
                weak_kit.onChannelJoin(200);
        }
    };
   
    //离开channel成功回调
    _agoraKit.leaveChannelBlock = ^(AgoraRtcStats* stat){
        NSLog(@"local leave channel");
        if(weak_kit.callstarted){
            [weak_kit stopRTCView];
            if(weak_kit.onCallStop)
                weak_kit.onCallStop(200);
             weak_kit.callstarted = NO;
        }
        
        //must restart capture to avoid push fail
        [weak_kit.aCapDev stopCapture];
        [weak_kit.aCapDev startCapture];
    };
    
    //接收数据回调，放入yuvinput里面
    _agoraKit.videoDataCallback=^(CVPixelBufferRef buf){
        [weak_kit defaultRtcVideoCallback:buf];
    };
    
    //音频回调，放入amixer里面
    _agoraKit.remoteAudioDataCallback=^(void* buffer,int sampleRate,int len,int bytesPerSample,int channels,int64_t pts)
    {
        [weak_kit defaultRtcVoiceCallback:buffer len:len pts:CMTimeMake(0, 0) channel:channels sampleRate:sampleRate sampleBytes:bytesPerSample trackId:1];
    };
    //本地音频回调
    _agoraKit.localAudioDataCallback=^(void* buffer,int sampleRate,int len,int bytesPerSample,int channels,int64_t pts)
    {
        if(CMTIME_IS_INVALID(weak_kit.localAudioPts)){
            weak_kit.localAudioPts = weak_kit.videoPts;
        }else{
            int nb_sample = len/bytesPerSample;
            int64_t timescale = weak_kit.localAudioPts.timescale;
            int64_t dur =(nb_sample*timescale)/sampleRate;
            int64_t newValue =weak_kit.localAudioPts.value + dur;
            weak_kit.localAudioPts = CMTimeMake(newValue, weak_kit.localAudioPts.timescale) ;
        }
        
        [weak_kit defaultRtcVoiceCallback:buffer len:len pts:weak_kit.localAudioPts channel:channels sampleRate:sampleRate sampleBytes:bytesPerSample trackId:0];
    };


    //注册进入后台的处理
    NSNotificationCenter* dc = [NSNotificationCenter defaultCenter];
    
    [dc addObserver:self
           selector:@selector(becomeActive)
               name:UIApplicationDidBecomeActiveNotification
             object:nil];
    
    [dc addObserver:self
           selector:@selector(resignActive)
               name:UIApplicationWillResignActiveNotification
             object:nil];
    
    
//    [dc addObserver:self
//           selector:@selector(interruptHandler:)
//               name:AVAudioSessionInterruptionNotification
//             object:nil];

    return self;
}

//- (void)interruptHandler:(NSNotification *)notification {
//    UInt32 interruptionState = [notification.userInfo[AVAudioSessionInterruptionTypeKey] unsignedIntValue];
//    if (interruptionState == kAudioSessionBeginInterruption){
//        if(_callstarted){
//            [self stopRTCView];
//            _callstarted = NO;
//        }
//    }
//    else if (interruptionState == kAudioSessionEndInterruption){
//        if(!_callstarted){
//            [self startRtcView];
//            _callstarted = YES;
//        }
//    }
//}

- (instancetype)init {
    return [self initWithDefaultCfg];
}
- (void)dealloc {
    NSLog(@"kit dealloc ");
    if(_agoraKit){
        [_agoraKit leaveChannel];
        _agoraKit = nil;
    }
    
    if(_beautyOutput){
        _beautyOutput = nil;
    }
    
    if(_rtcYuvInput){
        _rtcYuvInput = nil;
    }
    
    if(_contentView)
    {
        _contentView = nil;
    }
    
    if (_player){
        [self stopPlayer];
        _player = nil;
    }
    
    if(_playerYuvInput){
        _playerYuvInput = nil;
    }
    
    NSNotificationCenter* dc = [NSNotificationCenter defaultCenter];
    [dc removeObserver:self
                  name:AVAudioSessionInterruptionNotification
                object:nil];
    [dc removeObserver:self
                  name:UIApplicationDidBecomeActiveNotification
                object:nil];
//    [dc removeObserver:self
//                  name:UIApplicationWillResignActiveNotification
//                object:nil];
}

// 根据朝向, 判断是否需要交换宽和高
-(CGSize) getDimension: (CGSize) sz
           byOriention: (UIInterfaceOrientation) ori {
    CGSize outSz = sz;
    if ( ( ori == UIInterfaceOrientationPortraitUpsideDown ||
          ori == UIInterfaceOrientationPortrait )) {
        outSz.height = MAX(sz.width, sz.height);
        outSz.width  = MIN(sz.width, sz.height);
    }
    else  {
        outSz.height = MIN(sz.width, sz.height);
        outSz.width  = MAX(sz.width, sz.height);
    }
    return outSz;
}

- (void) updatePreDimension {
    CGSize _previewDimension = [self getDimension:self.previewDimension
                               byOriention:self.videoOrientation];
    CGSize  inSz     =  [self captureDimension];
    inSz = [self getDimension:inSz byOriention:self.vCapDev.outputImageOrientation];
    CGSize targetSize = CGSizeMake(_camRect.size.width*_previewDimension.width, _camRect.size.height*_previewDimension.height);
    CGSize cropSz = [self calcCropSize:inSz to:targetSize];
    self.capToGpu.cropRegion = [self calcCropRect:inSz to:cropSz];
    self.capToGpu.outputRotation = kGPUImageNoRotation;
    [self.capToGpu forceProcessingAtSize:_previewDimension];
}

- (void) setupRtcFilter:(GPUImageOutput<GPUImageInput> *) filter {
    _curfilter = filter;
    if (self.vCapDev  == nil) {
        return;
    }
    
    // 采集的图像先经过前处理
    [self.capToGpu     removeAllTargets];
    GPUImageOutput* src = self.capToGpu;
    
    if(filter)
    {
        [self.filter removeAllTargets];
        [src addTarget:self.filter];
        src = self.filter;
    }
    // 组装图层
    if(_rtcYuvInput)
    {
        [_rtcYuvInput removeAllTargets];
        if(!_selfInFront)//主播
        {
            [self setMixerMasterLayer:self.cameraLayer];
            [self addInput:src ToMixerAt:self.cameraLayer];
            if(_maskPicture){
                [self Maskwith:_rtcYuvInput];
                [self addInput:_maskingFilter ToMixerAt:_rtcLayer Rect:_winRect];
            }else{
                [self addInput:_rtcYuvInput ToMixerAt:_rtcLayer Rect:_winRect];
            }
        }
        else{//辅播
            [self setMixerMasterLayer:self.rtcLayer];
            [self addInput:_rtcYuvInput  ToMixerAt:self.cameraLayer];
            if(_maskPicture){
                [self Maskwith:src];
                [self addInput:_maskingFilter ToMixerAt:_rtcLayer Rect:_winRect];
            }else{
                [self addInput:src ToMixerAt:_rtcLayer Rect:_winRect];
            }
        }
    }else{
        [self clearMixerLayer:self.rtcLayer];
        [self clearMixerLayer:self.cameraLayer];
        [self setMixerMasterLayer:self.cameraLayer];
        [self addInput:src       ToMixerAt:self.cameraLayer];
    }
    
    //美颜后的图像，用于rtc发送
    if(_beautyOutput)
    {
        [src addTarget:_beautyOutput];
    }
    
    //组装自定义view
    if(_uiElementInput){
        [self addElementInput:_uiElementInput callbackOutput:src];
    }
    else{
        [self removeElementInput:_uiElementInput callbackOutput:src];
    }
    
    if (_playerYuvInput){
        [self addPic:self.playerYuvInput  ToMixerAt:self.playerLayer];
    }else{
        [self clearMixerLayer:self.playerLayer];
    }
    
    // 混合后的图像输出到预览和推流
    [self.vPreviewMixer removeAllTargets];
    [self.vPreviewMixer addTarget:self.preview];
    
    [self.vStreamMixer  removeAllTargets];
    [self.vStreamMixer  addTarget:self.gpuToStr];
    // 设置镜像
    [self setPreviewMirrored:self.previewMirrored];
    [self setStreamerMirrored:self.streamerMirrored];
}

-(void) addElementInput:(GPUImageUIElement *)input
         callbackOutput:(GPUImageOutput*)callbackOutput
{
    __weak GPUImageUIElement *weakUIEle = self.uiElementInput;
    [callbackOutput setFrameProcessingCompletionBlock:^(GPUImageOutput * f, CMTime fT){
        NSArray* subviews = [_contentView subviews];
        for(int i = 0;i<subviews.count;i++)
        {
            UIView* subview = (UIView*)[subviews objectAtIndex:i];
            if(subview)
                subview.hidden = NO;
        }
        if(subviews.count > 0)
        {
            [weakUIEle update];
        }
    }];
    [self addInput:_uiElementInput ToMixerAt:_customViewLayer Rect:_customViewRect];
}

- (void) addPic:(GPUImageOutput*)pic ToMixerAt: (NSInteger)idx{
    if (pic == nil){
        return;
    }
    [pic removeAllTargets];
    KSYGPUPicMixer * vMixer[2] = {self.vPreviewMixer, self.vStreamMixer};
    for (int i = 0; i<2; ++i) {
        [vMixer[i]  clearPicOfLayer:idx];
        [pic addTarget:vMixer[i] atTextureLocation:idx];
    }
}

-(void)Maskwith:(GPUImageOutput *)input
{
    [input removeAllTargets];
    [_maskPicture removeAllTargets];
    [_maskingFilter removeAllTargets];
    [_maskingShieldFilter removeAllTargets];
    
    [input addTarget:_maskingShieldFilter];
    [_maskingShieldFilter addTarget:_maskingFilter];
    [_maskPicture addTarget:_maskingFilter];
    [_maskPicture processImage];
}


-(void) setMixerMasterLayer:(NSInteger)idx
{
    KSYGPUPicMixer * vMixer[2] = {self.vPreviewMixer, self.vStreamMixer};
    for (int i = 0; i<2; ++i) {
        [vMixer[i]  setMasterLayer:idx];
    }
}


- (void) addPic:(GPUImageOutput*)pic
      ToMixerAt: (NSInteger)idx
           Rect:(CGRect)rect{
    if (pic == nil){
        return;
    }
    [pic removeAllTargets];
    KSYGPUPicMixer * vMixer[2] = {self.vPreviewMixer, self.vStreamMixer};
    for (int i = 0; i<2; ++i) {
        [vMixer[i]  clearPicOfLayer:idx];
        [pic addTarget:vMixer[i] atTextureLocation:idx];
        [vMixer[i] setPicRect:rect ofLayer:idx];
        [vMixer[i] setPicAlpha:1.0f ofLayer:idx];
    }
}


- (void) addInput:(GPUImageOutput*)pic
        ToMixerAt:(NSInteger)idx{
    if (pic == nil){
        return;
    }
    [pic removeAllTargets];
    KSYGPUPicMixer * vMixer[2] = {self.vPreviewMixer, self.vStreamMixer};
    for (int i = 0; i<2; ++i) {
        [vMixer[i]  clearPicOfLayer:idx];
        [pic addTarget:vMixer[i] atTextureLocation:idx];
    }
}


-(void) removeElementInput:(GPUImageUIElement *)input
            callbackOutput:(GPUImageOutput *)callbackOutput
{
    [self clearMixerLayer:_customViewLayer];
    [callbackOutput setFrameProcessingCompletionBlock:nil];
}

-(void) clearMixerLayer:(NSInteger)idx
{
    KSYGPUPicMixer * vMixer[2] = {self.vPreviewMixer, self.vStreamMixer};
    for (int i = 0; i<2; ++i) {
        [vMixer[i]  clearPicOfLayer:idx];
    }
}


- (void) addInput:(GPUImageOutput*)pic
        ToMixerAt:(NSInteger)idx
             Rect:(CGRect)rect{
    
    [self addInput:pic ToMixerAt:idx];
    KSYGPUPicMixer * vMixer[2] = {self.vPreviewMixer, self.vStreamMixer};
    for (int i = 0; i<2; ++i) {
        [vMixer[i] setPicRect:rect ofLayer:idx];
        [vMixer[i] setPicAlpha:1.0f ofLayer:idx];
    }
}
#pragma mark -播放
-(void)startPlayerWithUrl:( NSURL* _Nullable )playerUrl
{
    if (_player) {
        [self stopPlayer];
    }
    
    if(playerUrl) {
        [self.aMixer setTrack:_playerTrack enable:YES];
        [self.aMixer setMixVolume:1 of:_playerTrack];
        BOOL shouldUseHWCodec = YES;
        BOOL shouldAutoplay = YES;
        BOOL shouldMute = NO;
        _playerYuvInput = [[KSYGPUPicInput alloc] init];
        _player = [[KSYMoviePlayerController alloc]initWithContentURL:playerUrl];
        _player.videoDecoderMode = shouldUseHWCodec ? MPMovieVideoDecoderMode_Hardware : MPMovieVideoDecoderMode_Software;
        _player.shouldAutoplay = shouldAutoplay;
        _player.shouldMute = shouldMute;
        __weak KSYAgoraStreamerKit * weak_kit = self;
        _player.videoDataBlock = ^(CMSampleBufferRef buf){
            CVPixelBufferRef pb = CMSampleBufferGetImageBuffer(buf);
            CGSize preSize = [weak_kit adjustVideoProfile:weak_kit.agoraKit.videoProfile];
            CGSize rtcInputSize = CGSizeMake(CVPixelBufferGetWidth(pb),CVPixelBufferGetHeight(pb));
            CGSize cropSz = [weak_kit calcCropSize:rtcInputSize to:preSize];
            weak_kit.playerYuvInput.cropRegion = [weak_kit calcCropRect:rtcInputSize to:cropSz];
            [weak_kit.playerYuvInput forceProcessingAtSize:preSize];
            [weak_kit.playerYuvInput processPixelBuffer:CMSampleBufferGetImageBuffer(buf) time:CMTimeMake(2, 10)];
        };
        _player.audioDataBlock = ^(CMSampleBufferRef buf){
            if ([weak_kit.streamerBase isStreaming]){
                [weak_kit.aMixer processAudioSampleBuffer:buf of:weak_kit.playerTrack];
            }
        };
    }
    
    [self setupRtcFilter:_curfilter];
    [_player prepareToPlay];
}

-(void)stopPlayer{
    if (_player) {
        [_player stop];
        _player    = nil;
    }
    _playerYuvInput = nil;
    [self.aMixer setTrack:_playerTrack enable:NO];
    [self setupRtcFilter:_curfilter];
}

#pragma mark -rtc
-(void)joinChannel:(NSString *)channelName
{
    [_agoraKit joinChannel:channelName uid:0];
    
}
-(void)leaveChannel
{
    [self.aCapDev stopCapture];
    [_agoraKit leaveChannel];
}

-(void)setupBeautyOutput
{
    __weak KSYAgoraStreamerKit * weak_kit = self;
    _beautyOutput  =  [[KSYGPUPicOutput alloc] init];
    _beautyOutput.bCustomOutputSize = YES;
    _beautyOutput.outputSize = [self adjustVideoProfile:_agoraKit.videoProfile];//发送size需要和videoprofile匹配
    _beautyOutput.videoProcessingCallback = ^(CVPixelBufferRef pixelBuffer, CMTime timeInfo ){
            [weak_kit.agoraKit ProcessVideo:pixelBuffer timeInfo:timeInfo];
        };
}

-(void)startRtcVideoView{
    _rtcYuvInput =    [[KSYGPUYUVInput alloc] init];
    if(_contentView.subviews.count != 0)
        _uiElementInput = [[GPUImageUIElement alloc] initWithView:_contentView];
    if(!_beautyOutput)
    {
        [self setupBeautyOutput];
    }
    _maskingFilter = [[GPUImageMaskFilter alloc] init];
    [self setupRtcFilter:_curfilter];
}

-(void)startRtcView
{
    [self startRtcVideoView];
}

-(void)stopRTCVideoView{
    _rtcYuvInput = nil;
    _beautyOutput = nil;
    _uiElementInput = nil;
    _maskingFilter = nil;
    [self setupRtcFilter:_curfilter];
}

-(void)stopRTCView
{
    [self stopRTCVideoView];
    
    [self.aCapDev startCapture];
    [self.aMixer setTrack:1 enable:NO];
}

// 居中裁剪
-(CGRect) calcCropRect: (CGSize) camSz to: (CGSize) outSz {
    double x = (camSz.width  -outSz.width )/2/camSz.width;
    double y = (camSz.height -outSz.height)/2/camSz.height;
    double wdt = outSz.width/camSz.width;
    double hgt = outSz.height/camSz.height;
    return CGRectMake(x, y, wdt, hgt);
}
// 对 inSize 按照 targetSz的宽高比 进行裁剪, 得到最大的输出size
-(CGSize) calcCropSize: (CGSize) inSz to: (CGSize) targetSz {
    CGFloat preRatio = targetSz.width / targetSz.height;
    CGSize cropSz = inSz; // set width
    cropSz.height = cropSz.width / preRatio;
    if (cropSz.height > inSz.height){
        cropSz.height = inSz.height; // set height
        cropSz.width  = cropSz.height * preRatio;
    }
    return cropSz;
}

-(void) defaultRtcVideoCallback:(CVPixelBufferRef)buf
{
    CGSize preSize = [self adjustVideoProfile:_agoraKit.videoProfile];
    CGSize rtcInputSize = CGSizeMake(CVPixelBufferGetWidth(buf),CVPixelBufferGetHeight(buf));
    CGSize cropSz = [self calcCropSize:rtcInputSize to:preSize];
    _rtcYuvInput.cropRegion = [self calcCropRect:rtcInputSize to:cropSz];
    [_rtcYuvInput forceProcessingAtSize:preSize];
    [self.rtcYuvInput processPixelBuffer:buf time:CMTimeMake(2, 10)];
}

-(void) defaultRtcVoiceCallback:(uint8_t*)buf
                            len:(int)len
                            pts:(CMTime)pts
                        channel:(uint32_t)channels
                     sampleRate:(uint32_t)sampleRate
                    sampleBytes:(uint32_t)bytesPerSample
                        trackId:(int)trackId
{
    
    AudioStreamBasicDescription asbd;
    asbd.mSampleRate       = sampleRate;
    asbd.mFormatID         = kAudioFormatLinearPCM;
    asbd.mFormatFlags      = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    asbd.mBitsPerChannel   = 8 * bytesPerSample;
    asbd.mBytesPerFrame    = bytesPerSample;
    asbd.mBytesPerPacket   = bytesPerSample;
    asbd.mFramesPerPacket  = 1;
    asbd.mChannelsPerFrame = 1;

    if([self.streamerBase isStreaming])
    {
        [self.aMixer processAudioData:&buf nbSample:len/bytesPerSample withFormat:&asbd timeinfo:pts of:trackId];
    }
}

-(void) setWinRect:(CGRect)rect
{
    _winRect = rect;
    if(_callstarted)
    {
        KSYGPUPicMixer * vMixer[2] = {self.vPreviewMixer, self.vStreamMixer};
        for (int i = 0; i<2; ++i) {
            [vMixer[i]  removeAllTargets];
            [vMixer[i] setPicRect:rect ofLayer:self.rtcLayer];
        }
        [self.vPreviewMixer addTarget:self.preview];
        [self.vStreamMixer  addTarget:self.gpuToStr];
    }
}

-(void) setCamRect:(CGRect)rect
{
    _camRect = rect;
    KSYGPUPicMixer * vMixer[2] = {self.vPreviewMixer, self.vStreamMixer};
    for (int i = 0; i<2; ++i) {
        [vMixer[i]  removeAllTargets];
        [vMixer[i] setPicRect:rect ofLayer:self.cameraLayer];
    }
    [self.vPreviewMixer addTarget:self.preview];
    [self.vStreamMixer  addTarget:self.gpuToStr];
}

-(void) setPlayerRect:(CGRect)rect
{
    _playerRect = rect;
    KSYGPUPicMixer * vMixer[2] = {self.vPreviewMixer, self.vStreamMixer};
    for (int i = 0; i<2; ++i) {
        [vMixer[i]  removeAllTargets];
        [vMixer[i] setPicRect:rect ofLayer:self.playerLayer];
    }
    [self.vPreviewMixer addTarget:self.preview];
    [self.vStreamMixer  addTarget:self.gpuToStr];
}

-(void)setSelfInFront:(BOOL)selfInFront{
    _selfInFront = selfInFront;
    [self setupRtcFilter:_curfilter];
}

-(void)becomeActive
{
    __weak KSYAgoraStreamerKit * weak_kit = self;
    _agoraKit.videoDataCallback=^(CVPixelBufferRef buf){
        [weak_kit defaultRtcVideoCallback:buf];
    };
    _localAudioPts = kCMTimeInvalid;
}

-(void)resignActive
{
     _agoraKit.videoDataCallback = nil;
}

#pragma utility

-(CGSize) adjustVideoProfile:(AgoraRtcVideoProfile )videoProfile
{
    CGSize videoSize;
    switch(videoProfile){
        case AgoraRtc_VideoProfile_120P:
            videoSize=CGSizeMake(120, 160);
            break;
        case AgoraRtc_VideoProfile_120P_3:
            videoSize=CGSizeMake(120, 120);
            break;
        case AgoraRtc_VideoProfile_180P:		// 320x180   15   140
            videoSize=CGSizeMake(180, 320);
            break;
        case AgoraRtc_VideoProfile_180P_3:		// 180x180   15   100
            videoSize=CGSizeMake(180, 180);
            break;
        case AgoraRtc_VideoProfile_180P_4:		// 240x180   15   120
            videoSize=CGSizeMake(180, 240);
            break;
        case AgoraRtc_VideoProfile_240P:        // 320x240   15   200
            videoSize=CGSizeMake(240, 320);
            break;
        case AgoraRtc_VideoProfile_240P_3:		// 240x240   15   140
            videoSize=CGSizeMake(240, 240);
            break;
        case AgoraRtc_VideoProfile_240P_4:      // 424x240   15   220
            videoSize=CGSizeMake(240, 424);
            break;
        case AgoraRtc_VideoProfile_360P:
             AgoraRtc_VideoProfile_DEFAULT:// 640x360   15   400
            videoSize=CGSizeMake(360, 640);
            break;
        case AgoraRtc_VideoProfile_360P_3:	// 360x360   15   260
            videoSize=CGSizeMake(360, 360);
            break;
        case AgoraRtc_VideoProfile_360P_4:		// 640x360   30   600
            videoSize=CGSizeMake(360, 640);
            break;
        case AgoraRtc_VideoProfile_360P_6:		// 360x360   30   400
            videoSize=CGSizeMake(360, 360);
            break;
        case AgoraRtc_VideoProfile_360P_7:
        case AgoraRtc_VideoProfile_360P_8:      // 480x360   30   490
            videoSize=CGSizeMake(360, 480);
            break;
        case AgoraRtc_VideoProfile_360P_9:      // 640x360   15   800
        case AgoraRtc_VideoProfile_360P_10:     // 640x360   24   800
        case AgoraRtc_VideoProfile_360P_11:   // 640x360   24   1000
            videoSize=CGSizeMake(360, 640);
            break;
        case AgoraRtc_VideoProfile_480P:        	// 640x480   15   500
        case AgoraRtc_VideoProfile_480P_4:
            videoSize=CGSizeMake(480, 640);
            break;
        case AgoraRtc_VideoProfile_480P_3:		// 480x480   15   400
        case AgoraRtc_VideoProfile_480P_6:		// 480x480   30   600
            videoSize=CGSizeMake(480, 480);
            break;
        case AgoraRtc_VideoProfile_480P_8:		// 848x480   15   610
        case AgoraRtc_VideoProfile_480P_9:		// 848x480   30   930
            videoSize=CGSizeMake(480, 848);
            break;
        case AgoraRtc_VideoProfile_720P:		// 1280x720  15   1130
        case AgoraRtc_VideoProfile_720P_3:		// 1280x720  30   1710
            videoSize=CGSizeMake(720,1280);
            break;
        case AgoraRtc_VideoProfile_720P_5:		// 960x720   15   910
        case AgoraRtc_VideoProfile_720P_6:		// 960x720   30   1380
            videoSize=CGSizeMake(720,960);
            break;
        case AgoraRtc_VideoProfile_1080P:	// 1920x1080 15   2080
        case AgoraRtc_VideoProfile_1080P_3:		// 1920x1080 30   3150
        case AgoraRtc_VideoProfile_1080P_5:		// 1920x1080 60   4780
            videoSize=CGSizeMake(1080,1920);
            break;
        case AgoraRtc_VideoProfile_1440P:		// 2560x1440 30   4850
        case AgoraRtc_VideoProfile_1440P_2:		// 2560x1440 60   7350
            videoSize=CGSizeMake(1440,2560);
            break;
        case AgoraRtc_VideoProfile_4K:			// 3840x2160 30   8190
        case AgoraRtc_VideoProfile_4K_3:		// 3840x2160 60   13500
            videoSize=CGSizeMake(2160,3840);
            break;
        default:
            videoSize=CGSizeMake(360, 640);
            break;
    }
    
    return videoSize;
}

@end

