# 金山云魔方连麦API文档

[![Apps Using](https://img.shields.io/cocoapods/at/KMCAgoraVRTC.svg?label=Apps%20Using%20KMCAgoraVRTC&colorB=28B9FE)](http://cocoapods.org/pods/KMCAgoraVRTC)[![Downloads](https://img.shields.io/cocoapods/dt/KMCAgoraVRTC.svg?label=Total%20Downloads%20KMCAgoraVRTC&colorB=28B9FE)](http://cocoapods.org/pods/KMCAgoraVRTC)

[![Latest release](https://img.shields.io/github/release/ksvcmc/KMCAgoraVRTC_iOS.svg)](https://github.com/ksvcmc/KMCAgoraVRTC_iOS/releases/latest)
[![CocoaPods platform](https://img.shields.io/cocoapods/p/KMCAgoraVRTC.svg)](https://cocoapods.org/pods/KMCAgoraVRTC)
[![CocoaPods version](https://img.shields.io/cocoapods/v/KMCAgoraVRTC.svg?label=pod_github)](https://cocoapods.org/pods/KMCAgoraVRTC)

## 项目背景
金山魔方是一个多媒体能力提供平台，通过统一接入API、统一鉴权、统一计费等多种手段，降低客户接入多媒体处理能力的代价，提供多媒体能力供应商的效率。 本文档主要针对视频连麦功能而说明。
## 效果展示
![Alt text](https://raw.githubusercontent.com/wiki/ksvcmc/KMCAgoraVRTC_Android/lianmai.jpg)

### PK连麦效果
![pk_demo](https://raw.githubusercontent.com/wiki/ksvcmc/KMCAgoraVRTC_Android/image/pk_demo.jpg)

## 鉴权
SDK在使用时需要用token进行鉴权后方可使用，token申请方式见**接入步骤**部分;  
token与应用包名为一一对应的关系;  
鉴权错误码见：https://github.com/ksvcmc/KMCAgoraVRTC_iOS/wiki/auth_error

## 集成

客户可以先行下载demo, 执行
```
pod install
```
打开KMCAgoraVRTCDemo.xcworkspace演示demo查看效果

- 手动集成
将KMCAgoraVRTC.framework拖进工程，切换到xcode的**General**->**Embedded Binaries**位置，添加KMCAgoraVRTC.framework即可

- Cocoapod集成
```
pod 'KMCAgoraVRTC'
```

## SDK使用指南  

本sdk使用简单，初次使用需要在魔方服务后台申请token，用于客户鉴权，使用下面的接口鉴权
``` objective-c

-(instancetype)initWithToken:(NSString *)token
                    delegate:(id<KMCRtcDelegate>)delegate;
```

加入一个Channel

``` objective-c
-(void)joinChannel:(NSString *)channelName uid:(NSUInteger)uid;
```

离开一个Channel, T人可调用该API，

``` objective-c
-(void)leaveChannel;
```

视频前处理后使用下面的接口送入sdk

``` objective-c
-(void)ProcessVideo:(CVPixelBufferRef)buf timeInfo:(CMTime)pts;
```

远端视频数据回调

``` objective-c
@property (nonatomic, copy)RTCVideoDataBlock videoDataCallback;
``` 

远端音频数据回调

``` objective-c
@property (nonatomic, copy)RTCAudioDataBlock remoteAudioDataCallback;
```


本地音频数据回调

``` objective-c
@property (nonatomic, copy)RTCAudioDataBlock localAudioDataCallback;
```

本sdk需结合金山云推流sdk融合版使用，音视频的合成操作封装在KSYAgoraStreamerKit类中，已经开源，使用者可以参考KSYAgoraStreamerKit类的用法


## 接入流程
![金山魔方接入流程](https://raw.githubusercontent.com/wiki/ksvcmc/KMCSTFilter_Android/all.jpg "金山魔方接入流程")
## 接入步骤  
1.登录[金山云控制台]( https://console.ksyun.com)，选择视频服务-金山魔方
![步骤1](https://raw.githubusercontent.com/wiki/ksvcmc/KMCSTFilter_Android/step1.png "接入步骤1")

2.在金山魔方控制台中挑选所需服务。
![步骤2](https://raw.githubusercontent.com/wiki/ksvcmc/KMCSTFilter_Android/step2.png "接入步骤2")

3.点击申请试用，填写申请资料。
![步骤3](https://raw.githubusercontent.com/wiki/ksvcmc/KMCSTFilter_Android/step3.png "接入步骤3")

![步骤4](https://raw.githubusercontent.com/wiki/ksvcmc/KMCSTFilter_Android/step4.png "接入步骤4")

4.待申请审核通过后，金山云注册时的邮箱会收到邮件及试用token。
![步骤5](https://raw.githubusercontent.com/wiki/ksvcmc/KMCSTFilter_Android/step5.png "接入步骤5")

5.下载安卓/iOS版本的SDK集成进项目。
![步骤6](https://raw.githubusercontent.com/wiki/ksvcmc/KMCSTFilter_Android/step6.png "接入步骤6")

6.参照文档和DEMO填写TOKEN，就可以Run通项目了。  
7.试用中或试用结束后，有意愿购买该服务可以与我们的商务人员联系购买。  
（商务Email:KSC-VBU-KMC@kingsoft.com）
## Demo下载
![Alt text](https://raw.githubusercontent.com/wiki/ksvcmc/KMCAgoraVRTC_Android/lianmaicode.png)
## 反馈与建议  
主页：[金山魔方](https://docs.ksyun.com/read/latest/142/_book/index.html)  
邮箱：ksc-vbu-kmc-dev@kingsoft.com  
QQ讨论群：574179720 [视频云技术交流群] 
