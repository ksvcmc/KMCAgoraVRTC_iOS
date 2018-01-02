//
//  KSYPlayView.m
//  KSYGPUStreamerDemo
//
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import "KSYPlayView.h"

@interface KSYPlayView() <UITextFieldDelegate>

@end

@implementation KSYPlayView
- (id)init{
    self = [super init];
    _labelHostUrl = [self addLable:@"播放地址"];
    _textHostUrl = [self addTextField:@"rtmp://live.hkstv.hk.lxdns.com/live/hks"];
    _textHostUrl.returnKeyType = UIReturnKeyDone;
    _textHostUrl.delegate = self;
    
    _playBtn    = [self addButton:@"播放"];
    _pauseBtn   = [self addButton:@"暂停"];
    _stopBtn    = [self addButton:@"停止"];

    return self;
}
- (void)layoutUI{
    [super layoutUI];
    [self putLable:_labelHostUrl andView:_textHostUrl];
    [self putRow:@[_playBtn,_pauseBtn,_stopBtn]];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.returnKeyType == UIReturnKeyDone) {
        [textField resignFirstResponder];
    }
    return YES;
}

@end
