//
//  KSYPlayViewController.m
//  AgoraVRTCDemo
//
//  Created by yuyang on 2017/11/22.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import "KSYPlayViewController.h"
#import "KSYHeader.h"
#import "Masonry.h"
#import "KSYDefaultParamCenter.h"
#import "MBProgressHUD.h"
#import <KMCAgoraVRTC/KMCDefines.h>
#import "KSYMultiAgoraStreamerKit.h"
#import <KMCAgoraVRTC/KMCAgoraVRTC.h>
#import "KSYMenu.h"
#import "KSYKitTool.h"


#define kToken  @"7920903db27923b537ce1beedb976cd1"
#define kTime  0.5

@interface KSYPlayViewController ()<KMCRtcDelegate>
@property (nonatomic,strong)KSYMultiAgoraStreamerKit * kit;
@property (nonatomic,copy) NSString *channelId;
@property (nonatomic,strong) KSYStreamerBase*  streamerBase;
@property (nonatomic,strong) KSYMenu *menu;
@property (nonatomic,copy) NSString *hostUrl;
@property (nonatomic,strong) UITextView *textView;



@end

@implementation KSYPlayViewController

- (instancetype)initWithChannelId:(NSString *)channelId
{
    self = [super init];
    if (!self) return nil;
    self.channelId = channelId;
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    NSString *rtmpSrv = @"rtmp://mobile.kscvbu.cn/live";
    NSString *devCode = [ [KSYKitTool getUuid] substringToIndex:3];
    _hostUrl     = [NSString stringWithFormat:@"%@/%@", rtmpSrv, devCode];
    [self createView];
    [self initAgoraStreamerKit];
    [self addMenu];
    [self joinChannel];
    [self addTextView];
    self.textView.hidden = YES;
    
    @KSYWeakObj(self);
    //监听当前频道人数
    self.kit.currentNumBlock = ^(NSInteger personNum) {
      @KSYStrongObj(self);
        //NSLog(@"当前人数====%ld",personNum);
        if (personNum==1)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.menu hidden1V1Btn:NO];
            });
           
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
               [self.menu hidden1V1Btn:YES];
            });
        }
    };

    
}

-(void) onSwitchRtcView:(CGPoint)location
{
    CGRect winrect = _kit.camRect;
    
    //只有小窗口点击才会切换窗口
    if((location.x > winrect.origin.x && location.x <winrect.origin.x +winrect.size.width) &&
       (location.y > winrect.origin.y && location.y <winrect.origin.y +winrect.size.height))
    {
       //切换
        NSLog(@"切换");
        _kit.enableSwitch = !_kit.enableSwitch;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    CGPoint origin = [[touches anyObject] locationInView:self.view];
    CGPoint location;
    location.x = origin.x/self.view.frame.size.width;
    location.y = origin.y/self.view.frame.size.height;
    [self onSwitchRtcView:location];
}


- (void)addTextView
{
    [self.view addSubview:self.textView];
    self.textView.frame = CGRectMake(10, 10, 0.6*kDeviceWidth-20, 100);
    self.textView.font = [UIFont systemFontOfSize:12];
    self.textView.backgroundColor = [UIColor blackColor];
    self.textView.alpha = 0.5;
    self.textView.textColor = [UIColor whiteColor];
    self.textView.text = [NSString stringWithFormat:@"频道id ： %@ \n播放地址：\n%@",self.channelId,self.hostUrl];
}

- (void)addMenu
{
    [self.view addSubview:self.menu];
    @KSYWeakObj(self);
    self.menu.clickInfoBlock = ^(BOOL isOpen) {
        @KSYStrongObj(self);
        self.textView.hidden =  !isOpen;
        
    };
    self.menu.clickPlayBlock = ^(BOOL isOpen) {
        @KSYStrongObj(self);
        if(isOpen)
        {
            [self.streamerBase stopStream];
        }
        else
        {
            [self startStream:[NSURL URLWithString:self.hostUrl]];
        }
    };
    self.menu.clickMuteBlock = ^(BOOL isOpen) {
        @KSYStrongObj(self);
         self.kit.agoraKit.isMuted = !isOpen;
    };
    self.menu.clickCameraBlock = ^(BOOL isOpen) {
        @KSYStrongObj(self);
        [self.kit switchCamera];
    };
    self.menu.clickSelectScreenBlock = ^(BOOL isOpen) {
        @KSYStrongObj(self);
         self.kit.enablePK = isOpen;
    };

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_kit) {
        [_kit startPreview:self.view];
    }
    
}

- (void)joinChannel
{
    [_kit joinChannel:self.channelId];
}

- (void)leaveChannel
{
    if (_kit) {
        [_kit leaveChannel];
    }

}

- (void)initAgoraStreamerKit
{
    _kit = [[KSYMultiAgoraStreamerKit alloc]initWithDefaultCfg:self token:kToken];
    self.streamerBase = _kit.streamerBase;
    [self setCapConfig];
    [self setStreamerCfg];
    [self setAgoraStreamerKitCfg];
    
}
// 采集
- (void)setCapConfig
{
    _kit.capPreset = kGobalDefaultParamCenter.capPreset;
    _kit.previewDimension = kGobalDefaultParamCenter.previewDimension;
    _kit.streamDimension  = kGobalDefaultParamCenter.streamDimension;
    _kit.videoFPS       = kGobalDefaultParamCenter.videoFPS;
    _kit.cameraPosition = AVCaptureDevicePositionFront;
}

//推流
- (void) setStreamerCfg { // must set after capture
    if (_streamerBase == nil) {
        return;
    }
    _streamerBase.videoCodec       = kGobalDefaultParamCenter.videoCodec;
    _streamerBase.videoInitBitrate = kGobalDefaultParamCenter.videoKbps*6/10;//60%
    _streamerBase.videoMaxBitrate  = kGobalDefaultParamCenter.videoKbps;
    _streamerBase.videoMinBitrate  = 0; //
    _streamerBase.audiokBPS        = kGobalDefaultParamCenter.audioKbps;
    _streamerBase.videoFPS         = kGobalDefaultParamCenter.videoFPS;
    _streamerBase.audioCodec =kGobalDefaultParamCenter.audioCodec;
    _streamerBase.shouldEnableKSYStatModule = YES;
    _streamerBase.bWithMessage = NO;
    _streamerBase.logBlock = ^(NSString* str){ };
    
}
- (void)startStream:(NSURL *)url
{
    if (_kit.streamerBase.streamState == KSYStreamStateIdle ||
        _kit.streamerBase.streamState == KSYStreamStateError) {
        [_kit.streamerBase startStream:url];
    }
}

#pragma mark - 连麦配置
- (void) setAgoraStreamerKitCfg {
    
    _kit.customViewRect = CGRectMake(0, 0, 1, 1);
    _kit.customViewLayer = 1;
    UIView * customView = [self createPKBg];
    [_kit.contentView addSubview:customView];
    
    
    if ([kGobalDefaultParamCenter.capPreset isEqualToString:AVCaptureSessionPreset640x480]) {
        _kit.agoraKit.videoProfile = AgoraRtc_VideoProfile_360P_4;
    }
    else if ([kGobalDefaultParamCenter.capPreset isEqualToString:AVCaptureSessionPresetiFrame960x540])
    {
        // 540 声网不支持
         _kit.agoraKit.videoProfile = AgoraRtc_VideoProfile_360P_4;
    }
    else if ([kGobalDefaultParamCenter.capPreset isEqualToString:AVCaptureSessionPreset1280x720])
    {
        _kit.agoraKit.videoProfile = AgoraRtc_VideoProfile_720P;
    }
    
  
    // 1v1 设置窗口
    /*
    
    _kit.otherRemoteRect = CGRectMake(0, 0, 0.2, 0.2);//设置1v1 的尺寸
    _kit.camRect = CGRectMake(0.6, 0.03, 0.36, 0.36); //设置自己大小
     */
    //水印
    /*
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    view.backgroundColor =[UIColor redColor];
    [_kit.waterView addSubview:view];
    _kit.waterViewRect = CGRectMake(0.5, 0.5, 0.3, 0.3);
    _kit.enableWater = YES;
     */
    
    @KSYWeakObj(self);
    //kit回调，（option）
    _kit.onChannelJoin = ^(){
        @KSYStrongObj(self);

            if([UIApplication sharedApplication].applicationState !=UIApplicationStateBackground)
            {
                [KSYKitTool showAlterView:self.view message:@"成功加入"];
            }
    };
    _kit.leaveChannelBlock = ^{
        @KSYStrongObj(self);
        NSLog(@"离开成功!");
       
    };
    
    
}
// 创建pk 背景
-(UIImageView *)createPKBg{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    imageView.image = [UIImage imageNamed:@"背景"];
    return imageView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma AgoraRtcEngineDelegate

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraRtcUserOfflineReason)reason
{
    NSLog(@"删除前的id 为====%ld",uid);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{//避免新加入的数据影响老数据
        [self.kit removeItemId:uid];
        if([UIApplication sharedApplication].applicationState !=UIApplicationStateBackground)
        {
            if (![_kit currentChannelHavePerson]) {
                [KSYKitTool showAlterView:self.view message:@"断开连接！"]; // 一个人没有提示
                if (_kit.enablePK) {
                    _kit.enablePK = NO;
                }
                [self.menu hidden1V1Btn:YES];
            }
        }
    });
 
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed
{

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ //回调拿到数组再更新图层
        [self.kit  addItemId:uid];
        if([UIApplication sharedApplication].applicationState !=UIApplicationStateBackground)
        {
            if ([_kit currentChannelHavePerson]) {
                [KSYKitTool showAlterView:self.view message:@"建立连接！"]; // 只要有新人加入，就会提示！
            }
        }
    });
   
    
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


#pragma mark event

- (void)closeAction
{
    if (self.leaveBlock_t) {
        self.leaveBlock_t();
    }
    [self leaveChannel];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark UI
- (void)createView
{
    UIButton *closeBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[UIImage imageNamed:@"挂断"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-40);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
}

- (KSYMenu*)menu
{
    if(!_menu)
    {
        _menu = [[KSYMenu alloc] initWithMultiAgoraStreamerKit:self.kit frame:CGRectMake(kDeviceWidth-75, kDeviceHeight-408, 44, 408)];
    }
    return _menu;
}

- (UITextView *)textView
{
    if(!_textView)
    {
        _textView = [[UITextView alloc]init];
    }
    return _textView;
}


- (void)dealloc
{
    [self.streamerBase stopStream];
    [self.kit stopRTCView];
    [self.kit stopPreview];
    self.kit = nil;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    NSLog(@" play   dealloc");
}







@end
