//
//  KSYPlayViewController.h
//  AgoraVRTCDemo
//
//  Created by yuyang on 2017/11/22.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSYPlayViewController : UIViewController

@property (nonatomic,copy)void(^leaveBlock_t)();

- (instancetype)initWithChannelId:(NSString *)channelId;

@end
