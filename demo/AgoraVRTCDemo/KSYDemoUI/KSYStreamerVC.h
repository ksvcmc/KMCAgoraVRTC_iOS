//
//  KSYStreamerVC.h
//  KSYStreamerVC
//
//  Created by yiqian on 10/15/15.
//  Copyright (c) 2015 qyvideo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYUIView.h"
#import "KSYUIVC.h"
#import "KSYPresetCfgView.h"
#import "KSYCtrlView.h"
#import "KSYStreamerVC.h"
#import "KSYMenuView.h"
#import "KSYFilterView.h"
#import "KSYRtcView.h"
#import "KSYStateLableView.h"

#import <libksygpulive/libksystreamerengine.h>
#import <libksygpulive/KSYGPUStreamerKit.h>
#import "libksygpulive/KSYMoviePlayerController.h"


@interface KSYStreamerVC : KSYUIVC

// 切到当前VC后， 界面自动开启推流
@property BOOL  bAutoStart;

- (id) initWithCfg:(KSYPresetCfgView*)presetCfgView;

// sub views
@property (nonatomic, readonly) KSYCtrlView   * ctrlView;
@property (nonatomic, readonly) KSYMenuView   * ksyMenuView;
@property (nonatomic, readonly) KSYFilterView * ksyFilterView;
@property (nonatomic, readonly) KSYRtcView    *rtcView;
// submodules
@property (nonatomic, retain) KSYStreamerBase*   streamerBase;
@property (nonatomic, retain) KSYGPUCamera*      capDev;
@property (nonatomic, retain) KSYAudioMixer*     aMixer;
@property (nonatomic, assign) int     micTrack;

// presetCfgs
@property (nonatomic, retain) KSYPresetCfgView * presetCfgView;

// 推流地址 完整的URL
@property NSURL * hostURL;

// 采集的参数设置
- (void) setCaptureCfg;
// 推流的参数设置
- (void) setStreamerCfg;

// 一秒前的数据
@property StreamState *lastState;

- (void) addObservers;
- (void) rmObservers;

#pragma mark - state change monitor
- (void) onCaptureStateChange:(NSNotification *)notification;
- (void) onNetStateEvent     :(NSNotification *)notification;
- (void) onStreamStateChange :(NSNotification *)notification;

#pragma mark - UI respond
- (void) onFlash;
- (void) onCameraToggle;
- (void) onQuit;
- (void) onCapture;
- (void) onStream;
// gpu filter
- (void) onFilterChange:(id)sender;
@end
