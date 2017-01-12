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

@end

@implementation JNCollectionItem

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self.titleLabel setBackgroundColor:[NSColor clearColor]];
    [self.detailLabel setBackgroundColor:[NSColor clearColor]];
    
}

-(void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    if (representedObject !=nil)
    {
        [self.titleLabel setStringValue:[representedObject valueForKey:@"day"]];
        
        NSString *solarFestival = [representedObject valueForKey:@"solarFestival"];
        if (solarFestival.length > 0) {
            [self.detailLabel setStringValue:solarFestival];
            [self.detailLabel setTextColor:[NSColor redColor]];
        } else {
            [self.detailLabel setStringValue:[representedObject valueForKey:@"lunarDayName"]];
            [self.detailLabel setTextColor:[NSColor textColor]];
        }
    }
}

@end
