//
//  KSYDefaultParamCenter.h
//  GPUTest
//
//  Created by yuyang on 2017/11/20.
//  Copyright © 2017年 yuyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSYGPUStreamerKit.h"

#define kGobalDefaultParamCenter [KSYDefaultParamCenter sharedInstance]

@interface KSYDefaultParamCenter : NSObject

//推流相关 具体参数 文档 https://github.com/ksvc/KSYLive_iOS/wiki/streamerParams
@property (nonatomic,assign) KSYVideoCodec videoCodec;// 视频编码器
@property (nonatomic, assign) int          videoInitBitrate;
@property (nonatomic, assign) int          videoMaxBitrate;   // kbit/s of video
@property (nonatomic, assign) int          videoMinBitrate;   // 我们推荐streamerBase.videoMinBitrate设置为0，则能更好地发挥码率自适应的效果
@property (nonatomic, assign) int          audioKbps;   // kbit/s of audio
@property (nonatomic,assign)  NSUInteger audioCodec;
@property (nonatomic,assign) int  videoKbps;
// 采集相关
@property (nonatomic, copy)   NSString * capPreset; // 不同设备支持的预设分辨率可能不同, 请尽量与预览分辨率一致
@property (nonatomic, assign) CGSize  previewDimension;//预览分辨率 (仅在开始采集前设置有效)
@property (nonatomic, assign) CGSize  streamDimension;//用户定义的视频 **推流** 分辨率
@property (nonatomic, assign) AVCaptureDevicePosition   cameraPosition;//前后摄像头
@property (nonatomic, assign) int           videoFPS; // 当实际送入的视频帧率过高时会主动丢帧

//推流地址
@property (nonatomic, strong) NSURL  *  hostUrl; // 推流地址


// 记录设置界面一些设置的保存

@property (nonatomic,assign) NSInteger capIndex;
@property (nonatomic,assign) NSInteger streamIndex;
@property (nonatomic,assign) NSInteger videoCodecIndex;
@property (nonatomic,assign) NSInteger audioCodecIndex;
@property (nonatomic,assign) NSInteger audioKbpsIndex;


+ (instancetype)sharedInstance;

@end
