//
//  JNCollectionItem.m
//  JNLunarCalendar
//
//  Created by NetEase on 2017/1/12.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "JNCollectionItem.h"
#import "JNCalendarSelectManager.h"

@interface JNCollectionItem ()
@property (weak) IBOutlet NSTextField *titleLabel;
@property (weak) IBOutlet NSTextField *detailLabel;
@property (weak) IBOutlet NSTextField *workDayTag;
@property (strong) NSColor *selectColor;
@property (assign) BOOL isToday;

@end

@implementation JNCollectionItem

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.selectColor = [[NSColor redColor] colorWithAlphaComponent:0.7];
    [self.titleLabel setTextColor:[NSColor blackColor]];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    [self.view setWantsLayer:YES];
    if (selected) {
        if (![self isToday]) {
            [self.view.layer setBorderColor:self.selectColor.CGColor];
            [self.view.layer setBorderWidth:2.];
        }
        
        [[JNCalendarSelectManager sharedManager] selectedDay:self.representedObject];
    } else {
        [self.view.layer setBorderWidth:0.];
    }
}

- (void)setToDay {
    self.isToday = YES;
    [self.view setWantsLayer:YES];
    [self.view.layer setBackgroundColor:self.selectColor.CGColor];
    [self.titleLabel setTextColor:[NSColor whiteColor]];
    [self.detailLabel setTextColor:[NSColor whiteColor]];
}

-(void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    if (representedObject !=nil)
    {
        [self.titleLabel setStringValue:[representedObject valueForKey:@"day"]];
        
        NSString *solarFestival = [representedObject valueForKey:@"solarFestival"]; // 阳历节日
        NSString *lunarFestival = [representedObject valueForKey:@"lunarFestival"]; // 农历节日
        if (solarFestival.length>0) {
            [self.detailLabel setStringValue:solarFestival];
            [self.detailLabel setTextColor:[NSColor redColor]];
        } else if (lunarFestival.length>0) {
            [self.detailLabel setStringValue:lunarFestival];
            [self.detailLabel setTextColor:[NSColor redColor]];
        } else {
            [self.detailLabel setStringValue:[representedObject valueForKey:@"lunarDayName"]];
            [self.detailLabel setTextColor:[NSColor grayColor]];
        }
        
        // 放假
        if ([[representedObject valueForKey:@"worktime"] boolValue]) {
            [self.workDayTag setHidden:NO];
        } else {
            [self.workDayTag setHidden:YES];
        }
        
        // 今天
        if ([self isToday:[[representedObject valueForKey:@"year"] intValue] month:[[representedObject valueForKey:@"month"] intValue] day:[[representedObject valueForKey:@"day"] intValue]]) {
            [self setToDay];
        }
        
        // 其他月
        if ([[representedObject valueForKey:@"year"] intValue] != [JNCalendarSelectManager sharedManager].currentYear ||
            [[representedObject valueForKey:@"month"] intValue] != [JNCalendarSelectManager sharedManager].currentMonth) {
            [self.titleLabel setTextColor:[NSColor lightGrayColor]];
            [self.detailLabel setTextColor:[NSColor lightGrayColor]];
        }
    }
}

- (BOOL)isToday:(int)year month:(int)month day:(int)day {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *currentYear = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter setDateFormat:@"MM"];
    NSString *currentMonth = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter setDateFormat:@"DD"];
    NSString *currentDay = [dateFormatter stringFromDate:[NSDate date]];
    
    return ([currentYear intValue]==year && [currentMonth intValue]==month && [currentDay intValue]==day);
}

@end
