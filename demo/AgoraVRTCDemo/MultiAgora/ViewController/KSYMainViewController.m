//
//  KSYMainViewController.m
//  AgoraVRTCDemo
//
//  Created by yuyang on 2017/11/22.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import "KSYMainViewController.h"
#import "KSYHeader.h"
#import "Masonry.h"
#import "KSYConfigViewController.h"
#import "KSYPlayViewController.h"
#import "KSYDemoExplainView.h"
#import "KSYKitTool.h"

@interface KSYMainViewController ()
@property (nonatomic,strong)UITextField *textField;
@property (nonatomic,strong)KSYDemoExplainView *explainView;
@property (nonatomic,copy)NSString  *rooId;

@end

@implementation KSYMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = @"";
    self.view.backgroundColor  = UIColorFromRGB(0x18181D);
    [self setup];
    [self.view addSubview:self.explainView];
    
    // Do any additional setup after loading the view.
}

//开始连麦
- (void)start
{
    NSLog(@"开始连麦");
    KSYPlayViewController *playVC= [[KSYPlayViewController alloc]initWithChannelId:self.textField.text];
    [self presentViewController:playVC  animated:YES completion:nil] ;
}

//参数设置
- (void)config
{
    NSLog(@"参数设置");
    [self.navigationController pushViewController:[KSYConfigViewController new] animated:YES];
}

//demo说明
- (void)explain
{
    NSLog(@"demo说明");
    self.explainView.hidden = NO;
}


#pragma mark UI Creat
- (void)setup
{
    
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.image = [UIImage imageNamed:@"首页背景图"];
    [self.view addSubview:imageView];
    
    UILabel *titleLable = [[UILabel alloc]init];
    titleLable.text =@"视频连麦Demo";
    titleLable.textColor = [UIColor  whiteColor];
    titleLable.font = [UIFont systemFontOfSize:20];
    [self.view addSubview:titleLable];
    
    UILabel *channelLable = [[UILabel alloc]init];
    channelLable.text =@"连麦频道";
    channelLable.textColor = [UIColor  whiteColor];
    channelLable.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:channelLable];
    
    self.textField = [[UITextField alloc]init];
    self.textField.text = @"ksy24";
    self.textField.textColor = [UIColor whiteColor];
    self.textField.font = [UIFont systemFontOfSize:16];
    self.textField.backgroundColor = UIColorFromRGB(0x2E2E35);
    [self.view addSubview:self.textField];
    
    UIButton *startBtn = [self  getCustomBtn:@"开始连麦"];
    [startBtn addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startBtn];
    
    
    UIButton *configBtn = [self  getCustomBtn:@"参数设置"];
    [configBtn addTarget:self action:@selector(config) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:configBtn];
    
    
    UILabel *explainLable = [[UILabel alloc]init];
    explainLable.text =@"Demo说明";
    explainLable.textColor = [UIColor  whiteColor];
    explainLable.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:explainLable];
    
    
    UIImageView *img = [[UIImageView alloc]init];
    img.image = [UIImage imageNamed:@"Demo说明"];
    [self.view addSubview:img];
    
    
    UIButton *demoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    demoBtn.backgroundColor =[UIColor clearColor];
    [demoBtn addTarget:self action:@selector(explain) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:demoBtn];
    
    
    @KSYWeakObj(self);
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        @KSYStrongObj(self);
        make.top.equalTo(self.view).with.offset(0);
        make.left.equalTo(self.view).with.offset(0);
        make.right.equalTo(self.view).with.offset(0);
        make.height.mas_equalTo(0.42*kDeviceWidth);
    }];
    
    [titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        @KSYStrongObj(self);
        make.bottom.equalTo(imageView.mas_bottom).with.offset(-20);
        make.left.equalTo(self.view).with.offset(140);
        make.right.equalTo(self.view).with.offset(-100);
        
    }];
    
    [channelLable mas_makeConstraints:^(MASConstraintMaker *make) {
        @KSYStrongObj(self);
        make.top.equalTo(imageView.mas_bottom).with.offset(55);
        make.left.equalTo(self.view).with.offset(28);
        make.size.mas_equalTo(CGSizeMake(70, 22));
        
    }];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        @KSYStrongObj(self);
        make.top.equalTo(imageView.mas_bottom).with.offset(43);
        make.left.equalTo(channelLable.mas_right).with.offset(17);
        make.right.equalTo(self.view.mas_right).with.offset(-20);
        make.size.mas_equalTo(CGSizeMake(kDeviceWidth-135, 44));
        
    }];
    [startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        @KSYStrongObj(self);
        make.top.equalTo(self.textField.mas_bottom).with.offset(38);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(200, 44));
        
    }];
    [configBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        @KSYStrongObj(self);
        make.top.equalTo(startBtn.mas_bottom).with.offset(50);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(200, 44));
        
    }];
    [explainLable mas_makeConstraints:^(MASConstraintMaker *make) {
        @KSYStrongObj(self);
        make.top.equalTo(self.view.mas_bottom).with.offset(-30);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(80, 22));
        
    }];
    
    [img mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(explainLable.mas_top).with.offset(0);
        make.right.equalTo(explainLable.mas_left).with.offset(-5);
        make.size.mas_equalTo(CGSizeMake(18, 18));
        
    }];
    
    [demoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(explainLable.mas_top).with.offset(-10);
        make.left.equalTo(img.mas_left).with.offset(0);
        make.right.equalTo(explainLable.mas_right).with.offset(0);
        
    }];
}


- (UIButton *)getCustomBtn:(NSString *)title
{
    UIButton *customBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    customBtn.layer.cornerRadius = 22;
    customBtn.layer.masksToBounds = YES;
    customBtn.backgroundColor =UIColorFromRGB(0x18181D);
    customBtn.layer.borderWidth = 1;
    customBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    [customBtn setTitle:title forState:UIControlStateNormal];
    [customBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    customBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    return customBtn ;
}

- (KSYDemoExplainView *)explainView
{
    if (!_explainView) {
        _explainView = [[KSYDemoExplainView alloc]initWithFrame:self.view.bounds];
        _explainView.hidden = YES;
    }
    return _explainView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

