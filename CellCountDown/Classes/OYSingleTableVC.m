//
//  ViewController.m
//  CellCountDown
//
//  Created by herobin on 16/9/11.
//  Copyright © 2016年 herobin. All rights reserved.
//

#import "OYSingleTableVC.h"
#import "OYModel.h"
#import "OYTableViewCell.h"
#import "OYCountDownManager.h"

@interface OYSingleTableVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation OYSingleTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"单个列表倒计时";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    
    // 启动倒计时管理
    [kCountDownManager start];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OYTableViewCell *cell = (OYTableViewCell *)[tableView dequeueReusableCellWithIdentifier:OYTableViewCellID];
    // 传递模型
    OYModel *model = self.dataSource[indexPath.row];
    cell.model = model;
    [cell setCountDownZero:^(OYModel *timeOutModel){
        // 回调 
        if (!timeOutModel.timeOut) {
            NSLog(@"SingleTableVC--%@--时间到了", timeOutModel.title);
        }
        // 标志
        timeOutModel.timeOut = YES;
    }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

#pragma mark - 刷新数据
- (void)reloadData {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 模拟网络请求
        self.dataSource = nil;
        // 调用reload
        [kCountDownManager reload];
        // 刷新
        [self.tableView reloadData];
        // 停止刷新
        [self.tableView.refreshControl endRefreshing];
    });
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.refreshControl = [[UIRefreshControl alloc] init];
        [_tableView.refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
        [_tableView registerClass:NSClassFromString(OYTableViewCellID) forCellReuseIdentifier:OYTableViewCellID];
    }
    return _tableView;
}

- (NSArray *)dataSource {
    if (_dataSource == nil) {
        NSMutableArray *arrM = [NSMutableArray array];
        for (NSInteger i=0; i<50; i++) {
            // 模拟从服务器取得数据 -- 例如:服务器返回的数据为剩余时间数
            NSInteger count = arc4random_uniform(100); //生成0-100之间的随机正整数
            OYModel *model = [[OYModel alloc]init];
            model.count = count;
            model.title = [NSString stringWithFormat:@"第%zd条数据", i];
            [arrM addObject:model];
        }
        _dataSource = arrM.copy;
    }
    return _dataSource;
}

- (void)dealloc {
    // 废除定时器
    [kCountDownManager invalidate];
    // 清空时间差
    [kCountDownManager reload];
}

@end
