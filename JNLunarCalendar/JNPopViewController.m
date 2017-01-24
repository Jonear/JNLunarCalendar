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
#import "JNThemeManager.h"
#import "JNEventManger.h"

#define NormalItemSize CGSizeMake(65, 58)
#define ShortItemSize CGSizeMake(65, 51)
#define HolidayColor [NSColor colorWithRed:156/255. green:0 blue:5/255. alpha:0.8]

@interface JNPopViewController () <NSMenuDelegate, NSTableViewDataSource, NSTabViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegate>

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

@property (weak) IBOutlet NSScrollView *themeScrollView;
@property (weak) IBOutlet NSTableView *themeTableView;

@property (weak) IBOutlet NSTextField *dayTextFiled;
@property (weak) IBOutlet NSView *dayTextBackground;
@property (weak) IBOutlet NSTextField *fullDateTextFiled;
@property (weak) IBOutlet NSTextField *lunarDateTextFiled;
@property (weak) IBOutlet NSTextField *lunarYearTextFiled;
@property (weak) IBOutlet NSTextField *festivalTextFiled;
@property (weak) IBOutlet NSTextField *eventInputTextFiled;

@property (strong) NSCollectionViewFlowLayout *flowLayout;

@property (strong) NSMutableArray *contentDataSouce;
@property (strong) NSArray *themeDataSouce;

@end

@implementation JNPopViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // 1990-2050
        self.yearDataSouce = [NSMutableArray arrayWithCapacity:60];
        self.themeDataSouce = [[JNThemeManager sharedManager] getAllTheme];
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
    [self.dayTextBackground setWantsLayer:YES];
    [self.dayTextBackground.layer setCornerRadius:2];
    
    [self updateTheme];
    [self.headView setWantsLayer:YES];
    [self.headView.layer setBackgroundColor:[[NSColor whiteColor] CGColor]];
    
    _collectionView.selectable = YES;
    [_collectionView registerClass:[JNCollectionItem class] forItemWithIdentifier:@"JNCollectionItem"];
    self.flowLayout = [NSCollectionViewFlowLayout new];
    self.flowLayout.itemSize = NormalItemSize;
    self.flowLayout.minimumLineSpacing = 0;
    self.flowLayout.minimumInteritemSpacing = 0;
    _collectionView.collectionViewLayout = self.flowLayout;
    
    [self.yearTableView setGridStyleMask:(NSTableViewSolidHorizontalGridLineMask | NSTableViewSolidVerticalGridLineMask)];
    [self.yearTableView setRowHeight:20];
    [self.yearTableView setHeaderView:nil];
    
    [self.monthTableView setGridStyleMask:(NSTableViewSolidHorizontalGridLineMask | NSTableViewSolidVerticalGridLineMask)];
    [self.monthTableView setRowHeight:20];
    [self.monthTableView setHeaderView:nil];
    
    [self.themeTableView setRowHeight:20];
    [self.themeTableView setHeaderView:nil];
    
    // 首次点位到今天
    [self backToToDayClick:nil];
}

- (void)updateTheme {
    
    [self.backgroundView.layer setBackgroundColor:[[JNThemeManager sharedManager] backgroundColor].CGColor];
//    [self.festivalTextFiled setTextColor:[[JNThemeManager sharedManager] detailColor]];
    [self.dayTextBackground.layer setBackgroundColor:[[JNThemeManager sharedManager] detailColor].CGColor];
    [self.collectionView reloadData];
}

- (void)viewDidDisappear {
    [super viewDidDisappear];
    
    [self.yearScrollView setHidden:YES];
    [self.monthScrollView setHidden:YES];
    [self.themeScrollView setHidden:YES];
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
            self.flowLayout.itemSize = ShortItemSize;
        } else {
            // 5排结构
            NSMutableArray *newContents = [NSMutableArray arrayWithCapacity:35];
            for (int i=0; i<35; i++) {
                [newContents addObject:[contents objectAtIndex:i]];
            }
            self.contentDataSouce = newContents;
            self.flowLayout.itemSize = NormalItemSize;
        }
    } else {
        self.contentDataSouce = contents;
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (self.monthTableView == tableView) {
        return 12;
    } else if (self.themeTableView == tableView) {
        return self.themeDataSouce.count;
    }
    return self.yearDataSouce.count;
}

// MARK: - NSTableViewDataSource
//用了下面那个函数来显示数据就用不上这个，但是协议必须要实现，所以这里返回nil
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return nil;
}

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
    if (self.monthTableView == tableView) {
        NSTextField *textField = [rowView viewWithTag:31];
        [textField setStringValue:[NSString stringWithFormat:@"%zd 月", row+1]];
        
    } else if (self.themeTableView == tableView) {
        NSTextField *textField = [rowView viewWithTag:31];
        [textField setStringValue:@""];
        NSColor *color = self.themeDataSouce[row];
        [rowView setBackgroundColor:color];
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
    } else if ([notification object] == self.themeTableView) {
        [self.themeScrollView setHidden:YES];
        if ([[notification object] selectedRow] >= 0) {
            [[JNThemeManager sharedManager] updateTheme:[[notification object] selectedRow]];
            [self updateTheme];
            [self.themeTableView deselectAll:nil];
        }
    }
}

// MARK: - ButtonClick

- (IBAction)showYearPopUpMenu:(id)sender {
    if (self.yearScrollView.hidden) {
        [self.monthScrollView setHidden:YES];
        [self.themeScrollView setHidden:YES];
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
        [self.themeScrollView setHidden:YES];
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

- (IBAction)showThemeClick:(id)sender {
    if (self.themeScrollView.hidden) {
        [self.yearScrollView setHidden:YES];
        [self.monthScrollView setHidden:YES];
        [self.themeScrollView setHidden:NO];
    } else {
        [self.themeScrollView setHidden:YES];
    }
}

- (IBAction)quitClick:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"是否退出应用程序?"];
    [alert addButtonWithTitle:@"退出"];
    [alert addButtonWithTitle:@"暂不"];
    
    NSModalResponse returnCode = [alert runModal];
    if (returnCode == 1000) {
        [[NSApplication sharedApplication] terminate:self];
    }
}

- (IBAction)showEventClick:(id)sender {
    NSString *value = [JNEventManger eventFromYear:self.currentYear month:self.currentMonth day:self.currentDay];
    [self.eventInputTextFiled setStringValue:value];
    
    [self.eventInputTextFiled setHidden:NO];
    [self.eventInputTextFiled becomeFirstResponder];
}

- (IBAction)eventDidFinishEdit:(id)sender {
    if (self.eventInputTextFiled.stringValue.length>0 && self.eventInputTextFiled.stringValue.length<=2) {
        NSLog(@"%@", self.eventInputTextFiled.stringValue);
        [JNEventManger setEventToYear:self.currentYear month:self.currentMonth day:self.currentDay value:self.eventInputTextFiled.stringValue];
        [self.eventInputTextFiled setStringValue:@""];
        
        [self.collectionView reloadItemsAtIndexPaths:self.collectionView.selectionIndexPaths];
        
    } else if (self.eventInputTextFiled.stringValue.length>0) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"最多输入两个文字"];
        [alert addButtonWithTitle:@"确定"];
        [alert runModal];
    } else if (self.eventInputTextFiled.isHidden == NO) {
        NSString *value = [JNEventManger eventFromYear:self.currentYear month:self.currentMonth day:self.currentDay];
        if (value.length > 0) {
            [JNEventManger setEventToYear:self.currentYear month:self.currentMonth day:self.currentDay value:@""];
            [self.collectionView reloadData];
        }
    }
    
    [self.eventInputTextFiled setHidden:YES];
}

// MARK: -  ReloadData
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
    [self setCurrentDay:day];
    [self reloadDataWithDate:self.currentYear month:self.currentMonth];
    [_collectionView setContent:self.contentDataSouce];
    
    [_yearButton setTitle:[NSString stringWithFormat:@"%zd 年", self.currentYear]];
    [_monthButton setTitle:[NSString stringWithFormat:@"%zd 月", self.currentMonth]];
    
    [self.monthScrollView setHidden:YES];
    [self.yearScrollView setHidden:YES];
    [self.themeScrollView setHidden:YES];
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

// MARK: - NSCollectionViewDataSource
- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section NS_AVAILABLE_MAC(10_11) {
    return self.contentDataSouce.count;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_MAC(10_11) {
    JNCollectionItem *item = [collectionView makeItemWithIdentifier:@"JNCollectionItem" forIndexPath:indexPath];
    
    item.selectColor = [JNThemeManager sharedManager].backgroundColor;
    [item setSelected:NO];
    if (self.contentDataSouce.count > indexPath.item) {
        id dict = self.contentDataSouce[indexPath.item];
        if ([dict[@"year"] intValue] == self.currentYear && [dict[@"month"] intValue] == self.currentMonth && [dict[@"day"] intValue] == self.currentDay) {
            [item setSelected:YES];
            
            [self reloadDetailData:dict];
            [_collectionView setSelectionIndexes:[NSIndexSet indexSetWithIndex:indexPath.item]];
        }
        
        [item reloadDataWithObject:dict];
        
        if (indexPath.item%7==0 || indexPath.item%7==6) {
            [item setHolidayTagColor:HolidayColor];
        }
    }
    
    return item;
}

// MARK: - NSCollectionViewDelegate
- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
    NSIndexPath *indexPath = [indexPaths anyObject];
    if (self.contentDataSouce.count > indexPath.item) {
        id representedObject = self.contentDataSouce[indexPath.item];
        
        [self setCurrentDay:[representedObject[@"day"] intValue]];
        [self selectItemChanged:representedObject];
    }
}

- (void)selectItemChanged:(NSDictionary *)representedObject {
    if ([representedObject[@"month"] intValue] == self.currentMonth) {
        [self reloadDetailData:representedObject];
    } else {
        [self setCurrentYear:[representedObject[@"year"] intValue]];
        [self setCurrentMonth:[representedObject[@"month"] intValue]];
        [self reloadDateDataWithDefaultSelected:[representedObject[@"day"] intValue]];
    }
}

// MARK: - CalendarSelectManager
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

- (int)currentDay {
    return [[JNCalendarSelectManager sharedManager] currentDay];
}

- (void)setCurrentDay:(int)day {
    [[JNCalendarSelectManager sharedManager] setCurrentDay:day];
}
@end
