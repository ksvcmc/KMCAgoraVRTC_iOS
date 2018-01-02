//
//  KSYMenu.h
//  AgoraVRTCDemo
//
//  Created by yuyang on 2017/11/27.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSYMenu : UIView

// yes  打开 ，no 关闭

@property (nonatomic,copy) void(^clickSelectScreenBlock)(BOOL isOpen);
@property (nonatomic,copy) void(^clickInfoBlock)(BOOL isOpen);
@property (nonatomic,copy) void(^clickPlayBlock)(BOOL isOpen);
@property (nonatomic,copy) void(^clickMuteBlock)(BOOL isOpen);
@property (nonatomic,copy) void(^clickCameraBlock)(BOOL isOpen);

// YES  隐藏 ，NO 为显示
- (void)hidden1V1Btn:(BOOL) isHidden;


@end
