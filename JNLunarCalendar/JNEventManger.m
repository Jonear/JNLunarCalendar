//
//  JNEventManger.m
//  JNLunarCalendar
//
//  Created by NetEase on 2017/1/24.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "JNEventManger.h"

@implementation JNEventManger

+ (void)setEventToYear:(int)year month:(int)month day:(int)day value:(NSString *)value {
    NSString *key =  [NSString stringWithFormat:@"EventData:%zd-%zd-%zd", year, month, day];
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)eventFromYear:(int)year month:(int)month day:(int)day {
    NSString *key =  [NSString stringWithFormat:@"EventData:%zd-%zd-%zd", year, month, day];
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

@end
