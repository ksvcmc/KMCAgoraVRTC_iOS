//
//  KSYSegmentedControl.m
//  AgoraVRTCDemo
//
//  Created by yuyang on 2017/11/22.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import "KSYSegmentedControl.h"
#import "Masonry.h"
#import "KSYHeader.h"
@interface KSYSegmentedControl ()
@property (nonatomic,strong)UILabel *titleLable;
@property (nonatomic,strong)UISegmentedControl  *segCtl;

@end
@implementation KSYSegmentedControl

- (instancetype)initTitle:(NSString *)title array:(NSArray *)array
{
    self = [super init];
    if (!self) return nil;
    
    self.titleLable =[[UILabel alloc]init];
    self.titleLable.textColor= UIColorFromRGB(0xB7B6B6);
    self.titleLable.font = [UIFont  systemFontOfSize:14];
    [self addSubview:self.titleLable];
    self.titleLable.text = title;
    
    self.segCtl = [[UISegmentedControl alloc]initWithItems:array];
    [self addSubview:self.segCtl];
    
    
    self.segCtl.backgroundColor =UIColorFromRGB(0X16161B);
    self.segCtl.tintColor = [UIColor whiteColor];
    [self.segCtl addTarget:self action:@selector(selectedAction:) forControlEvents:UIControlEventValueChanged];
   
    //    选中的颜色
    [self.segCtl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateSelected];
    //    未选中的颜色
    [self.segCtl setTitleTextAttributes:@{NSForegroundColorAttributeName: UIColorFromRGB(0XB7B6B6)} forState:UIControlStateNormal];
    
    @KSYWeakObj(self);
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        @KSYStrongObj(self);
        make.top.equalTo(self).with.offset(20);
        make.left.equalTo(self).with.offset(28);
        make.height.mas_equalTo(22);
        
    }];
    
    [self.segCtl mas_makeConstraints:^(MASConstraintMaker *make) {
        @KSYStrongObj(self);
        make.top.equalTo(self.titleLable.mas_bottom).with.offset(15);
        make.left.equalTo(self).with.offset(24);
        make.right.equalTo(self).with.offset(-24);
        make.height.mas_equalTo(30);
        
    }];
    
    return self;
}

-(void)setIndex:(NSInteger )index
{
    if (self.segCtl) {
        self.segCtl.selectedSegmentIndex = index;
    }
}

-(void)selectedAction:(UISegmentedControl *)Seg{
    NSInteger index = Seg.selectedSegmentIndex;
    if(self.seletedIndex)
    {
        self.seletedIndex(index);
    }
    
}



@end
