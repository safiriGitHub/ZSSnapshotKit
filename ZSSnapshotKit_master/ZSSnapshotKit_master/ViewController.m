//
//  ViewController.m
//  ZSSnapshotKit_master
//
//  Created by safiri on 2019/5/21.
//  Copyright © 2019 safiri. All rights reserved.
//

#import "ViewController.h"
#import "WKWebViewTesterViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)WKWebViewTester:(id)sender {
    
    WKWebViewTesterViewController *vc = [[WKWebViewTesterViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
