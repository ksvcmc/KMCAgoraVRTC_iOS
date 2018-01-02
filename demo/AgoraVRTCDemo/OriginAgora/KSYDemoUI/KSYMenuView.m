//
//  KSYMenuView.m
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/6/24.
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import "KSYMenuView.h"

@implementation KSYMenuView

- (instancetype)init{
    self = [super init];
    if (self) {
        _filterBtn = [self addButton:@"美颜"];
        _rtcBtn    = [self addButton:@"Agora连麦"];
        _playBtn    = [self addButton:@"播放"];
        _backBtn   = [self addButton:@"返回菜单"
                              action:@selector(onBack:)];
        _backBtn.hidden = YES;
    }
    
    return self;
}
- (void)layoutUI{
    [super layoutUI];
    [self putRow: @[_filterBtn, _rtcBtn, _playBtn, _backBtn]];
    [self hideAllBtn:NO];
}
- (void)hideAllBtn: (BOOL) bHide {
    _backBtn.hidden   = !bHide; // 返回
    _filterBtn.hidden = bHide;
    _rtcBtn.hidden    = bHide;
    _playBtn.hidden    = bHide;
}
- (IBAction)onBack:(id)sender {
    for (UIView * v in self.subviews){
        v.hidden = YES;
    }
    [self hideAllBtn:NO];
}
@end
