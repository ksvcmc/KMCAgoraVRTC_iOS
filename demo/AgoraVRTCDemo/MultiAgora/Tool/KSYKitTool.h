//
//  KSYKitTool.h
//  GPUTest
//
//  Created by yuyang on 2017/11/17.
//  Copyright © 2017年 yuyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KSYGPUStreamerKit.h"
#import "KSYGPUPicMixer.h"
#import <KMCAgoraVRTC/AgoraRtcEngineKit.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface KSYKitTool : NSObject

// 居中裁剪
+(CGRect) calcCropRect: (CGSize) camSz to: (CGSize) outSz;

// 对 inSize 按照 targetSz的宽高比 进行裁剪, 得到最大的输出size
+ (CGSize) calcCropSize: (CGSize) inSz to: (CGSize) targetSz;


+(void) setMixerMasterLayer:(NSInteger)idx
                        kit:(KSYGPUStreamerKit *)kit;

+ (void) addInput:(GPUImageOutput*)pic
        ToMixerAt:(NSInteger)idx
             Rect:(CGRect)rect
              kit:(KSYGPUStreamerKit *)kit;

+ (void) addInput:(GPUImageOutput*)pic
        ToMixerAt:(NSInteger)idx
              kit:(KSYGPUStreamerKit *)kit;

+ (void) clearMixerLayer:(NSInteger)idx
                     kit:(KSYGPUStreamerKit *)kit;
+ (NSString *) getUuid;

+(CGSize) adjustVideoProfile:(AgoraRtcVideoProfile )videoProfile;

+ (void)showAlterView:(UIView *)view  message:(NSString *)message;

@end
