//
//  JNCollectionItem.m
//  JNLunarCalendar
//
//  Created by NetEase on 2017/1/12.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "JNCollectionItem.h"
#import "JNCalendarSelectManager.h"
#import "JNThemeManager.h"
#import "JNEventManger.h"

@interface JNCollectionItem ()
@property (weak) IBOutlet NSTextField *titleLabel;
@property (weak) IBOutlet NSTextField *detailLabel;
@property (weak) IBOutlet NSTextField *workDayTag;
@property (weak) IBOutlet NSTextField *eventLabel;
@property (assign) BOOL isToday;

@end

@implementation JNCollectionItem

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self.titleLabel setTextColor:[NSColor blackColor]];
}

- (void)setSelected:(BOOL)selected {
    if (self.selected != selected) {
        [super setSelected:selected];
        
        [self.view setWantsLayer:YES];
        if (selected) {
            if (![self isToday]) {
                [self.view.layer setBorderColor:self.selectColor.CGColor];
                [self.view.layer setBorderWidth:2.];
            }
        } else {
            [self.view.layer setBorderWidth:0.];
        }
    }
}

- (void)setToDay {
    self.isToday = YES;
    [self.view setWantsLayer:YES];
    [self.view.layer setBackgroundColor:self.selectColor.CGColor];
    [self.titleLabel setTextColor:[NSColor whiteColor]];
    [self.detailLabel setTextColor:[NSColor whiteColor]];
    [self.eventLabel setTextColor:[NSColor whiteColor]];
}

- (void)setNotToDay {
    self.isToday = NO;
    [self.view setWantsLayer:YES];
    [self.view.layer setBackgroundColor:[NSColor clearColor].CGColor];
}

-(void)reloadDataWithObject:(id)representedObject {
    [self setRepresentedObject:representedObject];
    if (representedObject !=nil)
    {
        [self.eventLabel setTextColor:[JNThemeManager sharedManager].detailColor];
        
        int year = [[representedObject valueForKey:@"year"] intValue];
        int month = [[representedObject valueForKey:@"month"] intValue];
        int day = [[representedObject valueForKey:@"day"] intValue];
        
        [self.titleLabel setTextColor:[NSColor blackColor]];
        [self.detailLabel setTextColor:[NSColor grayColor]];
        [self.titleLabel setStringValue:[representedObject valueForKey:@"day"]];
        
        NSString *solarFestival = [representedObject valueForKey:@"solarFestival"]; // 阳历节日
        if ([solarFestival hasPrefix:@"*"]) {
            solarFestival = nil;
        } else {
            NSRange range = [solarFestival rangeOfString:@"-"];
            if (range.location != NSNotFound) {
                solarFestival = [solarFestival substringToIndex:range.location];
            }
            range = [solarFestival rangeOfString:@" "];
            if (range.location != NSNotFound) {
                solarFestival = [solarFestival substringToIndex:range.location];
            }
            if (solarFestival.length > 4) {
                solarFestival = [solarFestival substringToIndex:4];
            }
        }
        
        NSString *lunarFestival = [representedObject valueForKey:@"lunarFestival"]; // 农历节日
        if (solarFestival.length>0) {
            [self.detailLabel setStringValue:solarFestival];
            [self.detailLabel setTextColor:[NSColor redColor]];
        } else if (lunarFestival.length>0) {
            [self.detailLabel setStringValue:lunarFestival];
            [self.detailLabel setTextColor:[NSColor redColor]];
        } else if ([[representedObject valueForKey:@"lunarDay"] intValue] == 1){
            [self.detailLabel setStringValue:[representedObject valueForKey:@"lunarMonthName"]];
            [self.detailLabel setTextColor:[[JNThemeManager sharedManager] detailColor]];
        } else {
            [self.detailLabel setStringValue:[representedObject valueForKey:@"lunarDayName"]];
            [self.detailLabel setTextColor:[NSColor grayColor]];
        }
        
        // 放假
        NSNumber *worktime = [representedObject valueForKey:@"worktime"];
        if ([worktime integerValue] > 0) {
            [self.workDayTag setHidden:NO];
            if ([worktime integerValue] == 1) {
                [self.workDayTag setStringValue:@"班"];
            } else {
                [self.workDayTag setStringValue:@"假"];
                [self.workDayTag setTextColor:NSColorFromRGB(0x00ad12)];
            }
        } else {
            [self.workDayTag setHidden:YES];
        }
        
        // 今天
        if ([self isToday:year month:month day:day]) {
            [self setToDay];
        } else {
            [self setNotToDay];
        }
        
        // 其他月
        if (year != [JNCalendarSelectManager sharedManager].currentYear ||
            month != [JNCalendarSelectManager sharedManager].currentMonth) {
            [self.titleLabel setTextColor:[NSColor lightGrayColor]];
            [self.detailLabel setTextColor:[NSColor lightGrayColor]];
        }
        
        // 事件
        NSString *eventString = [JNEventManger eventFromYear:year month:month day:day];
        if (eventString.length>0) {
            [self.eventLabel setStringValue:eventString];
            [self.eventLabel setHidden:NO];
        } else {
            [self.eventLabel setHidden:YES];
        }
        
    }
}

- (BOOL)isToday:(int)year month:(int)month day:(int)day {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *currentYear = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter setDateFormat:@"MM"];
    NSString *currentMonth = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter setDateFormat:@"dd"];
    NSString *currentDay = [dateFormatter stringFromDate:[NSDate date]];
    
    return ([currentYear intValue]==year && [currentMonth intValue]==month && [currentDay intValue]==day);
}

- (void)setHolidayTagColor:(NSColor *)color {
    // draw foreground color
    if ([[self.representedObject valueForKey:@"year"] intValue] != [JNCalendarSelectManager sharedManager].currentYear ||
        [[self.representedObject valueForKey:@"month"] intValue] != [JNCalendarSelectManager sharedManager].currentMonth) {
    } else if ([self isToday:[[self.representedObject valueForKey:@"year"] intValue] month:[[self.representedObject valueForKey:@"month"] intValue] day:[[self.representedObject valueForKey:@"day"] intValue]]) {
    } else {
        [self.titleLabel setTextColor:color];
    }
    
    if ([[self.representedObject valueForKey:@"worktime"] integerValue] == 1) {
        [self.workDayTag setTextColor:color];
    }
}

@end
