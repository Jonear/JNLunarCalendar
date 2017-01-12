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
@property (assign) NSInteger yearSelectIndex;

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
    
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *currentYear = [dateFormatter stringFromDate:[NSDate date]];
    [_yearButton setTitle:currentYear];
    
    self.collectionItem = [JNCollectionItem new];
    [_collectionView setItemPrototype:self.collectionItem];
    _collectionView.selectable = YES;
    
    
    [self.yearTableView setGridStyleMask:(NSTableViewSolidHorizontalGridLineMask | NSTableViewSolidVerticalGridLineMask)];
    [self.yearTableView setRowHeight:20];
    [self.yearTableView setHeaderView:nil];
    
    [self reloadDataWithDate:[currentYear intValue] month:1];
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
    return self.yearDataSouce.count;
}

//用了下面那个函数来显示数据就用不上这个，但是协议必须要实现，所以这里返回nil
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return nil;
}

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
    NSTextField *textField = [rowView viewWithTag:31];
    NSString *title = [self.yearDataSouce objectAtIndex:row];
    [textField setStringValue:title];
    
    if ([_yearButton.title isEqualToString:title]) {
        [rowView setSelected:YES];
        _yearSelectIndex = row;
    }
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    if ([notification object] == self.yearTableView) {
        _yearSelectIndex = [[notification object] selectedRow];
        NSString *year = [self.yearDataSouce objectAtIndex:_yearSelectIndex];
        [_yearButton setTitle:year];
        [self.yearScrollView setHidden:YES];
        // 刷新日历
        [self reloadDataWithDate:[year intValue] month:1];
    }
}

- (IBAction)showYearPopUpMenu:(id)sender {
//    [self.yearScrollView setHidden:!self.yearScrollView.isHidden];
    if (self.yearScrollView.hidden) {
        [self.yearScrollView setHidden:NO];
        // 滚动过去
        [self.yearScrollView.documentView scrollPoint:NSMakePoint(0, _yearSelectIndex*20)];
    } else {
        [self.yearScrollView setHidden:YES];
    }
}

- (void)viewDidDisappear {
    [super viewDidDisappear];
    
    [self.yearScrollView setHidden:YES];
}


@end
