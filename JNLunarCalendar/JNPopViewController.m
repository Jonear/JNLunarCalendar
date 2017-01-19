//
//  JNPopViewController.m
//  JNLunarCalendar
//
//  Created by NetEase on 2017/1/11.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "JNPopViewController.h"
#import "JNCollectionItem.h"
#import "LunarCore.h"
#import "JNCalendarSelectManager.h"

@interface JNPopViewController () <NSMenuDelegate, NSTableViewDataSource, NSTabViewDelegate>

@property (weak) IBOutlet NSView *backgroundView;
@property (weak) IBOutlet NSView *headView;
@property (weak) IBOutlet NSCollectionView *collectionView;
@property (strong) JNCollectionItem *collectionItem;

@property (weak) IBOutlet NSScrollView *yearScrollView;
@property (weak) IBOutlet NSButton *yearButton;
@property (weak) IBOutlet NSTableView *yearTableView;
@property (strong) NSMutableArray *yearDataSouce;

@property (weak) IBOutlet NSScrollView *monthScrollView;
@property (weak) IBOutlet NSButton *monthButton;
@property (weak) IBOutlet NSTableView *monthTableView;

@property (weak) IBOutlet NSTextField *dayTextFiled;
@property (weak) IBOutlet NSView *dayTextBackground;
@property (weak) IBOutlet NSTextField *fullDateTextFiled;
@property (weak) IBOutlet NSTextField *lunarDateTextFiled;
@property (weak) IBOutlet NSTextField *lunarYearTextFiled;
@property (weak) IBOutlet NSTextField *festivalTextFiled;

@property (strong) NSMutableArray *contentDataSouce;

@end

@implementation JNPopViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // 1990-2050
        self.yearDataSouce = [NSMutableArray arrayWithCapacity:60];
        for (int i=1990; i<=2050; i++) {
            [self.yearDataSouce addObject:[NSString stringWithFormat:@"%zd", i]];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self.backgroundView setWantsLayer:YES];
    [self.backgroundView.layer setBackgroundColor:[[NSColor redColor] colorWithAlphaComponent:0.5].CGColor];
    [self.headView setWantsLayer:YES];
    [self.headView.layer setBackgroundColor:[[NSColor whiteColor] CGColor]];
    
    
    self.collectionItem = [JNCollectionItem new];
    [_collectionView setItemPrototype:self.collectionItem];
    _collectionView.selectable = YES;
    
    
    [self.yearTableView setGridStyleMask:(NSTableViewSolidHorizontalGridLineMask | NSTableViewSolidVerticalGridLineMask)];
    [self.yearTableView setRowHeight:20];
    [self.yearTableView setHeaderView:nil];
    
    [self.monthTableView setGridStyleMask:(NSTableViewSolidHorizontalGridLineMask | NSTableViewSolidVerticalGridLineMask)];
    [self.monthTableView setRowHeight:20];
    [self.monthTableView setHeaderView:nil];
    
    [self.dayTextBackground setWantsLayer:YES];
    [self.dayTextBackground.layer setCornerRadius:2];
    [self.dayTextBackground.layer setBackgroundColor:[NSColor colorWithRed:128/255. green:89/255. blue:188/255. alpha:0.8].CGColor];
    
    // 首次点位到今天
    [self backToToDayClick:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectItemChanged:)
                                                 name:JNNotiSelctedItemChanged
                                               object:nil];
}

- (IBAction)quitClick:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"是否退出应用程序?"];
    [alert addButtonWithTitle:@"暂不"];
    [alert addButtonWithTitle:@"退出"];

    NSModalResponse returnCode = [alert runModal];
    if (returnCode > 1000) {
        [[NSApplication sharedApplication] terminate:self];
    }
}

- (void)reloadDataWithDate:(int)year month:(int)month {
    NSDictionary *dictData = calendar(year, month);
    NSMutableArray *contents = [dictData[@"monthData"] mutableCopy];

    // 判断下是否是6排
    if (contents.count > 35) {
        NSDictionary *content35 = [contents objectAtIndex:35];
        if ([content35[@"day"] integerValue] > 10) {
            // 6排
            self.contentDataSouce = contents;
        } else {
            // 5排结构
            NSMutableArray *newContents = [NSMutableArray arrayWithCapacity:35];
            for (int i=0; i<35; i++) {
                [newContents addObject:[contents objectAtIndex:i]];
            }
            self.contentDataSouce = newContents;
        }
    } else {
        self.contentDataSouce = contents;
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (self.monthTableView == tableView) {
        return 12;
    }
    return self.yearDataSouce.count;
}

//用了下面那个函数来显示数据就用不上这个，但是协议必须要实现，所以这里返回nil
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return nil;
}

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
    if (self.monthTableView == tableView) {
        NSTextField *textField = [rowView viewWithTag:31];
        [textField setStringValue:[NSString stringWithFormat:@"%zd 月", row+1]];
        
    } else {
        NSTextField *textField = [rowView viewWithTag:31];
        NSString *title = [self.yearDataSouce objectAtIndex:row];
        [textField setStringValue:title];
        
        if ([title intValue] == [self currentYear]) {
            [rowView setSelected:YES];
        }
    }
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification {
    if ([notification object] == self.yearTableView) {
        NSString *year = [self.yearDataSouce objectAtIndex:[[notification object] selectedRow]];
        [self.yearScrollView setHidden:YES];
        // 刷新日历
        [self setCurrentYear:[year intValue]];
        [self reloadDateData];
    } else if ([notification object] == self.monthTableView) {
        NSInteger month = [[notification object] selectedRow]+1;
        [self.monthScrollView setHidden:YES];
        [self setCurrentMonth:(int)month];
        [self reloadDateData];
    }
}

- (int)currentYear {
    return [[JNCalendarSelectManager sharedManager] currentYear];
}

- (void)setCurrentYear:(int)year {
    [[JNCalendarSelectManager sharedManager] setCurrentYear:year];
}

- (int)currentMonth {
    return [[JNCalendarSelectManager sharedManager] currentMonth];
}

- (void)setCurrentMonth:(int)month {
    [[JNCalendarSelectManager sharedManager] setCurrentMonth:month];
}

- (IBAction)showYearPopUpMenu:(id)sender {
    if (self.yearScrollView.hidden) {
        [self.monthScrollView setHidden:YES];
        [self.yearScrollView setHidden:NO];
        // 滚动过去
        int yearSelectIndex = [self currentYear] - 1990;
        [self.yearScrollView.documentView scrollPoint:NSMakePoint(0, yearSelectIndex*20)];
    } else {
        [self.yearScrollView setHidden:YES];
    }
}

- (IBAction)showMonthPopUpMenu:(id)sender {
    if (self.monthScrollView.hidden) {
        [self.yearScrollView setHidden:YES];
        [self.monthScrollView setHidden:NO];
    } else {
        [self.monthScrollView setHidden:YES];
    }
}

- (IBAction)nextMonthButtonClick:(id)sender {
    if (self.currentMonth+1 > 12) {
        [self setCurrentMonth:1];
        [self setCurrentYear:self.currentYear+1];
        
        // 超出范围
        if (self.currentYear > 2050) {
            self.currentMonth = 12;
            [self setCurrentYear:self.currentYear-1];
            return;
        }
    } else {
        [self setCurrentMonth:self.currentMonth+1];
    }
    [self reloadDateData];
}

- (IBAction)backToToDayClick:(id)sender {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *currentYear = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter setDateFormat:@"MM"];
    NSString *currentMonth = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter setDateFormat:@"DD"];
    NSString *currentDay = [dateFormatter stringFromDate:[NSDate date]];
    
    [self.dayTextFiled setStringValue:currentDay];
    
    [self setCurrentYear:[currentYear intValue]];
    [self setCurrentMonth:[currentMonth intValue]];
    [self reloadDateDataWithDefaultSelected:[currentDay intValue]];
}


- (IBAction)preMonthButtonClick:(id)sender {
    if (self.currentMonth-1 < 1) {
        [self setCurrentMonth:12];
        [self setCurrentYear:self.currentYear-1];
        // 超出范围
        if (self.currentYear < 1990) {
            [self setCurrentMonth:1];
            [self setCurrentYear:self.currentYear+1];
            return;
        }
    } else {
        [self setCurrentMonth:self.currentMonth-1];
    }
    [self reloadDateData];
}

- (void)selectItemChanged:(NSNotification *)notification {
    NSDictionary *dict = notification.userInfo;
    
    if ([dict[@"month"] intValue] == self.currentMonth) {
        [self reloadDetailData:dict];
    } else {
        [self setCurrentYear:[dict[@"year"] intValue]];
        [self setCurrentMonth:[dict[@"month"] intValue]];
        [self reloadDateDataWithDefaultSelected:[dict[@"day"] intValue]];
    }
}

- (void)viewDidDisappear {
    [super viewDidDisappear];
    
    [self.yearScrollView setHidden:YES];
}

- (void)reloadDateData {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *currentYear = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter setDateFormat:@"MM"];
    NSString *currentMonth = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter setDateFormat:@"DD"];
    NSString *currentDay = [dateFormatter stringFromDate:[NSDate date]];
    
    if (self.currentYear == [currentYear intValue] && self.currentMonth == [currentMonth intValue]) {
        [self reloadDateDataWithDefaultSelected:[currentDay intValue]];
    } else {
        [self reloadDateDataWithDefaultSelected:1];
    }
}

- (void)reloadDateDataWithDefaultSelected:(int)day {
    [self reloadDataWithDate:self.currentYear month:self.currentMonth];
    
    // 设置默认选中
    __block int selectIndex = day;
    __block NSDictionary *wobj = nil;
    [self.contentDataSouce enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj[@"year"] intValue] == self.currentYear && [obj[@"month"] intValue] == self.currentMonth && [obj[@"day"] intValue] == day) {
            NSMutableDictionary *mdict = [obj mutableCopy];
            [mdict setObject:@(YES) forKey:@"defaultSelected"];
            [self.contentDataSouce replaceObjectAtIndex:idx withObject:mdict];
            selectIndex = (int)idx;
            wobj = obj;
            *stop = YES;
        }
    }];
    
    [_collectionView setContent:self.contentDataSouce];
    // 解决一个坑爹的不能点击的问题
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([wobj[@"year"] intValue] == self.currentYear && [wobj[@"month"] intValue] == self.currentMonth) {
            [_collectionView setSelectionIndexes:[NSIndexSet indexSetWithIndex:selectIndex]];
        }
    });
    
    
    [_yearButton setTitle:[NSString stringWithFormat:@"%zd 年", self.currentYear]];
    [_monthButton setTitle:[NSString stringWithFormat:@"%zd 月", self.currentMonth]];
    
    [self.monthScrollView setHidden:YES];
    [self.yearScrollView setHidden:YES];
    [self.yearTableView reloadData];
}

- (void)reloadDetailData:(NSDictionary *)dict {
    [self.dayTextFiled setStringValue:dict[@"day"]];
    NSArray *weekName = @[@"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六"];
    NSInteger index = [self.contentDataSouce indexOfObject:dict];
    if (index == NSNotFound) {
        index = 0;
    }
    [self.fullDateTextFiled setStringValue:[NSString stringWithFormat:@"%@-%@-%@ %@", dict[@"year"], dict[@"month"], dict[@"day"], weekName[index%7]]];
    [self.lunarDateTextFiled setStringValue:[NSString stringWithFormat:@"%@%@", dict[@"lunarMonthName"], dict[@"lunarDayName"]]];
    [self.lunarYearTextFiled setStringValue:[NSString stringWithFormat:@"%@年 [%@年]", dict[@"GanZhiYear"], dict[@"zodiac"]]];
    
    NSString *solarFestival = [dict valueForKey:@"solarFestival"]; // 阳历节日
    solarFestival = [solarFestival stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
    solarFestival = [solarFestival stringByReplacingOccurrencesOfString:@"-" withString:@"\n"];
    solarFestival = [solarFestival stringByReplacingOccurrencesOfString:@"*" withString:@""];
    
    NSString *lunarFestival = [dict valueForKey:@"lunarFestival"]; // 农历节日
    if (solarFestival.length>0) {
        [self.festivalTextFiled setStringValue:solarFestival];
    } else if (lunarFestival.length>0) {
        [self.festivalTextFiled setStringValue:lunarFestival];
    } else {
        [self.festivalTextFiled setStringValue:@""];
    }
    
    // 布局
    [self.festivalTextFiled sizeToFit];
    [self.festivalTextFiled setFrame:CGRectMake(CGRectGetMinX(self.festivalTextFiled.frame), CGRectGetMinY(self.lunarYearTextFiled.frame)-CGRectGetHeight(self.festivalTextFiled.frame)-7, 123, CGRectGetHeight(self.festivalTextFiled.frame))];
}


@end
