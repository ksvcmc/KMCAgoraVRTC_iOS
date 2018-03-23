//
//  KSYMutiAgoraStreamerKit.m
//  AgoraVRTCDemo
//
//  Created by yuyang on 2017/11/24.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import "KSYMultiAgoraStreamerKit.h"
#import <libksygpulive/libksystreamerengine.h>
#import <KMCAgoraVRTC/KMCAgoraVRTC.h>
//#import "KMCAgoraVRTC.h"
#import <GPUImage/GPUImage.h>
#import <mach/mach_time.h>
#import "KSYKitTool.h"
#import "KSYHeader.h"

#define kMaxNumber 4 // 最大人数限制

@implementation  KSYAgoraPicModel

@end

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

@interface KSYMultiAgoraStreamerKit ()
{
    AudioStreamBasicDescription _asbd;  // format description for audio data
    
    
}
@property (nonatomic,strong) NSMutableDictionary *map;// 默认1...kMaxNumber 为key  value  KSYAgoraPicModel
@property (nonatomic,strong) NSMutableDictionary *keyMap;//key 为 uid  value 默认1...kMaxNumber
@property (strong) NSMutableArray *keyArray;// 当前频道的人数（不包含自己）， 最大为kMaxNumber
@property (nonatomic,strong) KSYGPUPicOutput *picOutPut;
@property (nonatomic,strong) GPUImageUIElement *uiElementInput;
@property (nonatomic,strong) GPUImageUIElement *waterElementInput;
@property (nonatomic,assign) CGRect customCamRect; //自定义自己采集的尺寸
@property (nonatomic,assign) CGRect customOtherRemoteRect;// 1v1 对方可设置的尺寸
@property  dispatch_queue_t queue;
@property  dispatch_queue_t operateQueue;


@property CMTime localAudioPts;
@property CMTime videoPts;
@end


@implementation KSYMultiAgoraStreamerKit

#pragma mark 连麦接口初始化
- (instancetype) initWithDefaultCfg:(id<KMCRtcDelegate>)delegate token:(NSString *)token
{
    self = [super initWithDefaultCfg];
    [self setAudioDataType:KSYAudioData_RawPCM];
    @KSYWeakObj(self);
    [self defaultInit];
    _agoraKit = [[KMCAgoraVRTC alloc] initWithToken:token delegate:delegate];
    _agoraKit.maxRetryAuthCnt = 3;
    fillAsbd(&_asbd, YES, sizeof(Float32));
    self.videoProcessingCallback = ^(CMSampleBufferRef buf){
        @KSYStrongObj(self);
        self.videoPts= CMSampleBufferGetPresentationTimeStamp(buf);
        
    };
    __weak KSYMultiAgoraStreamerKit * weak_kit = self;
    //加入channel成功回调,开始发送数据
    _agoraKit.joinChannelBlock = ^(NSString* channel, NSUInteger uid, NSInteger elapsed){
        @KSYStrongObj(self);
        if(channel)
        {
            [self updateLayer];
            //切换到声网音频采集
            [self.aCapDev stopCapture];
            [self.aMixer processAudioData:NULL nbSample:0 withFormat:NULL timeinfo:(CMTimeMake(0, 0)) of:0];
            [self.aMixer setTrack:1 enable:YES];
            [self.aMixer setMixVolume:1.0 of:1];
            self.localAudioPts = kCMTimeInvalid;
            if(self.onChannelJoin)
                self.onChannelJoin();
        }
    };
    //离开channel成功回调
    _agoraKit.leaveChannelBlock = ^(AgoraRtcStats* stat){
        @KSYStrongObj(self);
        NSLog(@"local leave channel");
        if (self.leaveChannelBlock) {
            self.leaveChannelBlock();
        }
        //must restart capture to avoid push fail
        [self.aCapDev stopCapture];
        [self.aCapDev startCapture];
    };
    
    [self registerVideoProcessingCallback];
    
    //音频回调，放入amixer里面
    _agoraKit.remoteAudioDataCallback=^(void* buffer,int sampleRate,int len,int bytesPerSample,int channels,int64_t pts)
    {
        @KSYStrongObj(self);
        [self defaultRtcVoiceCallback:buffer len:len pts:CMTimeMake(0, 0) channel:channels sampleRate:sampleRate sampleBytes:bytesPerSample trackId:1];
    };
    //本地音频回调
    _agoraKit.localAudioDataCallback=^(void* buffer,int sampleRate,int len,int bytesPerSample,int channels,int64_t pts)
    {
        @KSYStrongObj(self);
        if(CMTIME_IS_INVALID(weak_kit.localAudioPts)){
            self.localAudioPts = weak_kit.videoPts;
        }else{
            int nb_sample = len/bytesPerSample;
            int64_t timescale = self.localAudioPts.timescale;
            int64_t dur =(nb_sample*timescale)/sampleRate;
            int64_t newValue =self.localAudioPts.value + dur;
            self.localAudioPts = CMTimeMake(newValue, weak_kit.localAudioPts.timescale) ;
        }
        
        [self defaultRtcVoiceCallback:buffer len:len pts:weak_kit.localAudioPts channel:channels sampleRate:sampleRate sampleBytes:bytesPerSample trackId:0];
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
    
    
    CGFloat ratio = self.previewDimension.width / self.previewDimension.height;
    if ( FLOAT_EQ( ratio, 16.0/9 ) || FLOAT_EQ( ratio,  9.0/16) ){
        self.agoraKit.videoProfile = AgoraRtc_VideoProfile_DEFAULT;
    }else{
        self.agoraKit.videoProfile = AgoraRtc_VideoProfile_480P;
    }
    
    return self;
}

//接收数据回调，放入yuvinput里面
- (void)registerVideoProcessingCallback {
    
    @KSYWeakObj(self);
    _agoraKit.videoDataCallback=^(CVPixelBufferRef buf, unsigned  int uid ){
        @KSYStrongObj(self);
        dispatch_sync(self.queue, ^{
            [self updatePixelBuffer:buf byItemId:uid];
        });
        
    };
    
}

-(void)becomeActive
{
    [self registerVideoProcessingCallback];
    _localAudioPts = kCMTimeInvalid;
}

-(void)resignActive
{
    _agoraKit.videoDataCallback = nil;
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


-(void)joinChannel:(NSString *)channelName
{
    [_agoraKit joinChannel:channelName uid:0];
}


-(void)leaveChannel
{
    [_agoraKit leaveChannel];
}

#pragma mark defalut init

// 刚开始启动设置默认四层
- (void)defaultInit
{
    self.keyArray = [[NSMutableArray alloc]init];
    self.keyMap =[[NSMutableDictionary alloc]init];
    self.map = [[NSMutableDictionary alloc]init];
    self.queue = dispatch_queue_create( "com.ksyun.mc.AgoraVRTCDemo.queue", DISPATCH_QUEUE_SERIAL);
    self.operateQueue = dispatch_queue_create( "com.ksyun.mc.AgoraVRTCDemo.operateQueue", DISPATCH_QUEUE_SERIAL);
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height)];
    _contentView.backgroundColor = [UIColor clearColor];
    _otherRemoteRect = CGRectMake(0, 0, 1, 1);
    _camRect = CGRectMake(0.6, 0.03, 0.36, 0.36);//默认值
    _customOtherRemoteRect = CGRectZero;
    _customCamRect = CGRectZero;
    _waterViewRect = CGRectZero;
    for (int i = 1; i < kMaxNumber+1; i++) { //初始化序列
        KSYGPUPicInput * gpuInput = [[KSYGPUPicInput alloc]init];
        KSYAgoraPicModel * picModel = [[KSYAgoraPicModel alloc]init];
        picModel.isClear = NO;
        picModel.layerIndex = i+4;
        picModel.input =gpuInput;
        NSString *key = [NSString stringWithFormat:@"%d",i];
        [self.map setObject:picModel forKey:key];
    }
    self.waterViewLayer = 9;//因为8之前被占用,所以水印设置为9
    _waterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height)];
    _waterView.backgroundColor = [UIColor clearColor];

}

- (void)startRtcView
{
    dispatch_sync(self.operateQueue, ^{
        if (self.keyArray.count>1&&self.keyArray.count<kMaxNumber) {
            [self setRtcViewDefault];
        }
        [self updateLayer];
    });
    
}

- (void)setRtcViewDefault
{
    _enablePK = NO;
    _enableSwitch = NO;
    _uiElementInput = nil;
    [self stopEnbaleSwitch];
    [self stopUsePK];
}

- (void)stopRTCView
{
    dispatch_sync(self.operateQueue, ^{
        for (KSYAgoraPicModel *picModel  in self.map.allValues) {
            if (picModel.layerIndex==8)
                picModel.isClear = NO;
            else
                picModel.isClear = YES;
        }
        [self updateLayer];
    });
}

#pragma mark 采集推流的给连麦sdk的数据
-(KSYGPUPicOutput *)picOutPut
{
    @KSYWeakObj(self);
    if (!_picOutPut) {
        _picOutPut  =  [[KSYGPUPicOutput alloc] init];
        _picOutPut.bCustomOutputSize = YES;
        _picOutPut.outputSize = [KSYKitTool adjustVideoProfile:self.agoraKit.videoProfile];//发送size需要和videoprofile匹配
        _picOutPut.videoProcessingCallback = ^(CVPixelBufferRef pixelBuffer, CMTime timeInfo ){
            @KSYStrongObj(self)
            //发送视频数据到云端
            [self.agoraKit ProcessVideo:pixelBuffer timeInfo:timeInfo];
        };
    }
    return _picOutPut;
}

#pragma mark preView&&streamerView
- (void)updateLayer
{
    
    [self.capToGpu     removeAllTargets];
    GPUImageOutput* src = self.capToGpu;
    [KSYKitTool setMixerMasterLayer:self.cameraLayer kit:self];
    [KSYKitTool addInput:src ToMixerAt:self.cameraLayer kit:self];
    for (KSYAgoraPicModel *picModel  in self.map.allValues) {
        
        if (!_enableSwitch) {
            if (picModel.layerIndex==8) { //交换图层 8 与 2 交换 设置第八层为主视图
                [KSYKitTool setMixerMasterLayer:picModel.layerIndex kit:self];
                [KSYKitTool addInput:picModel.input  ToMixerAt:self.cameraLayer kit:self];
                [KSYKitTool addInput:src ToMixerAt:picModel.layerIndex  Rect:CGRectZero kit:self];
            }
        }
        else
        {
            if (picModel.layerIndex==8) { //交换图层 8 与 2 交换  设置self.cameraLayer为主视图
                [KSYKitTool setMixerMasterLayer:self.cameraLayer kit:self];
                [KSYKitTool addInput:src  ToMixerAt:self.cameraLayer kit:self];
                [KSYKitTool addInput:picModel.input ToMixerAt:picModel.layerIndex  Rect:CGRectZero kit:self];
            }
        }
        
        if (!picModel.isClear)
            [KSYKitTool addInput:picModel.input ToMixerAt:picModel.layerIndex Rect:[self getRectFromIndex:picModel.layerIndex] kit:self];
        else
            [KSYKitTool clearMixerLayer:picModel.layerIndex kit:self];
    }
    
    [src addTarget:self.picOutPut];
    
    //组装自定义view
    if(_uiElementInput)
        [self addElementInput:_uiElementInput callbackOutput:src layerIndex:_customViewLayer rect:_customViewRect];
    else
        [self removeElementInput:_uiElementInput callbackOutput:src layerIndex:_customViewLayer];
    
    
    if(_waterElementInput)
        [self addElementInput:_waterElementInput callbackOutput:src layerIndex:_waterViewLayer rect:_waterViewRect];
    else
        [self removeElementInput:_waterElementInput callbackOutput:src layerIndex:_waterViewLayer];
    
    // 混合后的图像输出到预览和推流
    [self.vPreviewMixer removeAllTargets];
    [self.vPreviewMixer addTarget:self.preview];
    [self.vStreamMixer  removeAllTargets];
    [self.vStreamMixer  addTarget:self.gpuToStr];
    [self setPreviewMirrored:self.previewMirrored];
    [self setStreamerMirrored:self.streamerMirrored];
    
}

- (void) mixterBuffer:(CVPixelBufferRef)pixelBuffer itemId:(NSString *)itemId
{
    if(!itemId)
        return;
    KSYAgoraPicModel *pic = [self getPicModelByItemId:itemId];
    KSYGPUPicInput  *  rtcYuvInput =pic.input;
    CGSize preSize =[KSYKitTool adjustVideoProfile:self.agoraKit.videoProfile];
    CGSize rtcInputSize = CGSizeMake(CVPixelBufferGetWidth(pixelBuffer),CVPixelBufferGetHeight(pixelBuffer));
    CGSize cropSz = [KSYKitTool calcCropSize:rtcInputSize to:preSize];
    rtcYuvInput.cropRegion = [KSYKitTool calcCropRect:rtcInputSize to:cropSz];
    [rtcYuvInput forceProcessingAtSize:preSize];
    [rtcYuvInput processPixelBuffer:pixelBuffer time:CMTimeMake(2, 10)];
    
}

#pragma mark  减去人数
// 根据itemId删除model和图层
- (void)removeItemId:(NSInteger)ItemId
{
    dispatch_sync(self.operateQueue, ^{
        NSString *iid = [NSString stringWithFormat:@"%ld",(long)ItemId];
        if ([self.keyArray containsObject:iid]) {
            [self.keyArray removeObject:iid];
        }
        if (self.keyArray.count==0) {
            [self setRtcViewDefault];
        }
        
        if ([self.keyMap objectForKey:iid]) {
            //重置默认图层
            for (KSYAgoraPicModel *picModel  in self.map.allValues) {
                if (picModel.layerIndex==8)
                    picModel.isClear = NO;
                else
                   picModel.isClear = YES;
            }
            
            [self.keyMap removeObjectForKey:[NSString stringWithFormat:@"%ld",(long)ItemId]];
            for (int i=0;i<self.keyMap.allKeys.count;i++) //重置图层
            {
                NSString *keysId =[self.keyMap.allKeys objectAtIndex:i];
                NSString *value = [NSString stringWithFormat:@"%d",i+1];
                [self.keyMap setObject:value forKey:keysId];
                 KSYAgoraPicModel *picModel = [self.map objectForKey:value];
                 picModel.isClear = NO;
            }
            
           [self updateLayer];
        }

    });
    
}
// 根据itemId 更新试图 动态修改图层以及绑定数据与试图
#pragma mark  增加人数
- (void)updatePixelBuffer:(CVPixelBufferRef)pixelBuffer  byItemId:(unsigned int)itemId
{
    
    NSString *iid = [NSString stringWithFormat:@"%ld",(long)itemId];
    if ([self.keyMap objectForKey:iid]) {
        [self mixterBuffer:pixelBuffer itemId:[self.keyMap objectForKey:iid]];
    }
    if (self.currentNumBlock) {
        self.currentNumBlock(self.keyArray.count);
    }
}

- (void)addItemId:(NSUInteger)itemId
{
    NSString *iid = [NSString stringWithFormat:@"%ld",(long)itemId];
    if (![self.keyArray containsObject:iid]&&self.keyArray.count<kMaxNumber-1) {
        [self.keyArray addObject:iid];
    }
    if (![self.keyMap objectForKey:iid]&&[self.keyArray containsObject:iid]) {
        // key 为 itemid  value为当前第几个人
        NSString *keyNum = [NSString stringWithFormat:@"%ld",(unsigned long)self.keyArray.count];
        [self.keyMap setObject:keyNum forKey:iid];
    }
    [self startRtcView];
}


#pragma mark 自定义图层混合
-(void) addElementInput:(GPUImageUIElement *)input
         callbackOutput:(GPUImageOutput*)callbackOutput
             layerIndex:(NSInteger)layerIndex
                   rect:(CGRect)rect
{
    __weak GPUImageUIElement *weakUIEle = input;
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
    [KSYKitTool addInput:input ToMixerAt:layerIndex Rect:rect kit:self];
}

-(void) removeElementInput:(GPUImageUIElement *)input
            callbackOutput:(GPUImageOutput *)callbackOutput
                layerIndex:(NSInteger)layerIndex
{
    [KSYKitTool clearMixerLayer:layerIndex kit:self];
    [callbackOutput setFrameProcessingCompletionBlock:nil];
}

#pragma mark 1v1 使用的方法


- (void)setEnablePK:(BOOL)enablePK
{
    if (self.keyArray.count!=1&&_enablePK==NO) {
        NSLog(@"当前人数不等于2，不能开启1v1pk");
        return;
    }
    
    _enablePK = enablePK;
    _enableSwitch = NO;
    if (_enablePK)
        [self startUsePK];
    else
        [self stopUsePK];
    
}

- (void)setCamRect:(CGRect)camRect
{
    _camRect =camRect;
    _customCamRect = camRect;
}

- (void)setOtherRemoteRect:(CGRect)otherRemoteRect
{
    _customOtherRemoteRect = otherRemoteRect;
    _otherRemoteRect = otherRemoteRect;
}

- (void)setEnableSwitch:(BOOL)enableSwitch
{
    if (_enablePK) {
        NSLog(@"开启pk，不能切换屏幕");
        return;
    }
    if (self.keyArray.count!=1) {
        NSLog(@"当前人数不等于2，不能切换屏幕");
        return;
    }
    _enableSwitch =enableSwitch;
    if (_enableSwitch)
        [self startEnbaleSwitch];
    else
        [self stopEnbaleSwitch];
    
    [self updateLayer];
}


- (void)startEnbaleSwitch
{
    if ([self isCustomCamRect])
        _camRect = _customCamRect;
    else
        _camRect = CGRectMake(0, 0, 1, 1);
    
    if (self.isCustomOtherRemoteRect)
        _otherRemoteRect = _customOtherRemoteRect;
    else
        _otherRemoteRect = CGRectMake(0.6, 0.03, 0.36, 0.36);
}

- (void)stopEnbaleSwitch
{
    if ([self isCustomCamRect])
        _camRect = _customCamRect;
    else
        _camRect = CGRectMake(0.6, 0.03, 0.36, 0.36);
    
    if (self.isCustomOtherRemoteRect)
        _otherRemoteRect = _customOtherRemoteRect;
    else
        _otherRemoteRect = CGRectMake(0, 0, 1, 1);
}


- (BOOL) isCustomCamRect
{
    return !CGRectEqualToRect(_customCamRect,CGRectZero);
}
- (BOOL) isCustomOtherRemoteRect
{
    return !CGRectEqualToRect(_customOtherRemoteRect,CGRectZero);
}


- (void)startUsePK
{
    if ([self isCustomCamRect])
        _camRect = _customCamRect;
    else
        _camRect = CGRectMake(0.5, 0.25, 0.5, 0.5);
    
    if (self.isCustomOtherRemoteRect)
        _otherRemoteRect = _customOtherRemoteRect;
    else
        _otherRemoteRect = CGRectMake(0.0, 0.25,0.5 ,0.5);
    
    if(_contentView.subviews.count != 0)
        _uiElementInput = [[GPUImageUIElement alloc] initWithView:_contentView];
    [self updateLayer];
}

- (void)stopUsePK
{
    if ([self isCustomCamRect])
        _camRect = _customCamRect;
    else
        _camRect = CGRectMake(0.6, 0.03, 0.36, 0.36);
    
    if (self.isCustomOtherRemoteRect)
        _otherRemoteRect = _customOtherRemoteRect;
    else
        _otherRemoteRect =  CGRectMake(0.0, 0.0,1 ,1);
    _uiElementInput = nil;
    [self updateLayer];
}

- (BOOL)currentChannelHavePerson
{
    if (self.keyArray.count==0) {
        return NO;
    }
    return YES;
}


#pragma mark 水印
- (void)setEnableWater:(BOOL)enableWater
{
    
    if (CGRectEqualToRect(_waterViewRect,CGRectZero)) {
        NSLog(@"请设置水印的位置");
        return;
    }
    if (_waterView.subviews.count==0) {
        NSLog(@"请设置水印的图片");
        return;
    }
    _enableWater = enableWater;
    if (_enableWater)
    {
        [self startWater];
    }
    else
    {
        [self stopWater];
    }
}

//开始使用水印
- (void)startWater
{
    if(_waterView.subviews.count != 0)
        _waterElementInput = [[GPUImageUIElement alloc] initWithView:_waterView];
    [self updateLayer];
}
//停止使用水印
- (void)stopWater
{
    _waterElementInput = nil;
    [self updateLayer];
}


#pragma mark get 方法

// 根据第几个人获取Model
- (KSYAgoraPicModel *)getPicModelByItemId:(NSString *) itemId
{
    KSYAgoraPicModel * picModel  = [_map objectForKey:itemId];
    picModel.isClear = NO;
    return picModel ;
}
//根据图层设置rect 自定义尺寸
- (CGRect )getRectFromIndex:(NSInteger ) index;
{
    switch (index) {
        case 5:
        {
            if (self.keyArray.count<=1)
                return _otherRemoteRect;
            else
                return CGRectMake(0, 0, 0.5, 0.5);
        }
            break;
        case 6:
            
            return CGRectMake(0.5, 0, 0.5, 0.5);
            
            break;
        case 7:
        {
              return CGRectMake(0, 0.5, 0.5, 0.5);
        }
            break;
        case 8:
            return  [self getCustomcamRect];
            
            break;
        default:
            return CGRectMake(0.6, 0.03, 0.36, 0.36);
            
            break;
    }
    return CGRectMake(0.6, 0.03, 0.36, 0.36);
}

- (CGRect)getCustomcamRect
{
    if (self.keyArray.count==1)
        return _camRect;
    else if (self.keyArray.count==2)
        return  CGRectMake(0.25, 0.5, 0.5, 0.5);
    else if (self.keyArray.count==3)
        return  CGRectMake(0.5, 0.5, 0.5, 0.5);
    
    return CGRectZero;
}

#pragma dealloc
- (void)dealloc
{
    if (_map) {
        _map  = nil;
    }
    if (_keyMap) {
        _keyMap = nil;
    }
    if (_keyArray) {
        _keyArray = nil;
    }
    if (_picOutPut) {
        _picOutPut = nil;
    }
    
    if(_contentView)
    {
        _contentView = nil;
    }
    if(_agoraKit){
        [_agoraKit leaveChannel];
        _agoraKit = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (int)adjustRecordingSignalVolume:(NSInteger)volume
{
    return [_agoraKit adjustRecordingSignalVolume:volume];
}

- (int)adjustPlaybackSignalVolume:(NSInteger)volume
{
    return [_agoraKit adjustPlaybackSignalVolume:volume];
}




@end
