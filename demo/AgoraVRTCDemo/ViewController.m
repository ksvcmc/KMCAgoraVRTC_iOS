//
//  ViewController.m
//  AgoraVRTCDemo
//
//  Created by 张俊 on 05/07/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView *tbView;
@property (nonatomic,strong)NSMutableArray *array;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title =@"连麦demo";
    [self.view addSubview:self.tbView];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    NSDictionary *dic = [self.array objectAtIndex:indexPath.row];
    cell.textLabel.text =[dic valueForKey:@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = [self.array objectAtIndex:indexPath.row];
    UIViewController *vc = [[NSClassFromString([dic valueForKey:@"className"]) alloc]init];
    vc.title = [dic objectForKey:@"title"];
    [self.navigationController pushViewController:vc animated:YES];
}


- (UITableView *)tbView
{
    if (!_tbView) {
        _tbView = [[UITableView alloc]initWithFrame:self.view.frame];
        _tbView.delegate =self;
        _tbView.dataSource =self;
        _tbView.tableFooterView = [UIView new];
    }
    
    return  _tbView;
}

- (NSMutableArray *)array
{
    if (!_array) {
        NSArray *arr = @[@{@"title":@"原始连麦版本",
                           @"className":@"KSYPresetCfgVC"},
                         @{@"title":@"1v1PK",
                           @"className":@"KSY1V1PKViewController"}];
        _array = [[NSMutableArray alloc]initWithArray:arr];
    }
    return _array;
}


@end
