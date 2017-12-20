//
//  KSY1V1PKViewController.m
//  KMCAgoraVRTCDemo
//
//  Created by yuyang on 2017/12/19.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import "KSY1V1PKViewController.h"
#import "KSYAgoraStreamerKit.h"
#import <KMCAgoraVRTC/KMCAgoraVRTC.h>
#import <MBProgressHUD/MBProgressHUD.h>


#define FLOAT_EQ( f0, f1 ) ( (f0 - f1 < 0.001)&& (f0 - f1 > -0.001) )

//16进制颜色转换
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface KSY1V1PKViewController ()<KMCRtcDelegate>
@property (nonatomic,strong)KSYAgoraStreamerKit *kit;

@end

@implementation KSY1V1PKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // Set the label text.
    hud.label.text = @"鉴权中...";
    [self initKit];
    [self creatBtn];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_kit) {
        [_kit stopPreview];
        [_kit.streamerBase stopStream];
        [_kit leaveChannel];
        _kit = nil;
    }
}


- (void) initKit{
    _kit = [[KSYAgoraStreamerKit alloc] initWithDefaultCfg:self];
    _kit.capPreset =AVCaptureSessionPreset640x480;
    _kit.previewDimension = CGSizeMake(640, 360);
    _kit.streamDimension  = CGSizeMake(640, 360);
    _kit.videoFPS       = 15;
    _kit.cameraPosition =AVCaptureDevicePositionFront;
    
    _kit.selfInFront = NO; // 画面  YES 主播在左边  NO 主播在右边
    CGFloat ratio = _kit.previewDimension.width / _kit.previewDimension.height;
    if ( FLOAT_EQ( ratio, 16.0/9 ) || FLOAT_EQ( ratio,  9.0/16) ){
        _kit.agoraKit.videoProfile = AgoraRtc_VideoProfile_DEFAULT;
    }else{
        _kit.agoraKit.videoProfile = AgoraRtc_VideoProfile_480P;
    }    //设置小窗口属性
    
    _kit.camRect = CGRectMake(0.0, 0.0, 1.0, 1.0);//设置小窗口属性，可以调整camera窗口的位置和大小，这里设置成全屏显示
    _kit.winRect = CGRectMake(0.5, 0.25, 0.5, 0.5);//设置小窗口属性
    
    _kit.rtcLayer = 4;//设置小窗口图层，因为主版本占用了1~3，建议设置为4
    
    
    _kit.customViewRect = CGRectMake(0, 0, 1, 1);
    _kit.customViewLayer = 1;
    UIView * customView = [self createUIView];
    [_kit.contentView addSubview:customView];
    
    __weak KSY1V1PKViewController *weak_demo = self;
    //kit回调，（option）
    _kit.onCallStart =^(int status){
        if(status == 200)
        {
            if([UIApplication sharedApplication].applicationState !=UIApplicationStateBackground)
            {
                [weak_demo alterMessage:@"建立连接" code:status];
            }
        }
        NSLog(@"oncallstart:%d",status);
    };
    _kit.onCallStop = ^(int status){
        if(status == 200)
        {
            if([UIApplication sharedApplication].applicationState !=UIApplicationStateBackground)
            {
                [weak_demo alterMessage:@"断开连接" code:status];
            }
        }
        NSLog(@"oncallstop:%d",status);
    };
    _kit.onChannelJoin = ^(int status){
        if(status == 200)
        {
            if([UIApplication sharedApplication].applicationState !=UIApplicationStateBackground)
            {
                [weak_demo alterMessage:@"成功加入" code:status];
            }
        }
        NSLog(@"onChannelJoin:%d",status);
    };
    [_kit startPreview:self.view];
    
    _kit.agoraKit.leaveChannelBlock = ^(AgoraRtcStats *stat) {
        weak_demo.title = @"离开频道";
    };
    
}

-(UIView *)createUIView{
    
    UIView *bgView = [[UIView alloc]initWithFrame:self.view.bounds];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0XFFBBFF).CGColor, (__bridge id)UIColorFromRGB(0XFF83FA).CGColor,(__bridge id)UIColorFromRGB(0XE066FF).CGColor];
    gradientLayer.locations = @[@0.3, @0.5, @1.0];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1.0, 0);
    gradientLayer.frame =bgView.frame;
    [bgView.layer addSublayer:gradientLayer];
    return bgView;
}


- (void)alterMessage:(NSString *)message code:(int )code
{
    self.title = message;
}

- (void)joinChannel
{
    [_kit joinChannel:@"ksy24"];
}

- (void)leaveChannel
{
    [_kit leaveChannel];
}

- (void)startStream
{
    if (_kit.streamerBase.streamState == KSYStreamStateIdle ||
        _kit.streamerBase.streamState == KSYStreamStateError) {
        NSString *rtmpSrv = @"rtmp://120.92.224.235/live";
        NSString *devCode = [[self getUuid] substringToIndex:3];
        NSString * _hostUrl = [  NSString stringWithFormat:@"%@/%@", rtmpSrv, devCode];
        [_kit.streamerBase startStream:[NSURL URLWithString:_hostUrl]];
    }
}

- (NSString *) getUuid{
    return [[[[UIDevice currentDevice] identifierForVendor] UUIDString] lowercaseString];
}

- (void)stopStream
{
    if (_kit) {
        [_kit.streamerBase stopStream];
    }
}

- (void)creatBtn
{
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBtn addTarget:self action:@selector(joinChannel) forControlEvents:UIControlEventTouchUpInside];
    [addBtn setTitle:@"加入频道" forState:UIControlStateNormal];
    addBtn.frame = CGRectMake(10, 100, 100, 20);
    [self.view addSubview:addBtn];
    
    UIButton *leaveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leaveBtn addTarget:self action:@selector(leaveChannel) forControlEvents:UIControlEventTouchUpInside];
    [leaveBtn setTitle:@"离开频道" forState:UIControlStateNormal];
    leaveBtn.frame = CGRectMake(self.view.frame.size.width-110, 100, 100, 20);
    [self.view addSubview:leaveBtn];
    
    UIButton *streamBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [streamBtn addTarget:self action:@selector(startStream) forControlEvents:UIControlEventTouchUpInside];
    [streamBtn setTitle:@"打开推流" forState:UIControlStateNormal];
    streamBtn.frame = CGRectMake(10, 200, 100, 20);
    [self.view addSubview:streamBtn];
    
    UIButton *stopStreamBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [stopStreamBtn addTarget:self action:@selector(stopStream) forControlEvents:UIControlEventTouchUpInside];
    [stopStreamBtn setTitle:@"停止推流" forState:UIControlStateNormal];
    stopStreamBtn.frame = CGRectMake(self.view.frame.size.width-110, 200, 100, 20);
    [self.view addSubview:stopStreamBtn];
}


#pragma AgoraRtcEngineDelegate

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraRtcUserOfflineReason)reason
{
    if(_kit.callstarted){
        [_kit stopRTCView];
        _kit.camRect = CGRectMake(0.0, 0.0, 1.0, 1.0);
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
        _kit.camRect = CGRectMake(0.0, 0.25, 0.5, 0.5);
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

