//
//  KMCAgoraVRTC.h
//  demo
//
//  Created by 张俊 on 05/07/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "KMCDefines.h"
#import "AgoraRtcEngineKit.h"

@protocol KMCRtcDelegate <AgoraRtcEngineDelegate>

/**
    金山魔方鉴权成功, 鉴权成功后才能开始之后的操作，比如joinChannel
 */
- (void)authSuccess:(id)sender;

/**
 鉴权失败
 
 @param iErrorCode 错误码
 */
- (void)authFailure:(AuthorizeError)iErrorCode;

@end


@class AgoraRtcStats;

typedef void (^RTCVideoDataBlock)(CVPixelBufferRef pixelBuffer);
typedef void (^RTCAudioDataBlock)(void* buffer,int sampleRate,int samples,int bytesPerSample,int channels,int64_t pts);


@interface KMCAgoraVRTC:NSObject

-(instancetype)initWithToken:(NSString *)token
                    delegate:(id<KMCRtcDelegate>)delegate;

/*
 @abstract 是否静音
 */
@property (assign, nonatomic) BOOL isMuted;
/*
 @abstract 设置视频的profile，具体参看声网的定义
 */
@property (assign, nonatomic) AgoraRtcVideoProfile videoProfile;
/*
 @abstract 加入通道
 */
-(void)joinChannel:(NSString *)channelName uid:(NSUInteger)uid;


@property(nonatomic, copy) void(^joinChannelBlock)(NSString* channel, NSUInteger uid, NSInteger elapsed);
/*
 @abstract 离开通道
 */
-(void)leaveChannel;

@property(nonatomic, copy) void(^leaveChannelBlock)(AgoraRtcStats* stat);
/*
 @abstract 发送视频数据到云端
 */
-(void)ProcessVideo:(CVPixelBufferRef)buf
           timeInfo:(CMTime)pts;

/*
 @abstract 远端视频数据回调
 */
@property (nonatomic, copy)RTCVideoDataBlock videoDataCallback;

/*
 @abstract 远端音频数据回调
 */
@property (nonatomic, copy)RTCAudioDataBlock remoteAudioDataCallback;

/*
 @abstract 本地音频数据回调
 */
@property (nonatomic, copy)RTCAudioDataBlock localAudioDataCallback;

@end
