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

@interface JNPopViewController () <NSMenuDelegate, NSOutlineViewDataSource>

@property (weak) IBOutlet NSView *backgroundView;
@property (weak) IBOutlet NSView *headView;
@property (weak) IBOutlet NSCollectionView *collectionView;
@property (strong) JNCollectionItem *collectionItem;
@property (weak) IBOutlet NSScrollView *yearScrollView;
@property (weak) IBOutlet NSButton *yearButton;
@property (weak) IBOutlet NSOutlineView *outlineView;
@property (strong) NSMutableArray *yearDataSouce;

@end

@implementation JNPopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self.backgroundView setWantsLayer:YES];
    [self.backgroundView.layer setBackgroundColor:[[NSColor redColor] colorWithAlphaComponent:0.5].CGColor];
    [self.headView setWantsLayer:YES];
    [self.headView.layer setBackgroundColor:[[NSColor whiteColor] CGColor]];
    
    // 1990-2050
    self.yearDataSouce = [NSMutableArray arrayWithCapacity:60];
    for (int i=1990; i<=2050; i++) {
        [self.yearDataSouce addObject:[NSString stringWithFormat:@"%zd", i]];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *currentYear = [dateFormatter stringFromDate:[NSDate date]];
    [_yearButton setTitle:currentYear];
    
    
    self.collectionItem = [JNCollectionItem new];
    [_collectionView setItemPrototype:self.collectionItem];
    _collectionView.selectable = YES;
    
    self.outlineView.dataSource = self;
    
    NSTableCellView *root = [NSTableCellView new];
    [self.outlineView expandItem:root];
    
    
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

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item {
    return self.yearDataSouce.count;
}

- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *cell = [[NSTableCellView alloc] init];
    [cell.textField setStringValue:self.yearDataSouce[row]];
    
    return cell;
}

- (IBAction)showYearPopUpMenu:(id)sender {
    [self.yearScrollView setHidden:!self.yearScrollView.isHidden];
}

@end
