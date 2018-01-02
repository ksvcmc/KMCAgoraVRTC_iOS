//
//  KSYConfigViewController.m
//  AgoraVRTCDemo
//
//  Created by yuyang on 2017/11/22.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import "KSYConfigViewController.h"
#import "KSYHeader.h"
#import "KSYSegmentedControl.h"
#import "Masonry.h"
#import "KSYSliderView.h"
#import "KSYStaticData.h"
#import "KSYDefaultParamCenter.h"

@interface KSYConfigViewController ()
{
    UIView *overlay ;
}

@property (nonatomic,strong)KSYSegmentedControl *capControl;
@property (nonatomic,strong)KSYSegmentedControl *streamerControl;
@property (nonatomic,strong)KSYSegmentedControl *videoCodecControl;
@property (nonatomic,strong)KSYSegmentedControl *audioCodecControl;
@property (nonatomic,strong)KSYSliderView *videoFpsSiler;
@property (nonatomic,strong)KSYSliderView *videoRateSiler;
@property (nonatomic,strong)KSYSegmentedControl *audioRatControl;
@property (nonatomic,strong)UIScrollView *scrollView;
@property (nonatomic,strong)UIView * contentView;
@property (nonatomic,strong)KSYConfig * config;

@end

@implementation KSYConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavBar];
    [self createView];
    [self __layoutSubViews];
    [self callBack];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [overlay removeFromSuperview];
    self.navigationController.navigationBar.backgroundColor =  [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can bew recreated.
}


- (void)dealloc
{
    
}

#pragma mark eventHandler

//保存
- (void)save
{
    NSLog(@"保存");
    kGobalDefaultParamCenter.capPreset = self.config.capPix;
    kGobalDefaultParamCenter.streamDimension = self.config.streamerSize;
    kGobalDefaultParamCenter.videoFPS = self.config.videoFPS;
    kGobalDefaultParamCenter.videoCodec = self.config.videoCodec;
    kGobalDefaultParamCenter.audioCodec = self.config.audioCodec;
    kGobalDefaultParamCenter.videoKbps = self.config.videoKbps;
    kGobalDefaultParamCenter.audioKbps =self.config.audioKbps;
    kGobalDefaultParamCenter.capIndex = self.config.capIndex;
    kGobalDefaultParamCenter.streamIndex =  self.config.streamIndex;
    kGobalDefaultParamCenter.videoCodecIndex =  self.config.videoCodecIndex;
    kGobalDefaultParamCenter.audioCodecIndex = self.config.audioCodecIndex;
    kGobalDefaultParamCenter.audioKbpsIndex = self.config.audioKbpsIndex;
    
}

- (void)callBack
{
    
    @KSYWeakObj(self);
    self.capControl.seletedIndex = ^(NSInteger index) {
        @KSYStrongObj(self)
        self.config.capIndex = index;
        self.config.capPix = [KSYStaticData getCapPix:index];
        NSLog(@"采集分辨率为 %@ ",self.config.capPix);
        
    };
    
    self.streamerControl.seletedIndex = ^(NSInteger index) {
        @KSYStrongObj(self)
        self.config.streamIndex =  index;
        self.config.streamerSize = [KSYStaticData getStreamerDimensionToSize:index];
        NSLog(@"推流分辨率Size为 %@ ",NSStringFromCGSize(self.config.streamerSize));
        
    };
    
    self.videoFpsSiler.seletedIndex = ^(NSInteger index) {
        @KSYStrongObj(self)
        self.config.videoFPS =(int)index;
        NSLog(@"帧率为 %d ",self.config.videoFPS);
        
    };
    
    self.videoCodecControl.seletedIndex = ^(NSInteger index) {
        @KSYStrongObj(self)
        self.config.videoCodecIndex =  index;
        self.config.videoCodec = [KSYStaticData videoCodecIndex:index];
        NSLog(@"视频编码 %ld ",self.config.videoCodec);
        
    };
    
    self.audioCodecControl.seletedIndex = ^(NSInteger index) {
        @KSYStrongObj(self)
        self.config.audioCodecIndex = index;
        self.config.audioCodec = [KSYStaticData audioCodec:index];
        NSLog(@"音频编码 %ld ",self.config.audioCodec);
        
    };
    
    self.videoRateSiler.seletedIndex = ^(NSInteger index) {
        @KSYStrongObj(self)
        self.config.videoKbps = (int)index;
        NSLog(@"视频码率 %d ",self.config.videoKbps);
    };
    
    self.audioRatControl.seletedIndex = ^(NSInteger index) {
        @KSYStrongObj(self)
        self.config.audioKbpsIndex = index;
        self.config.audioKbps = [KSYStaticData audioCodec:index];
        NSLog(@"音频码率 %d ",self.config.audioKbps);
    };
}

#pragma mark UI

- (void)setNavBar
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    overlay = [[UIView alloc] initWithFrame:CGRectMake(0, -20, [UIScreen mainScreen].bounds.size.width,20)];
    overlay.backgroundColor = UIColorFromRGB(0x18181D);
    [self.navigationController.navigationBar insertSubview:overlay atIndex:0];
    self.navigationController.navigationBar.backgroundColor =  UIColorFromRGB(0x18181D);
    self.view.backgroundColor  = UIColorFromRGB(0x27272C);
    self.title = @"视频连麦Demo设置";
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = leftButton;
    
}



- (void)createView
{
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.scrollView];
    self.contentView = [[UIView alloc] init];
    [self.scrollView  addSubview:self.contentView];
    
    self.capControl = [[KSYSegmentedControl alloc]initTitle:@"采集分辨率" array:@[@"360p",@"540p",@"720p"]];
    [self.scrollView addSubview:self.capControl];
    [self.capControl setIndex:kGobalDefaultParamCenter.capIndex];
    
    self.streamerControl = [[KSYSegmentedControl alloc]initTitle:@"推流分辨率" array:@[@"360p",@"540p",@"720p"]];
    [self.scrollView addSubview:self.streamerControl];
    [self.streamerControl setIndex:kGobalDefaultParamCenter.streamIndex];
    
    
    self.videoFpsSiler = [[KSYSliderView alloc]initTitle:@"视频帧率" min:1.0 max:30.0];
    [self.scrollView addSubview:self.videoFpsSiler];
    [self.videoFpsSiler setIndex:kGobalDefaultParamCenter.videoFPS];
    
    
    self.videoCodecControl = [[KSYSegmentedControl alloc]initTitle:@"视频编码器" array:@[@"自动",@"软解264",@"硬解264",@"软解265"]];
    [self.scrollView addSubview:self.videoCodecControl];
    [self.videoCodecControl setIndex:kGobalDefaultParamCenter.videoCodecIndex];
    
    self.audioCodecControl = [[KSYSegmentedControl alloc]initTitle:@"音频编码器" array:@[@"ACC-HE",@"AAC_LC",@"AT_AAC",@"AAC_HE_V2"]];
    [self.scrollView addSubview:self.audioCodecControl];
    [self.audioCodecControl setIndex:kGobalDefaultParamCenter.audioCodecIndex];
    
    self.videoRateSiler = [[KSYSliderView alloc]initTitle:@"视频码率" min:100.0 max:1500.0];
    [self.scrollView addSubview:self.videoRateSiler];
    [self.videoRateSiler setIndex:kGobalDefaultParamCenter.videoKbps];
    
    self.audioRatControl = [[KSYSegmentedControl alloc]initTitle:@"音频kbps" array:@[@"12",@"24",@"32", @"48", @"64", @"128"]];
    [self.scrollView addSubview:self.audioRatControl];
    [self.audioRatControl setIndex:3];
    
    
    
}

- (void)__layoutSubViews
{
    @KSYWeakObj(self);
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        @KSYStrongObj(self)
        make.edges.equalTo(self.view);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        @KSYStrongObj(self);
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
        make.height.greaterThanOrEqualTo(@0.f);//此处保证容器View高度的动态变化 大于等于0.f的高度
    }];
    
    [self.capControl mas_makeConstraints:^(MASConstraintMaker *make) {
        @KSYStrongObj(self);
        make.top.equalTo(self.contentView).with.offset(0);
        make.left.equalTo(self.contentView).with.offset(0);
        make.right.equalTo(self.contentView).with.offset(0);
        make.right.height.mas_equalTo(90);
        
    }];
    [self.streamerControl mas_makeConstraints:^(MASConstraintMaker *make) {
        @KSYStrongObj(self);
        make.top.equalTo(self.capControl.mas_bottom).with.offset(0);
        make.left.equalTo(self.contentView).with.offset(0);
        make.right.equalTo(self.contentView).with.offset(0);
        make.right.height.mas_equalTo(90);
        
    }];
    [self.videoFpsSiler mas_makeConstraints:^(MASConstraintMaker *make) {
        @KSYStrongObj(self);
        make.top.equalTo(self.streamerControl.mas_bottom).with.offset(0);
        make.left.equalTo(self.contentView).with.offset(0);
        make.right.equalTo(self.contentView).with.offset(0);
        make.right.height.mas_equalTo(90);
        
    }];
    [self.videoCodecControl mas_makeConstraints:^(MASConstraintMaker *make) {
        @KSYStrongObj(self);
        make.top.equalTo(self.videoFpsSiler.mas_bottom).with.offset(0);
        make.left.equalTo(self.contentView).with.offset(0);
        make.right.equalTo(self.contentView).with.offset(0);
        make.right.height.mas_equalTo(90);
        
    }];
    
    [self.audioCodecControl mas_makeConstraints:^(MASConstraintMaker *make) {
        @KSYStrongObj(self);
        make.top.equalTo(self.videoCodecControl.mas_bottom).with.offset(0);
        make.left.equalTo(self.contentView).with.offset(0);
        make.right.equalTo(self.contentView).with.offset(0);
        make.right.height.mas_equalTo(90);
        
    }];
    
    [self.videoRateSiler mas_makeConstraints:^(MASConstraintMaker *make) {
        @KSYStrongObj(self);
        make.top.equalTo(self.audioCodecControl.mas_bottom).with.offset(0);
        make.left.equalTo(self.contentView).with.offset(0);
        make.right.equalTo(self.contentView).with.offset(0);
        make.right.height.mas_equalTo(90);
        
    }];
    
    [self.audioRatControl mas_makeConstraints:^(MASConstraintMaker *make) {
        @KSYStrongObj(self);
        make.top.equalTo(self.videoRateSiler.mas_bottom).with.offset(0);
        make.left.equalTo(self.contentView).with.offset(0);
        make.right.equalTo(self.contentView).with.offset(0);
        make.height.mas_equalTo(90);
        make.bottom.equalTo(self.contentView).offset(-10);
        
    }];
    
}

#pragma mark Lazy

- (KSYConfig *)config
{
    if(!_config)
    {
        _config = [[KSYConfig alloc]init];
        _config.capPix = kGobalDefaultParamCenter.capPreset;
        _config.streamerSize = kGobalDefaultParamCenter.streamDimension;
        _config.videoFPS = kGobalDefaultParamCenter.videoFPS;
        _config.videoCodec = kGobalDefaultParamCenter.videoCodec;
        _config.audioCodec = kGobalDefaultParamCenter.audioCodec;
        _config.videoKbps = kGobalDefaultParamCenter.videoKbps;
        _config.audioKbps =  kGobalDefaultParamCenter.audioKbps;
        _config.capIndex  = kGobalDefaultParamCenter.capIndex;
        _config.streamIndex = kGobalDefaultParamCenter.streamIndex ;
        _config.videoCodecIndex =kGobalDefaultParamCenter.videoCodecIndex;
        _config.audioCodecIndex = kGobalDefaultParamCenter.audioCodecIndex;
        _config.audioKbpsIndex = kGobalDefaultParamCenter.audioKbpsIndex;
        
    }
    return _config;
}






@end
