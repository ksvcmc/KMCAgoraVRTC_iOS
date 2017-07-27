//
//  KSYRTCKitDemoVC.m
//  KSYGPUStreamerDemo
//
//  Created by yiqian on 6/23/16.
//  Copyright © 2016 ksyun. All rights reserved.
//
#import "KSYStreamerVC.h"
#import "KSYAgoraStreamerKit.h"
#import "KSYRTCAgoraVC.h"
#import <KMCAgoraVRTC/KMCAgoraVRTC.h>
#import <libksygpulive/libksystreamerengine.h>
#import <libksygpulive/KSYGPUStreamerKit.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface KSYRTCAgoraVC () <KMCRtcDelegate>{
    id _filterBtn;
    UILabel* label;
    NSDateFormatter * _dateFormatter;
    int64_t _seconds;
    bool _ismaster;
    
    UIPanGestureRecognizer *panGestureRecognizer;
    UIView* _winRtcView;
}
@property bool beQuit;

@end

@implementation KSYRTCAgoraVC

#pragma mark - UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Set the label text.
    hud.label.text = @"鉴权中...";
    
    _kit = [[KSYAgoraStreamerKit alloc] initWithDefaultCfg:self];
    // 获取streamerBase, 方便进行推流相关操作, 也可以直接 _kit.streamerBase.xxx
    self.streamerBase = _kit.streamerBase;
    // 采集相关设置初始化
    [self setCaptureCfg];
    //推流相关设置初始化
    [self setStreamerCfg];
    //设置rtc参数
    [self setAgoraStreamerKitCfg];
    

    _ismaster = NO;
    _beQuit = NO;
    //设置拖拽手势
    panGestureRecognizer=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
    CGRect rect;
    rect.origin.x = _kit.winRect.origin.x * self.view.frame.size.width;
    rect.origin.y = _kit.winRect.origin.y * self.view.frame.size.height;
    rect.size.height =_kit.winRect.size.height * self.view.frame.size.height;
    rect.size.width =_kit.winRect.size.width * self.view.frame.size.width;
    
    _winRtcView =  [[UIView alloc] initWithFrame:rect];
    _winRtcView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_winRtcView];
    [self.view bringSubviewToFront:_winRtcView];
    [_winRtcView addGestureRecognizer:panGestureRecognizer];

}

- (void)onTimer:(NSTimer *)theTimer{
    if (_kit.streamerBase.streamState == KSYStreamStateConnected ) {
        [self.ctrlView.lblStat updateState: _kit.streamerBase];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.ctrlView.btnQuit setTitle: @"退出kit"
                           forState: UIControlStateNormal];
    [self.ksyMenuView.rtcBtn setHidden:NO];
    if (_kit) {
        // init with default filter
        [_kit setupFilter:self.ksyFilterView.curFilter];
        _kit.curfilter =self.ksyFilterView.curFilter;
        [_kit startPreview:self.view];
    }
}

- (void) setCaptureCfg {
    _kit.capPreset = [self.presetCfgView capResolution];
    _kit.previewDimension = [self.presetCfgView capResolutionSize];
    _kit.streamDimension  = [self.presetCfgView strResolutionSize ];
    _kit.videoFPS       = [self.presetCfgView frameRate];
    _kit.cameraPosition = [self.presetCfgView cameraPos];
}

#pragma mark - 采集/推流功能

- (void) onFlash {
    [_kit toggleTorch];
}

- (void) onCameraToggle{
    [_kit switchCamera];
    if (_kit && [_kit isTorchSupported]) {
        [self.ctrlView.btnFlash setEnabled:YES];
    }
    else{
        [self.ctrlView.btnFlash setEnabled:NO];
    }
    [super onCameraToggle];
}

- (void) onCapture{
    if (!_kit.vCapDev.isRunning){
        [_kit startPreview:self.view];
    }
    else {
        [_kit stopPreview];
    }
}
- (void) onStream{
    if (_kit.streamerBase.streamState == KSYStreamStateIdle ||
        _kit.streamerBase.streamState == KSYStreamStateError) {
        [_kit.streamerBase startStream:self.hostURL];
        self.streamerBase = _kit.streamerBase;
        _seconds = 0;
    }
    else {
        [_kit.streamerBase stopStream];
        self.streamerBase = nil;
    }
}

- (void) onFilterChange:(id)sender{
    if (self.ksyFilterView.curFilter != _kit.filter){
        // use a new filter
         [_kit setupRtcFilter:self.ksyFilterView.curFilter];
    }
}

#pragma mark - 连麦配置
- (void) setAgoraStreamerKitCfg {
    
    _kit.selfInFront = NO;
    _kit.agoraKit.videoProfile = AgoraRtc_VideoProfile_DEFAULT;
    //设置小窗口属性
    _kit.winRect = CGRectMake(0.6, 0.6, 0.3, 0.3);//设置小窗口属性
    _kit.rtcLayer = 4;//设置小窗口图层，因为主版本占用了1~3，建议设置为4
    
    //特性1：悬浮图层，用户可以在小窗口叠加自己的view，注意customViewLayer >rtcLayer,（option）
    _kit.customViewRect = CGRectMake(0.6, 0.6, 0.3, 0.3);
    _kit.customViewLayer = 5;
//    UIView * customView = [self createUIView];
//    [_kit.contentView addSubview:customView];
    
    //特性2:圆角小窗口
    _kit.maskPicture = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"mask.png"]];

    __weak KSYRTCAgoraVC *weak_demo = self;
    //kit回调，（option）
    _kit.onCallStart =^(int status){
        if(status == 200)
        {
            if([UIApplication sharedApplication].applicationState !=UIApplicationStateBackground)
            {
                [weak_demo statEvent:@"建立连接," result:status];
            }
        }
        NSLog(@"oncallstart:%d",status);
    };
    _kit.onCallStop = ^(int status){
        if(status == 200)
        {
            if([UIApplication sharedApplication].applicationState !=UIApplicationStateBackground)
            {
                [weak_demo statEvent:@"断开连接," result:status];
            }
        }
        NSLog(@"oncallstop:%d",status);
    };
    _kit.onChannelJoin = ^(int status){
        if(status == 200)
        {
            if([UIApplication sharedApplication].applicationState !=UIApplicationStateBackground)
            {
                [weak_demo statEvent:@"成功加入," result:status];
            }
        }
        NSLog(@"onChannelJoin:%d",status);
    };

    
}

-(void)onJoinChannelBtn
{
    [_kit joinChannel:@"ksy24"];
}

-(void)onLeaveChannelBtn
{
    [_kit leaveChannel];
}

- (void) onQuit{
    [_kit stopPreview];
    [_kit leaveChannel];
    _kit = nil;
    [super onQuit];
    
}


#pragma mark - tool
-(void)statEvent:(NSString *)event
          result:(int)ret
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.ctrlView.lblStat.text.length > 100)
            self.ctrlView.lblStat.text= @"";
        NSString *text = [NSString stringWithFormat:@"\n%@, ret:%d",event,ret];
        self.ctrlView.lblStat.text = [ self.ctrlView.lblStat.text  stringByAppendingString:text  ];
        
    });
}
-(void)statString:(NSString *)event
{
    if(self.ctrlView.lblStat.text.length > 100)
        self.ctrlView.lblStat.text= @"";
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *text = [NSString stringWithFormat:@"\n%@",event];
        self.ctrlView.lblStat.text = [ self.ctrlView.lblStat.text  stringByAppendingString:text  ];
    });
}

-(void) onSwitchRtcView:(CGPoint)location
{
    CGRect winrect = _kit.winRect;
    
    //只有小窗口点击才会切换窗口
    if((location.x > winrect.origin.x && location.x <winrect.origin.x +winrect.size.width) &&
        (location.y > winrect.origin.y && location.y <winrect.origin.y +winrect.size.height))
    {
        _kit.selfInFront = !_kit.selfInFront;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    CGPoint origin = [[touches anyObject] locationInView:self.view];
    CGPoint location;
    location.x = origin.x/self.view.frame.size.width;
    location.y = origin.y/self.view.frame.size.height;
    [self onSwitchRtcView:location];
}

-(void)panAction:(UIPanGestureRecognizer *)sender
{
    //获取手势在屏幕上拖动的点
    
    CGPoint translatedPoint = [panGestureRecognizer translationInView:self.view];
    
    panGestureRecognizer.view.center = CGPointMake(panGestureRecognizer.view.center.x + translatedPoint.x, panGestureRecognizer.view.center.y + translatedPoint.y);
    
    CGRect newWinRect;
    newWinRect.origin.x = (panGestureRecognizer.view.center.x - panGestureRecognizer.view.frame.size.width/2)/self.view.frame.size.width;
    newWinRect.origin.y = (panGestureRecognizer.view.center.y - panGestureRecognizer.view.frame.size.height/2)/self.view.frame.size.height;
    newWinRect.size.height = _kit.winRect.size.height;
    newWinRect.size.width = _kit.winRect.size.width;
    _kit.winRect = newWinRect;
    [panGestureRecognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}

- (BOOL)checkNetworkReachability:(sa_family_t)sa_family {
    //www.apple.com - IPv4: 125.252.236.67 - IPv6: 64:ff9b::7dfc:ec43
    static unsigned char ipv4_addr[4] = {125, 252, 236, 67};
    static unsigned char ipv6_addr[16] = {0x00, 0x64, 0xff, 0x9b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x7d, 0xfc, 0xec, 0x43};
    
    struct sockaddr *pZeroAddress = nil;
    struct sockaddr_in zeroSockaddrin;
    struct sockaddr_in6 zeroSockaddrin6;
    if (AF_INET == sa_family) {
        bzero(&zeroSockaddrin, sizeof(zeroSockaddrin));
        bcopy(ipv4_addr, &zeroSockaddrin.sin_addr, sizeof(zeroSockaddrin.sin_addr));
        zeroSockaddrin.sin_len = sizeof(zeroSockaddrin);
        zeroSockaddrin.sin_family = AF_INET;
        pZeroAddress = (struct sockaddr *)&zeroSockaddrin;
    } else if (AF_INET6 == sa_family) {
        bzero(&zeroSockaddrin6, sizeof(zeroSockaddrin6));
        bcopy(ipv6_addr, &zeroSockaddrin6.sin6_addr, sizeof(zeroSockaddrin6.sin6_addr));
        zeroSockaddrin6.sin6_len = sizeof(zeroSockaddrin6);
        zeroSockaddrin6.sin6_family = AF_INET6;
        pZeroAddress = (struct sockaddr *)&zeroSockaddrin6;
    }
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, pZeroAddress);
    SCNetworkReachabilityFlags flags;
    if (!defaultRouteReachability) {
        return NO;
    }
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    if (!didRetrieveFlags) {
        return NO;
    }
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL isLocalAddress = flags & kSCNetworkFlagsIsLocalAddress;
    BOOL isDirect = flags & kSCNetworkFlagsIsDirect;
    return (isReachable && !isLocalAddress && !isDirect) ? YES : NO;
}

-(UIView *)createUIView{
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    view.layer.borderWidth = 10;
    view.layer.borderColor = [[UIColor blueColor] CGColor];
    return view;
}

#pragma AgoraRtcEngineDelegate

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraRtcUserOfflineReason)reason
{
    if(_kit.callstarted){
        [_kit stopRTCView];
        if(_kit.onCallStop)
            _kit.onCallStop(reason);
        _kit.callstarted = NO;
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed
{
    if(!_kit.callstarted)
    {
        [_kit startRtcView];
        if(_kit.onCallStart)
            _kit.onCallStart(200);
        _kit.callstarted = YES;
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOccurError:(AgoraRtcErrorCode)errorCode
{
    NSString * errorMessage = [[NSString alloc]initWithFormat:@"出错了,错误码:%@", @(errorCode)];
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:(BOOL)YES];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:errorMessage delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alert show];
    });
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine remoteVideoStats:(AgoraRtcRemoteVideoStats*)stats
{
    //    NSLog(@"remotestats,width:%lu,height:%lu,fps:%lu,receivedBitrate:%lu",(unsigned long)stats.width,(unsigned long)stats.height,(unsigned long)stats.receivedFrameRate,(unsigned long)stats.receivedBitrate);
    //
}

- (void)authSuccess:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:(BOOL)YES];
    });
    
    
}

- (void)authFailure:(AuthorizeError)iErrorCode
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:(BOOL)YES];
        
        NSString * errorMessage = [[NSString alloc]initWithFormat:@"鉴权失败，错误码:%@", @(iErrorCode)];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:errorMessage delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alert show];
    });
    
}


@end
