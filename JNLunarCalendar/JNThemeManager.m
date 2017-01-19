//
//  JNThemeManager.m
//  JNLunarCalendar
//
//  Created by NetEase on 2017/1/19.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "JNThemeManager.h"

#define NSColorFromRGBA(rgbValue, alphaValue) [NSColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:alphaValue]

#define NSColorFromRGB(rgbValue)              NSColorFromRGBA(rgbValue, 1.0)

@implementation JNThemeManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [JNThemeManager new];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self updateTheme:JNThemeType_Normal];
    }
    return self;
}

- (NSArray<NSColor*>*)getAllTheme {
    return @[NSColorFromRGB(0xfa897a), NSColorFromRGB(0x11897a), NSColorFromRGB(0xaa8923)];
}

- (void)updateTheme:(JNThemeType)type {
    if (type == JNThemeType_Normal) {
        _backgroundColor = NSColorFromRGB(0xfa897a);
        _detailColor = NSColorFromRGB(0x8F53C4);
    } else if (type == JNThemeType_Green) {
        _backgroundColor = NSColorFromRGB(0x11897a);
        _detailColor = NSColorFromRGB(0x8F5011);
    } else if (type == JNThemeType_Gray) {
        _backgroundColor = NSColorFromRGB(0xaa8923);
        _detailColor = NSColorFromRGB(0x774411);
    }
}

@end
