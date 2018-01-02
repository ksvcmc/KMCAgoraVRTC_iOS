//
//  KSYMutiAgoraStreamerKit.h
//  AgoraVRTCDemo
//
//  Created by yuyang on 2017/11/24.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <libksygpulive/KSYGPUStreamerKit.h>

@interface KSYAgoraPicModel : NSObject

@property (nonatomic,assign)NSInteger  layerIndex;
@property (nonatomic,assign)BOOL  isClear;
@property (nonatomic,strong)KSYGPUPicInput *input;

@end


@class KMCAgoraVRTC;
@protocol KMCRtcDelegate;
@interface KSYMultiAgoraStreamerKit : KSYGPUStreamerKit

/**
 @abstract 初始化方法
 @discussion 创建带有默认参数的 kit
 
 @warning kit只支持单实例推流，构造多个实例会出现异常
 */
- (instancetype) initWithDefaultCfg:(id<KMCRtcDelegate>)delegate token:(NSString *)token;

#pragma 声网sdk相关
/**
 @abstract rtc接口类
 */
@property (nonatomic, strong) KMCAgoraVRTC * agoraKit;
/*
 @abstract 加入channel回调
 */
@property (nonatomic, copy)void (^onChannelJoin)();
/*
 @abstract 离开channel回调
 */
@property(nonatomic, copy) void(^leaveChannelBlock)();
/*
 @abstract 加入通道
 */
-(void)joinChannel:(NSString *)channelName;
/*
 @abstract 离开通道
 */
-(void)leaveChannel;

// 加入多人连麦
- (void)addItemId:(NSUInteger)itemId;
/*
 @abstract 删除itemId 并更新图层
 */
- (void)removeItemId:(NSInteger)ItemId;
/*
 @abstract 开始连麦view
 */
- (void)startRtcView;
/*
 @abstract 停止连麦view
 */
- (void)stopRTCView;

#pragma mark  1v1 interface

/*
 @abstract 相机采集自己的大小， 只有enablePK 为YES会生效
 */
@property (nonatomic, readwrite) CGRect  camRect;
/*
 @abstract 1v1 pk 对方窗口的大小只, 有enablePK 为YES会生效
 */
@property (nonatomic, readwrite) CGRect  otherRemoteRect;
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

/*
 @abstract enablePK YES 为 打开1v1 pk 模式  NO 关闭
 */
@property (nonatomic,assign) BOOL enablePK;
/*
 @abstract 当前连麦的频道人数  YES  至少有一个人进入， No 只有自己。
 */
- (BOOL)currentChannelHavePerson;
/*
 @abstract 当前频道人数回调、
 */
@property(nonatomic, copy) void(^currentNumBlock)(NSInteger personNum);


/*
 @abstract enableSwitch 默认为NO YES 为自己采集图像在后面， No 对方采集图像在后面
 */
@property (nonatomic,assign) BOOL enableSwitch;


#pragma mark  水印 interface

/*
 @abstract 用户水印图层
 */
@property (nonatomic, readwrite) NSInteger  waterViewLayer;
/*
 @abstract 用户水印图层的大小
 */
@property (nonatomic, readwrite) CGRect waterViewRect;
/*
 @abstract 水印图层母类，可往里addview
 */
@property (nonatomic, readwrite)UIView * waterView;
/*
 @abstract YES 开始使用水印 No 停止使用水印 使用之前需要设置 waterViewRect waterViewLayer
 */
@property (nonatomic,assign) BOOL enableWater;


@end
