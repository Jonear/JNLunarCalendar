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

@interface JNPopViewController () <NSCollectionViewDelegate, NSCollectionViewDataSource>

@property (weak) IBOutlet NSView *backgroundView;
@property (weak) IBOutlet NSView *headView;
@property (weak) IBOutlet NSPopUpButton *yearPopUpButton;
@property (weak) IBOutlet NSCollectionView *collectionView;
@property (strong) JNCollectionItem *collectionItem;

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
    [_yearPopUpButton removeAllItems];
    NSMutableArray *titles = [NSMutableArray arrayWithCapacity:60];
    for (int i=1990; i<=2050; i++) {
        [titles addObject:[NSString stringWithFormat:@"%zd", i]];
    }
    [_yearPopUpButton addItemsWithTitles:titles];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *currentYear = [dateFormatter stringFromDate:[NSDate date]];
    NSInteger index = [titles indexOfObject:currentYear];
    if (index != NSNotFound) {
        [_yearPopUpButton selectItemAtIndex:index];
    }
    
    self.collectionItem = [JNCollectionItem new];
    [_collectionView setItemPrototype:self.collectionItem];
    
    NSDictionary *dictData = calendar(2007, 1);
    NSArray *contents = dictData[@"monthData"];
    [_collectionView setContent:contents];
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

@end
