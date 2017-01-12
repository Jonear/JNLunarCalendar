//
//  JNCollectionItem.m
//  JNLunarCalendar
//
//  Created by NetEase on 2017/1/12.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "JNCollectionItem.h"

@interface JNCollectionItem ()
@property (weak) IBOutlet NSTextField *titleLabel;
@property (weak) IBOutlet NSTextField *detailLabel;
@property (weak) IBOutlet NSTextField *workDayTag;

@end

@implementation JNCollectionItem

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self.titleLabel setTextColor:[NSColor blackColor]];
    
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
    }
}

@end
