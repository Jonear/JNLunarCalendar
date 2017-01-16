//
//  JNCalendarSelectManager.h
//  JNLunarCalendar
//
//  Created by NetEase on 2017/1/16.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

#define JNNotiSelctedItemChanged @"JNNotiSelctedItemChanged"

@interface JNCalendarSelectManager : NSObject

@property (assign) int currentYear;
@property (assign) int currentMonth;
@property (assign) int currentDay;

+ (instancetype)sharedManager;

- (void)selectedDay:(NSDictionary *)dict;

@end
