//
//  KSYRtcView.m
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/7/15.
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import "KSYRtcView.h"

@implementation KSYRtcView
- (id)init{
    self = [super init];
    _joinChannelBtn = [self addButton:@"加入"];
    _leaveChannelBtn = [self addButton:@"离开"];
    return self;
}
- (void)layoutUI{
    [super layoutUI];
    [self putRow:@[_joinChannelBtn,_leaveChannelBtn]];
}

@end
