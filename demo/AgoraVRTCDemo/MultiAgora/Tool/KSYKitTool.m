//
//  KSYKitTool.m
//  GPUTest
//
//  Created by yuyang on 2017/11/17.
//  Copyright © 2017年 yuyang. All rights reserved.
//

#import "KSYKitTool.h"

@implementation KSYKitTool



+(CGRect) calcCropRect: (CGSize) camSz to: (CGSize) outSz {
    double x = (camSz.width  -outSz.width )/2/camSz.width;
    double y = (camSz.height -outSz.height)/2/camSz.height;
    double wdt = outSz.width/camSz.width;
    double hgt = outSz.height/camSz.height;
    return CGRectMake(x, y, wdt, hgt);
}

+ (CGSize) calcCropSize: (CGSize) inSz to: (CGSize) targetSz {
    CGFloat preRatio = targetSz.width / targetSz.height;
    CGSize cropSz = inSz; // set width
    cropSz.height = cropSz.width / preRatio;
    if (cropSz.height > inSz.height){
        cropSz.height = inSz.height; // set height
        cropSz.width  = cropSz.height * preRatio;
    }
    return cropSz;
}


+(void) setMixerMasterLayer:(NSInteger)idx
                        kit:(KSYGPUStreamerKit *)kit
{
    KSYGPUPicMixer * vMixer[2] = {kit.vPreviewMixer, kit.vStreamMixer};
    for (int i = 0; i<2; ++i) {
        [vMixer[i]  setMasterLayer:idx];
    }
}

+ (void) addInput:(GPUImageOutput*)pic
        ToMixerAt:(NSInteger)idx
             Rect:(CGRect)rect
              kit:(KSYGPUStreamerKit *)kit{
    
    [self addInput:pic ToMixerAt:idx kit:kit];
    KSYGPUPicMixer * vMixer[2] = {kit.vPreviewMixer, kit.vStreamMixer};
    for (int i = 0; i<2; ++i) {
        [vMixer[i] setPicRect:rect ofLayer:idx];
        [vMixer[i] setPicAlpha:1.0f ofLayer:idx];
    }
}

+ (void) addInput:(GPUImageOutput*)pic
        ToMixerAt:(NSInteger)idx
               kit:(KSYGPUStreamerKit *)kit{
    if (pic == nil){
        return;
    }
    [pic removeAllTargets];
    KSYGPUPicMixer * vMixer[2] = {kit.vPreviewMixer, kit.vStreamMixer};
    for (int i = 0; i<2; ++i) {
        [vMixer[i]  clearPicOfLayer:idx];
        [pic addTarget:vMixer[i] atTextureLocation:idx];
    }
}

+ (void) clearMixerLayer:(NSInteger)idx
                    kit:(KSYGPUStreamerKit *)kit{
    KSYGPUPicMixer * vMixer[2] = {kit.vPreviewMixer, kit.vStreamMixer};
    for (int i = 0; i<2; ++i) {
        [vMixer[i]  clearPicOfLayer:idx];
    }
}

+ (NSString *) getUuid{
    return [[[[UIDevice currentDevice] identifierForVendor] UUIDString] lowercaseString];
}

+(CGSize) adjustVideoProfile:(AgoraRtcVideoProfile )videoProfile
{
    CGSize videoSize;
    switch(videoProfile){
        case AgoraRtc_VideoProfile_120P:
            videoSize=CGSizeMake(120, 160);
            break;
        case AgoraRtc_VideoProfile_120P_3:
            videoSize=CGSizeMake(120, 120);
            break;
        case AgoraRtc_VideoProfile_180P:        // 320x180   15   140
            videoSize=CGSizeMake(180, 320);
            break;
        case AgoraRtc_VideoProfile_180P_3:        // 180x180   15   100
            videoSize=CGSizeMake(180, 180);
            break;
        case AgoraRtc_VideoProfile_180P_4:        // 240x180   15   120
            videoSize=CGSizeMake(180, 240);
            break;
        case AgoraRtc_VideoProfile_240P:        // 320x240   15   200
            videoSize=CGSizeMake(240, 320);
            break;
        case AgoraRtc_VideoProfile_240P_3:        // 240x240   15   140
            videoSize=CGSizeMake(240, 240);
            break;
        case AgoraRtc_VideoProfile_240P_4:      // 424x240   15   220
            videoSize=CGSizeMake(240, 424);
            break;
        case AgoraRtc_VideoProfile_360P:
        AgoraRtc_VideoProfile_DEFAULT:// 640x360   15   400
            videoSize=CGSizeMake(360, 640);
            break;
        case AgoraRtc_VideoProfile_360P_3:    // 360x360   15   260
            videoSize=CGSizeMake(360, 360);
            break;
        case AgoraRtc_VideoProfile_360P_4:        // 640x360   30   600
            videoSize=CGSizeMake(360, 640);
            break;
        case AgoraRtc_VideoProfile_360P_6:        // 360x360   30   400
            videoSize=CGSizeMake(360, 360);
            break;
        case AgoraRtc_VideoProfile_360P_7:
        case AgoraRtc_VideoProfile_360P_8:      // 480x360   30   490
            videoSize=CGSizeMake(360, 480);
            break;
        case AgoraRtc_VideoProfile_360P_9:      // 640x360   15   800
        case AgoraRtc_VideoProfile_360P_10:     // 640x360   24   800
        case AgoraRtc_VideoProfile_360P_11:   // 640x360   24   1000
            videoSize=CGSizeMake(360, 640);
            break;
        case AgoraRtc_VideoProfile_480P:            // 640x480   15   500
        case AgoraRtc_VideoProfile_480P_4:
            videoSize=CGSizeMake(480, 640);
            break;
        case AgoraRtc_VideoProfile_480P_3:        // 480x480   15   400
        case AgoraRtc_VideoProfile_480P_6:        // 480x480   30   600
            videoSize=CGSizeMake(480, 480);
            break;
        case AgoraRtc_VideoProfile_480P_8:        // 848x480   15   610
        case AgoraRtc_VideoProfile_480P_9:        // 848x480   30   930
            videoSize=CGSizeMake(480, 848);
            break;
        case AgoraRtc_VideoProfile_720P:        // 1280x720  15   1130
        case AgoraRtc_VideoProfile_720P_3:        // 1280x720  30   1710
            videoSize=CGSizeMake(720,1280);
            break;
        case AgoraRtc_VideoProfile_720P_5:        // 960x720   15   910
        case AgoraRtc_VideoProfile_720P_6:        // 960x720   30   1380
            videoSize=CGSizeMake(720,960);
            break;
        case AgoraRtc_VideoProfile_1080P:    // 1920x1080 15   2080
        case AgoraRtc_VideoProfile_1080P_3:        // 1920x1080 30   3150
        case AgoraRtc_VideoProfile_1080P_5:        // 1920x1080 60   4780
            videoSize=CGSizeMake(1080,1920);
            break;
        case AgoraRtc_VideoProfile_1440P:        // 2560x1440 30   4850
        case AgoraRtc_VideoProfile_1440P_2:        // 2560x1440 60   7350
            videoSize=CGSizeMake(1440,2560);
            break;
        case AgoraRtc_VideoProfile_4K:            // 3840x2160 30   8190
        case AgoraRtc_VideoProfile_4K_3:        // 3840x2160 60   13500
            videoSize=CGSizeMake(2160,3840);
            break;
        default:
            videoSize=CGSizeMake(360, 640);
            break;
    }
    
    return videoSize;
}

+ (void)showAlterView:(UIView *)view  message:(NSString *)message
{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.mode =MBProgressHUDModeText;
        hud.label.text =message;
        [hud hideAnimated:YES afterDelay:2];
}



@end
