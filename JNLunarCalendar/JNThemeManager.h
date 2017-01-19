//
//  JNThemeManager.h
//  JNLunarCalendar
//
//  Created by NetEase on 2017/1/19.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, JNThemeType) {
    JNThemeType_Normal,
    JNThemeType_Green,
    JNThemeType_Gray,
};

@interface JNThemeManager : NSObject

+ (instancetype)sharedManager;

- (NSArray<NSColor*>*)getAllTheme;

- (void)updateTheme:(JNThemeType)type;

@property (strong, nonatomic, readonly) NSColor *backgroundColor;
@property (strong, nonatomic, readonly) NSColor *detailColor;

@end
