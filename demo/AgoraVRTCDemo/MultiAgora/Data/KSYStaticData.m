//
//  KSYStaticData.m
//  AgoraVRTCDemo
//
//  Created by yuyang on 2017/11/22.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import "KSYStaticData.h"
#import  <AVFoundation/AVFoundation.h>


@implementation KSYConfig

@end

@implementation KSYStaticData

+ (NSString*) getCapPix:(NSInteger) index
{
    switch ( index) {
        case 0:
            return  AVCaptureSessionPreset640x480;
        case 1:
            return  AVCaptureSessionPresetiFrame960x540;
        case 2:
            return  AVCaptureSessionPreset1280x720;
        case 3:
            return  AVCaptureSessionPreset640x480;
        default:
            return  AVCaptureSessionPreset640x480;
    }
}

+ (CGSize) getStreamerDimensionToSize:(NSInteger)idx{
    switch (idx) {
        case 0:
            return  CGSizeMake(640, 360);
        case 1:
            return  CGSizeMake(960, 540);
        case 2:
            return  CGSizeMake(1280, 720);
        case 3:
            return  CGSizeMake(640, 480);
        default:
            return  CGSizeMake(400, 400);
    }
}

+ (KSYVideoCodec) videoCodecIndex:(NSInteger )idx {
    switch (idx) {
        case 0:
            return  KSYVideoCodec_AUTO;
        case 1:
            return  KSYVideoCodec_X264;
        case 2:
            return  KSYVideoCodec_VT264;
        case 3:
            return  KSYVideoCodec_QY265;
        default:
            return  KSYVideoCodec_AUTO;
    }
}

+ (KSYAudioCodec) audioCodec:(NSInteger )idx {
    switch (idx) {
        case 0:
            return  KSYAudioCodec_AAC_HE;
        case 1:
            return  KSYAudioCodec_AAC;
        case 2:
            return  KSYAudioCodec_AT_AAC;
        case 3:
            return  KSYAudioCodec_AAC_HE_V2;
            
        default:
            return  KSYAudioCodec_AAC_HE;
    }
}

+ (int) audioKbps:(NSInteger )idx {
    NSArray *array=@[@"12",@"24",@"32", @"48", @"64", @"128"];
    if (idx>=array.count) {
         return 32;
    }
    int aKbps = [[array objectAtIndex:idx] intValue];
    return aKbps;
}


@end
