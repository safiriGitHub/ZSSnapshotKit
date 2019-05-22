//
//  WKWebViewTesterViewController.m
//  ZSSnapshotKit_master
//
//  Created by safiri on 2019/5/21.
//  Copyright © 2019 safiri. All rights reserved.
//

#import "WKWebViewTesterViewController.h"
#import <WebKit/WebKit.h>
#import "WKWebView+Snapshot.h"
#import "UIScrollView+Snapshot.h"
#import "SVProgressHUD.h"

@interface WKWebViewTesterViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *funcDataArray;

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation WKWebViewTesterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"WKWebView 测试";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initView];
}

- (void)initView {
    
    CGFloat tableHeight = self.funcDataArray.count * 30;
    self.tableView.frame = CGRectMake(0, 64, self.view.frame.size.width, tableHeight);
    [self.view addSubview:self.tableView];
    
    CGFloat webView_Y = self.tableView.frame.origin.y + self.tableView.frame.size.height;
    self.webView.frame = CGRectMake(0, webView_Y, self.view.frame.size.width, self.view.frame.size.height - webView_Y);
    [self.view addSubview:self.webView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"weizhangfenxi" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:path];
    
//    NSURL *url = [NSURL URLWithString:@"https://www.jianshu.com/u/2809c84474f6"];
//    NSURL *url = [NSURL URLWithString:@"http://pay.egintra.com:8080/wzfx/wzfx/html/weizhangfenxi.html"];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}



// MARK: - 截图

- (void)takeSnapshotOfVisibleContent {
    UIImage *image = [self.webView takeSnapshotOfVisibleContent];
    //展示截图：TODO
    
    //保存截图到文件：
    //NSString *path_document = NSHomeDirectory();
    //设置一个图片的存储路径
    //NSString *imagePath = [path_document stringByAppendingString:@"/Documents/picc.png"];
    //把图片直接保存到指定的路径
    //同时应该把图片的路径imagePath存起来，下次就可以直接用来取
    //[UIImagePNGRepresentation(cutImage) writeToFile:imagePath atomically:YES];
    
    //保存截图到照片
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(completedWithImage:error:context:), NULL);
}
- (void)sync_takeSnapshotOfFullContent {
    UIImage *image = [self.webView takeSnapshotOfFullContent];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(completedWithImage:error:context:), NULL);
}
- (void)async_takeSnapshotOfFullContent_bySpliter {
    [SVProgressHUD show];
    [self.webView.scrollView asyncTakeSnapshotOfFullContent:^(UIImage * _Nullable image) {
        [SVProgressHUD dismiss];
        //保存截图到照片
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(completedWithImage:error:context:), NULL);
    }];
}
- (void)async_takeSnapshotOfFullContent_byPrinter {
    [SVProgressHUD show];
    [self.webView asyncTakeSnapshotOfFullContent:^(UIImage * _Nullable image) {
        [SVProgressHUD dismiss];
        //保存截图到照片
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(completedWithImage:error:context:), NULL);
    }];
    
}

- (void)completedWithImage:(UIImage *)image error:(NSError *)error context:(void *)contextInfo{
    NSString *toast = (!image || error)? [NSString stringWithFormat:@"保存图片失败 , 错误：%@",error] : @"保存图片成功";
    NSLog(@"%@",toast);
    [SVProgressHUD showInfoWithStatus:toast];
}

// MARK: - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.funcDataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.funcDataArray[indexPath.row];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
            [self takeSnapshotOfVisibleContent];
            break;
        case 1:
            [self sync_takeSnapshotOfFullContent];
            break;
        case 2:
            [self async_takeSnapshotOfFullContent_bySpliter];
            break;
        case 3:
            [self async_takeSnapshotOfFullContent_byPrinter];
            break;
            
        default:
            break;
    }
}
//MARK: - Get
- (NSArray *)funcDataArray {
    if (!_funcDataArray) {
        _funcDataArray = @[@"截图可视区域",
                           @"同步截图全部区域",
                           @"异步截图全部区域_分页截图方式",
                           @"异步截图全部区域_打印PDF方式"];
    }
    return _funcDataArray;
}
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}
- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] init];
        _webView.backgroundColor = UIColor.lightGrayColor;
    }
    return _webView;
}
@end
