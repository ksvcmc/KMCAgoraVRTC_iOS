//
//  KSYHeader.h
//  GPUTest
//
//  Created by yuyang on 2017/11/17.
//  Copyright © 2017年 yuyang. All rights reserved.
//

#ifndef KSYHeader_h
#define KSYHeader_h

#define DEBUGGER 1 //上线版本屏蔽此宏

#ifdef DEBUGGER
/* 自定义log 可以输出所在的类名,方法名,位置(行数)*/
#define KSYLog(format, ...) NSLog((@"%s [Line %d] " format), __FUNCTION__, __LINE__, ##__VA_ARGS__)

#else

#define KSYLog(...)

#endif

//16进制颜色转换
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kDeviceWidth [[UIScreen mainScreen] bounds].size.width
#define kDeviceHeight [[UIScreen mainScreen] bounds].size.height

#define KSYWeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o;

#define KSYStrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

#define FLOAT_EQ( f0, f1 ) ( (f0 - f1 < 0.001)&& (f0 - f1 > -0.001) )



#endif /* KSYHeader_h */
