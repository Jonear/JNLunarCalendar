//
//  JNEventManger.h
//  JNLunarCalendar
//
//  Created by NetEase on 2017/1/24.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JNEventManger : NSObject

+ (void)setEventToYear:(int)year month:(int)month day:(int)day value:(NSString *)value;

+ (NSString *)eventFromYear:(int)year month:(int)month day:(int)day;

@end
