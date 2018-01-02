//
//  KSYStaticData.h
//  AgoraVRTCDemo
//
//  Created by yuyang on 2017/11/22.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KSYGPUStreamerKit.h"



@interface KSYConfig : NSObject
@property (nonatomic,copy) NSString *capPix;
@property (nonatomic,assign) CGSize streamerSize;
@property (nonatomic,assign) NSUInteger videoCodec;
@property (nonatomic,assign) NSUInteger audioCodec;
@property (nonatomic,assign) int  videoFPS;
@property (nonatomic,assign) int  audioKbps;
@property (nonatomic,assign) int  videoKbps;

@property (nonatomic,assign) NSInteger capIndex;
@property (nonatomic,assign) NSInteger streamIndex;
@property (nonatomic,assign) NSInteger videoCodecIndex;
@property (nonatomic,assign) NSInteger audioCodecIndex;
@property (nonatomic,assign) NSInteger audioKbpsIndex;

@end

@interface KSYStaticData : NSObject

//采集分辨率
+ (NSString*) getCapPix:(NSInteger) index;

//推流分辨率
+ (CGSize) getStreamerDimensionToSize:(NSInteger)idx;

//视频编码
+ (KSYVideoCodec) videoCodecIndex:(NSInteger )idx;

//音频编码
+ (KSYAudioCodec) audioCodec:(NSInteger )idx;

//音频kps
+ (int) audioKbps:(NSInteger )idx ;

@end
