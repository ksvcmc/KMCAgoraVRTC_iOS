//
//  KSYSegmentedControl.h
//  AgoraVRTCDemo
//
//  Created by yuyang on 2017/11/22.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSYSegmentedControl : UIView

@property (nonatomic,copy)void (^seletedIndex)(NSInteger index);

- (instancetype)initTitle:(NSString *)title array:(NSArray *)array;

-(void)setIndex:(NSInteger )index;


@end
