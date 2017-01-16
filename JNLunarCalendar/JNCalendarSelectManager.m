//
//  JNCalendarSelectManager.m
//  JNLunarCalendar
//
//  Created by NetEase on 2017/1/16.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "JNCalendarSelectManager.h"

@implementation JNCalendarSelectManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [JNCalendarSelectManager new];
    });
    return instance;
}

- (void)selectedDay:(NSDictionary *)dict {
    _currentDay = [dict[@"day"] intValue];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:JNNotiSelctedItemChanged object:nil userInfo:dict];
}

@end
