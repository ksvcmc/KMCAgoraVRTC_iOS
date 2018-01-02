//
//  KSYSliderView.h
//  AgoraVRTCDemo
//
//  Created by yuyang on 2017/11/23.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSYSliderView : UIView
@property (nonatomic,copy)void (^seletedIndex)(NSInteger index);

- (instancetype)initTitle:(NSString *)title min:(float )minValue max:(float)maxValue;

-(void)setIndex:(NSInteger )index;
@end
