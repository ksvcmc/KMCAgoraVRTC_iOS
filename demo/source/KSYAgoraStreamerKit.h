#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <libksygpulive/KSYGPUStreamerKit.h>


@class KMCAgoraVRTC;
@protocol KMCRtcDelegate;

@interface KSYAgoraStreamerKit: KSYGPUStreamerKit
/**
 @abstract 初始化方法
 @discussion 创建带有默认参数的 kit
 
 @warning kit只支持单实例推流，构造多个实例会出现异常
 */
- (instancetype) initWithDefaultCfg:(id<KMCRtcDelegate>)delegate;
#pragma 声网sdk相关
/**
 @abstract rtc接口类
 */
@property (nonatomic, strong) KMCAgoraVRTC * agoraKit;
/*
 @abstract start call的回调函数
 */
@property (nonatomic, copy)void (^onCallStart)(int status);
/*
 @abstract stop call的回调函数
 */
@property (nonatomic, copy)void (^onCallStop)(int status);
/*
 @abstract 加入channel回调
 */
@property (nonatomic, copy)void (^onChannelJoin)(int status);
/*
 @abstract 呼叫开始
 */
@property (nonatomic, readwrite) BOOL callstarted;
/*
 @abstract 加入通道
 */
-(void)joinChannel:(NSString *)channelName;
/*
 @abstract 离开通道
 */
-(void)leaveChannel;
/**
 @abstract 播放器
 */
@property (nonatomic, readonly) KSYMoviePlayerController * _Nonnull player;
/**
 @abstract 播放视频数据
 */
@property (nonatomic, readonly)KSYGPUPicInput         * _Nonnull playerYuvInput;
/**
 @abstract   开启播放器
 @param playerUrl:播放视频的url
 */
-(void)startPlayerWithUrl:( NSURL* _Nullable )playerUrl;
/**
 @abstract 关闭播放器
 */
-(void)stopPlayer;
#pragma 窗口相关配置
/*
 @abstract 播放窗口图层
 */
@property (nonatomic, readwrite) NSInteger playerLayer;
/**
 @abstract 播放音轨
 */
@property (nonatomic, readwrite) int playerTrack;
/**
 @abstract 播放窗口图层的大小
 */
@property (nonatomic, readwrite) CGRect playerRect;
/*
 @abstract 小窗口图层
 */
@property (nonatomic, readwrite) NSInteger rtcLayer;
/**
 @abstract 小窗口图层的大小
 */
@property (nonatomic, readwrite) CGRect winRect;

/**
 @abstract 主播图层的大小
 */
@property (nonatomic, readwrite) CGRect camRect;
/*
 @abstract 用户自定义图层
 */
@property (nonatomic, readwrite) NSInteger customViewLayer;
/*
 @abstract 用户自定义图层的大小
 */
@property (nonatomic, readwrite) CGRect customViewRect;
/*
 @abstract 自定义图层母类，可往里addview
 */
@property (nonatomic, readwrite)UIView * contentView;
/**
 @abstract 主窗口和小窗口切换
 */
@property (nonatomic, readwrite) BOOL selfInFront;
/**
 @abstract 圆角的图片
 */
@property GPUImagePicture *  maskPicture;
#pragma 美颜相关
/*
 @abstract 美颜滤镜
 */
@property GPUImageOutput<GPUImageInput>* curfilter;
/**
 @abstract 加入rtc窗口滤镜
 */
- (void) setupRtcFilter:(GPUImageOutput<GPUImageInput> *) filter;

/**
 * 该方法调节录音信号音量
 * @param volume 录音信号音量可在 0~400 范围内进行调节:
 *               0: 静音
 *               100: 原始音量
 *               400: 最大可为原始音量的 4 倍(自带溢出保护)
 * @return 0: 方法调用成功, <0: 方法调用失败
 */
- (int)adjustRecordingSignalVolume:(NSInteger)volume;

/**
 * 该方法调节播放信号音量
 * @param volume 播放信号音量可在 0~400 范围内进行调节:
 *               0: 静音
 *               100: 原始音量
 *               400: 最大可为原始音量的 4 倍(自带溢出保护)
 * @return 0: 方法调用成功, <0: 方法调用失败
 */
- (int)adjustPlaybackSignalVolume:(NSInteger)volume;
@end

