//
//  KSYDefaultParamCenter.m
//  GPUTest
//
//  Created by yuyang on 2017/11/20.
//  Copyright © 2017年 yuyang. All rights reserved.
//

#import "KSYDefaultParamCenter.h"
#import "KSYStaticData.h"

@implementation KSYDefaultParamCenter


+ (instancetype)sharedInstance
{
    static KSYDefaultParamCenter * _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
    });
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;
    [self defaultConfig];
    return self;
}

- (void)defaultConfig
{
    _videoFPS = 15;
    _videoCodec = KSYVideoCodec_AUTO;
    _capPreset = [KSYStaticData getCapPix:0];
    _previewDimension = CGSizeMake(640, 360);
    _streamDimension =CGSizeMake(640, 360);
    _videoInitBitrate =  800;
    _videoMaxBitrate  = 1000;
    _videoMinBitrate  =    0;
    _audioKbps        =   48;
    _videoKbps = 800;

    _capIndex = 0;
    _streamIndex = 0;
    _videoCodecIndex = 2;
    _audioCodecIndex = 0;
    _audioKbpsIndex = 3;
    
}






@end
