//
//  JNPopViewController.m
//  JNLunarCalendar
//
//  Created by NetEase on 2017/1/11.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "JNPopViewController.h"

@interface JNPopViewController ()

@property (weak) IBOutlet NSView *backgroundView;
@property (weak) IBOutlet NSView *headView;

@end

@implementation JNPopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self.backgroundView setWantsLayer:YES];
    [self.backgroundView.layer setBackgroundColor:[[NSColor redColor] colorWithAlphaComponent:0.5].CGColor];
    [self.headView setWantsLayer:YES];
    [self.headView.layer setBackgroundColor:[[NSColor whiteColor] CGColor]];
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
