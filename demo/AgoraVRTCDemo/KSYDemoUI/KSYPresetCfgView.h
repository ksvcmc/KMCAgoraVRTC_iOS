//
//  KSYPresetCfgView.h
//  KSYStreamerVC
//
//  Created by yiqian on 10/15/15.
//  Copyright (c) 2015 qyvideo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYUIView.h"

#if USING_DYNAMIC_FRAMEWORK
#import <libksygpulivedylib/libksygpulivedylib.h>
#import <libksygpulivedylib/libksygpuimage.h>
#else
#import <libksygpulive/libksygpulive.h>
#import "libksygpulive/KSYMoviePlayerController.h"
#endif

@interface KSYPresetCfgView : KSYUIView

// UI elements
@property UIButton* btn0;

// preset settings
// capture
@property UITextField        * hostUrlUI;           // host URL
@property UILabel            *lblResolutionUI;
@property UISegmentedControl *resolutionUI; // 采集分辨率
@property UILabel            *lblStreamResoUI;
@property UISegmentedControl *streamResoUI; // 推流分辨率
@property UILabel            *lblCameraPosUI;
@property UISegmentedControl *cameraPosUI;  //

@property KSYNameSlider* frameRateUI;

// stream
@property UILabel            *lblVideoCodecUI;
@property UISegmentedControl *videoCodecUI; //
@property UILabel            *lblAudioCodecUI; //
@property UISegmentedControl *audioCodecUI; //
@property KSYNameSlider      *videoKbpsUI;
@property UILabel            *lblAudioKbpsUI; //
@property UISegmentedControl *audioKbpsUI; //
// get config data
- (NSString*) hostUrl;
- (NSString*) capResolution;
- (KSYVideoDimension) strResolution;
@property(nonatomic, assign) CGSize capResolutionSize;
@property(nonatomic, assign) CGSize strResolutionSize;
- (AVCaptureDevicePosition) cameraPos;
- (int) frameRate;
- (KSYVideoCodec) videoCodec;
- (KSYAudioCodec) audioCodec;
- (int) videoKbps;
- (int) audioKbps;

@end

