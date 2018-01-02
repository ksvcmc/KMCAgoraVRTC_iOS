//
//  KSYMenu.m
//  AgoraVRTCDemo
//
//  Created by yuyang on 2017/11/27.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import "KSYMenu.h"
#import "KSYHeader.h"
#import "Masonry.h"

#define kItemSize 44
#define kItemMargn  20

@interface KSYMenu ()
@property (nonatomic,strong)UIButton *selectScreenBtn;
@property (nonatomic,strong)UIButton *infoBtn;
@property (nonatomic,strong)UIButton *playBtn;
@property (nonatomic,strong)UIButton *muteBtn;
@property (nonatomic,strong)UIButton *cameraPositionBtn;
@property (nonatomic,strong)UIButton *moreBtn;

@property (nonatomic,assign)BOOL isSelectScreenClick;
@property (nonatomic,assign)BOOL isMoreClick;
@property (nonatomic,assign)BOOL isInfoClick;
@property (nonatomic,assign)BOOL isPlayClick;
@property (nonatomic,assign)BOOL isMuteClick;
@property (nonatomic,assign)BOOL isCameraClick;


@end
@implementation KSYMenu

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(!self) return nil;
    self.isMoreClick = NO;
    self.isSelectScreenClick = YES;
    [self setup];
    return self;
    
}

- (void)hidden1V1Btn:(BOOL) isHidden
{
   self.selectScreenBtn.hidden = isHidden;
   if (isHidden) {
      [self.selectScreenBtn setImage:[UIImage imageNamed:@"画中画"] forState:UIControlStateNormal];
   }
}

- (void)selectScreenAction:(UIButton *)btn
{
    if(self.isSelectScreenClick)
    {
        [self.selectScreenBtn setImage:[UIImage imageNamed:@"分屏"] forState:UIControlStateNormal];
    }
    else
    {
        [self.selectScreenBtn setImage:[UIImage imageNamed:@"画中画"] forState:UIControlStateNormal];
    }
    if(self.clickSelectScreenBlock)
    {
        self.clickSelectScreenBlock(self.isSelectScreenClick);
    }
    self.isSelectScreenClick = !self.isSelectScreenClick;
}

- (void)infoAction:(UIButton *)btn
{
    if(self.isInfoClick)
    {
        [self.infoBtn setImage:[UIImage imageNamed:@"显示信息"] forState:UIControlStateNormal];
    }
    else
    {
        [self.infoBtn setImage:[UIImage imageNamed:@"关闭信息"] forState:UIControlStateNormal];
    }
    if(self.clickInfoBlock)
    {
        self.clickInfoBlock(self.isInfoClick);
    }
    
    self.isInfoClick = !self.isInfoClick;
}

- (void)playAction:(UIButton *)btn
{
    if(self.isPlayClick)
    {
        [self.playBtn setImage:[UIImage imageNamed:@"开始推流"] forState:UIControlStateNormal];
    }
    else
    {
        [self.playBtn setImage:[UIImage imageNamed:@"暂停推流"] forState:UIControlStateNormal];
    }
    if(self.clickPlayBlock)
    {
        self.clickPlayBlock(self.isPlayClick);
    }
    self.isPlayClick = !self.isPlayClick;
}

- (void)muteAction:(UIButton *)btn
{
    if(self.isMuteClick)
    {
        [self.muteBtn setImage:[UIImage imageNamed:@"开启麦克风"] forState:UIControlStateNormal];
    }
    else
    {
        [self.muteBtn setImage:[UIImage imageNamed:@"关闭麦克风"] forState:UIControlStateNormal];
    }
    if(self.clickMuteBlock)
    {
        self.clickMuteBlock(self.isMuteClick);
    }
    self.isMuteClick = !self.isMuteClick;
}

- (void)cameraAction:(UIButton *)btn
{
    if(self.isCameraClick)
    {
        [self.cameraPositionBtn setImage:[UIImage imageNamed:@"相机翻转"] forState:UIControlStateNormal];
    }
    else
    {
        [self.cameraPositionBtn setImage:[UIImage imageNamed:@"相机翻转"] forState:UIControlStateNormal];
    }
    if(self.clickCameraBlock)
    {
        self.clickCameraBlock(self.isCameraClick);
    }
    self.isCameraClick =!self.isCameraClick;
}

- (void)moreAction:(UIButton *)btn
{
   
    if(self.isMoreClick)
    {
        [UIView animateWithDuration:0.3 animations:^{
            
           [self hiddenBtn:YES];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3 animations:^{
            
            [self hiddenBtn:NO];
        }];
    }
    self.isMoreClick = !self.isMoreClick;
    
    
}

- (void)hiddenBtn:(BOOL) isHidden
{
    self.infoBtn.hidden = isHidden;
    self.playBtn.hidden = isHidden;
    self.muteBtn.hidden = isHidden;
    self.cameraPositionBtn.hidden = isHidden;

}

- (void)setup
{
    
    self.selectScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.selectScreenBtn setImage:[UIImage imageNamed:@"画中画"] forState:UIControlStateNormal];
    [self.selectScreenBtn addTarget:self action:@selector(selectScreenAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.selectScreenBtn];
    self.selectScreenBtn.hidden = YES;
    
    self.infoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.infoBtn setImage:[UIImage imageNamed:@"显示信息"] forState:UIControlStateNormal];
    [self.infoBtn addTarget:self action:@selector(infoAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.infoBtn];

    
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playBtn setImage:[UIImage imageNamed:@"开始推流"] forState:UIControlStateNormal];
    [self.playBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.playBtn];
    
    self.muteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.muteBtn setImage:[UIImage imageNamed:@"开启麦克风"] forState:UIControlStateNormal];
    [self.muteBtn addTarget:self action:@selector(muteAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.muteBtn];
    
    self.cameraPositionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cameraPositionBtn setImage:[UIImage imageNamed:@"相机翻转"] forState:UIControlStateNormal];
    [self.cameraPositionBtn addTarget:self action:@selector(cameraAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cameraPositionBtn];
    
    self.moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.moreBtn setImage:[UIImage imageNamed:@"更多"] forState:UIControlStateNormal];
    [self.moreBtn addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.moreBtn];
    
    
    @KSYWeakObj(self);
    
    [self.selectScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        @KSYStrongObj(self);
        make.top.equalTo(self).with.offset(0);
        make.left.equalTo(self).with.offset(0);
        make.size.mas_equalTo(CGSizeMake(kItemSize, kItemSize));
        
    }];
    
    [self.infoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        @KSYStrongObj(self);
        make.top.equalTo(self.selectScreenBtn.mas_bottom).with.offset(20);
        make.left.equalTo(self).with.offset(0);
        make.size.mas_equalTo(CGSizeMake(kItemSize, kItemSize));
        
    }];
    
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        @KSYStrongObj(self);
        make.top.equalTo(self.infoBtn.mas_bottom).with.offset(20);
        make.left.equalTo(self).with.offset(0);
        make.size.mas_equalTo(CGSizeMake(kItemSize, kItemSize));
        
    }];
    
    [self.muteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        @KSYStrongObj(self);
        make.top.equalTo(self.playBtn.mas_bottom).with.offset(20);
        make.left.equalTo(self).with.offset(0);
        make.size.mas_equalTo(CGSizeMake(kItemSize, kItemSize));
        
    }];
    
    [self.cameraPositionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        @KSYStrongObj(self);
        make.top.equalTo(self.muteBtn.mas_bottom).with.offset(20);
        make.left.equalTo(self).with.offset(0);
        make.size.mas_equalTo(CGSizeMake(kItemSize, kItemSize));
        
    }];
    
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        @KSYStrongObj(self);
        make.top.equalTo(self.cameraPositionBtn.mas_bottom).with.offset(20);
        make.left.equalTo(self).with.offset(0);
        make.size.mas_equalTo(CGSizeMake(kItemSize, kItemSize));
        
    }];
     
     [self hiddenBtn:YES];
    
}




@end
