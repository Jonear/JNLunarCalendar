//
//  JNThemeManager.h
//  JNLunarCalendar
//
//  Created by NetEase on 2017/1/19.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#define NSColorFromRGBA(rgbValue, alphaValue) [NSColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:alphaValue]

#define NSColorFromRGB(rgbValue)              NSColorFromRGBA(rgbValue, 1.0)
#define ThemeBackgroundImageFilePath          @"ThemeBackgroundImageFilePath"

typedef NS_ENUM(NSInteger, JNThemeType) {
    JNThemeType_Normal = 0,
    JNThemeType_Green,
    JNThemeType_Gray,
    JNThemeType_Nice,
};

@interface JNThemeManager : NSObject

+ (instancetype)sharedManager;

- (NSArray<NSColor*>*)getAllTheme;

- (void)updateTheme:(JNThemeType)type;

@property (strong, nonatomic, readonly) NSColor *backgroundColor;
@property (strong, nonatomic, readonly) NSColor *detailColor;

@end
