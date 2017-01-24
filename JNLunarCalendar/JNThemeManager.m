//
//  JNThemeManager.m
//  JNLunarCalendar
//
//  Created by NetEase on 2017/1/19.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "JNThemeManager.h"

#define UserSaveThemeIndexKey @"UserSaveThemeIndexKey"

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
        NSNumber *theme = [[NSUserDefaults standardUserDefaults] objectForKey:UserSaveThemeIndexKey];
        [self updateTheme:[theme intValue]];
    }
    return self;
}

- (NSArray<NSColor*>*)getAllTheme {
    return @[NSColorFromRGB(0xfa897a), NSColorFromRGB(0x11897a), NSColorFromRGB(0xaa8923), NSColorFromRGB(0x3588ab)];
}

- (void)updateTheme:(JNThemeType)type {
    if (type == JNThemeType_Green) {
        _backgroundColor = NSColorFromRGB(0x11897a);
        _detailColor = NSColorFromRGB(0x335021);
    } else if (type == JNThemeType_Gray) {
        _backgroundColor = NSColorFromRGB(0xaa8923);
        _detailColor = NSColorFromRGB(0x774411);
    } else if (type == JNThemeType_Nice) {
        _backgroundColor = NSColorFromRGB(0x3588ab);
        _detailColor = NSColorFromRGB(0x324488);
    } else {
        _backgroundColor = NSColorFromRGB(0xfa897a);
        _detailColor = NSColorFromRGB(0x8F53C4);
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@(type) forKey:UserSaveThemeIndexKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
