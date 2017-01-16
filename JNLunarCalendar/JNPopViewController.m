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

@property (assign) int currentYear;
@property (assign) int currentMonth;

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
    
    // 首次点位到今天
    [self backToToDayClick:nil];
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
    NSArray *contents = dictData[@"monthData"];
    
    // 判断下是否是6排
    if (contents.count > 35) {
        NSDictionary *content35 = [contents objectAtIndex:35];
        if ([content35[@"day"] integerValue] > 10) {
            [_collectionView setContent:contents];
        } else {
            // 5排结构
            NSMutableArray *newContents = [NSMutableArray arrayWithCapacity:35];
            for (int i=0; i<35; i++) {
                [newContents addObject:[contents objectAtIndex:i]];
            }
            [_collectionView setContent:newContents];
        }
    } else {
        [_collectionView setContent:contents];
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
        
        if ([title intValue] == _currentYear) {
            [rowView setSelected:YES];
        }
    }
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification {
    if ([notification object] == self.yearTableView) {
        NSString *year = [self.yearDataSouce objectAtIndex:[[notification object] selectedRow]];
        [self.yearScrollView setHidden:YES];
        // 刷新日历
        _currentYear = [year intValue];
        [self reloadDateData];
    }
}

- (IBAction)showYearPopUpMenu:(id)sender {
    if (self.yearScrollView.hidden) {
        [self.yearScrollView setHidden:NO];
        // 滚动过去
        int yearSelectIndex = _currentYear - 1990;
        [self.yearScrollView.documentView scrollPoint:NSMakePoint(0, yearSelectIndex*20)];
    } else {
        [self.yearScrollView setHidden:YES];
    }
}

- (IBAction)showMonthPopUpMenu:(id)sender {
    if (self.monthScrollView.hidden) {
        [self.monthScrollView setHidden:NO];
    } else {
        [self.monthScrollView setHidden:YES];
    }
}

- (IBAction)nextMonthButtonClick:(id)sender {
    if (_currentMonth+1 > 12) {
        _currentMonth = 1;
        _currentYear ++;
        
        // 超出范围
        if (_currentYear > 2050) {
            _currentMonth = 12;
            _currentYear --;
            return;
        }
    } else {
        _currentMonth ++;
    }
    [self reloadDateData];
}

- (IBAction)backToToDayClick:(id)sender {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *currentYear = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter setDateFormat:@"MM"];
    NSString *currentMonth = [dateFormatter stringFromDate:[NSDate date]];
    
    _currentYear = [currentYear intValue];
    _currentMonth = [currentMonth intValue];
    [self reloadDateData];
    
}

- (IBAction)preMonthButtonClick:(id)sender {
    if (_currentMonth-1 < 1) {
        _currentMonth = 12;
        _currentYear --;
        // 超出范围
        if (_currentYear < 1990) {
            _currentMonth = 1;
            _currentYear ++;
            return;
        }
    } else {
        _currentMonth --;
    }
    [self reloadDateData];
}

- (void)viewDidDisappear {
    [super viewDidDisappear];
    
    [self.yearScrollView setHidden:YES];
}

- (void)reloadDateData {
    [self reloadDataWithDate:_currentYear month:_currentMonth];
    
    [_yearButton setTitle:[NSString stringWithFormat:@"%zd 年", _currentYear]];
    [_monthButton setTitle:[NSString stringWithFormat:@"%zd 月", _currentMonth]];
    
    [self.monthScrollView setHidden:YES];
    [self.yearScrollView setHidden:YES];
    [self.yearTableView reloadData];
}


@end
