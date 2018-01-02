//
//  KSYDemoExplainView.m
//  AgoraVRTCDemo
//
//  Created by yuyang on 2017/11/22.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import "KSYDemoExplainView.h"
#import "KSYHeader.h"
#import "Masonry.h"

@interface KSYDemoExplainView ()

@end
@implementation KSYDemoExplainView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    [self setup];
    return self;
    
}

- (void)setup
{
    UIView *backView =[[UIView alloc]initWithFrame:CGRectMake(0, 0,kDeviceWidth , kDeviceHeight)];
    backView.backgroundColor = [UIColor blackColor];
    backView.alpha = 0.5;
    [self addSubview:backView];
    
    UIView *sBgView = [[UIView alloc]init];
    sBgView.backgroundColor = UIColorFromRGB(0x27272C);
    sBgView.layer.cornerRadius = 10;
    [self addSubview:sBgView];
    
    NSString *string = @"视频连麦，由声网提供。此技术可运用在金山直播SDK，其他SDK要根据其开放性决定。\n声网1对1视频直播连麦产品，是全球首个基于UDP的直播连麦SDK，声网在全球部署了近100个数据中心，通过智能路由算法保证全球跨国、跨网的稳定低延时互动。\n\n若想进一步了解，请联系我们\n邮件：KSC-VBU-KMC@kingsoft.com";
    UITextView *textView = [[UITextView alloc]init];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 4;// 字体的行间距
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:16],
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    textView.attributedText = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    textView.backgroundColor = [UIColor clearColor];
    textView.textColor = [UIColor whiteColor];
    [sBgView addSubview:textView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"关闭"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    
    [sBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(330, 344));
        make.center.mas_equalTo(self);
        
    }];
    
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(310, 286));
        make.center.mas_equalTo(sBgView);
    }];
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(sBgView.mas_right).with.offset(20);
        make.bottom.equalTo(sBgView.mas_top).with.offset(20);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
  
}

- (void)close
{
   self.hidden = YES;
}


@end
