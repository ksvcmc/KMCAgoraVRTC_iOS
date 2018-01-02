//
//  KSYSliderView.m
//  AgoraVRTCDemo
//
//  Created by yuyang on 2017/11/23.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import "KSYSliderView.h"
#import "Masonry.h"
#import "KSYHeader.h"

@interface KSYSliderView ()
@property (nonatomic,strong)UILabel *titleLable;
@property (nonatomic,strong)UISlider  *slider;
@property (nonatomic,strong)UILabel  *valueLable;
@end
@implementation KSYSliderView

- (instancetype)initTitle:(NSString *)title min:(float )minValue max:(float)maxValue
{
    self = [super init];
    if (!self) return nil;
    
    self.titleLable =[[UILabel alloc]init];
    self.titleLable.textColor= UIColorFromRGB(0xB7B6B6);
    self.titleLable.font = [UIFont  systemFontOfSize:14];
    [self addSubview:self.titleLable];
    self.titleLable.text = title;
    
    self.slider = [[UISlider alloc]init];
   
    self.slider.backgroundColor = [UIColor clearColor];
    self.slider.minimumValue = minValue;
    self.slider.maximumValue = maxValue;
    self.slider.continuous = YES;
    [self addSubview:self.slider];
    [self.slider addTarget:self action:@selector(selectedAction:) forControlEvents:UIControlEventValueChanged];
    [self.slider setMinimumTrackTintColor:[UIColor  whiteColor]];
    [self.slider setMaximumTrackTintColor:[UIColor blackColor]];

    self.valueLable =[[UILabel alloc]init];
    self.valueLable.textColor= [UIColor whiteColor];
    self.valueLable.textColor= UIColorFromRGB(0xB7B6B6);
    self.valueLable.font = [UIFont  systemFontOfSize:12];
    [self addSubview:self.valueLable];

    
    @KSYWeakObj(self);
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        @KSYStrongObj(self);
        make.top.equalTo(self).with.offset(20);
        make.left.equalTo(self).with.offset(28);
        make.height.mas_equalTo(22);
        
    }];
    
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        @KSYStrongObj(self);
        make.top.equalTo(self.titleLable.mas_bottom).with.offset(15);
        make.left.equalTo(self).with.offset(24);
        make.right.equalTo(self).with.offset(-36);
        //make.height.mas_equalTo(30);

    }];

    [self.valueLable mas_makeConstraints:^(MASConstraintMaker *make) {
        @KSYStrongObj(self);
        make.top.equalTo(self.titleLable.mas_bottom).with.offset(15);
        make.left.equalTo(self.slider.mas_right).with.offset(0);
        make.right.equalTo(self).with.offset(5);
        make.height.mas_equalTo(30);

    }];
    
  
    
    return self;
}

-(void)setIndex:(NSInteger )index
{
    if (self.slider) {
        self.slider.value = (float)index;
    }
    [self.slider setValue:index animated:NO];
    self.valueLable.text =[NSString stringWithFormat:@"%ld",index];
}

-(void)selectedAction:(UISlider *)slider{

    if(self.seletedIndex)
    {
        self.seletedIndex((int)slider.value);
    }
    self.valueLable.text =[NSString stringWithFormat:@"%ld",(NSInteger)(self.slider.value)];
    
}

@end
