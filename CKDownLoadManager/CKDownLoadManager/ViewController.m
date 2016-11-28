//
//  ViewController.m
//  CKDownLoadManager
//
//  Created by Yck on 16/7/1.
//  Copyright © 2016年 CK. All rights reserved.
//

#import "ViewController.h"
#import "CKVideoModel.h"
#import "CKVideoManager.h"

#define kBaseURL @"请修改成自己的URL，这里去掉了，因为是项目中的！"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSArray *urls = @[@"27", @"15", @"26", @"19", @"25", @"17",
                      @"23", @"22", @"18", @"20", @"16", @"24",
                      @"14"];
    NSMutableArray *videoModels = [[NSMutableArray alloc] init];
    for (NSString *uid in urls) {
        CKVideoModel *model = [[CKVideoModel alloc] init];
        model.fileName = [NSString stringWithFormat:@"%@.pdf",uid];
        model.videoUrl = @"http://192.168.3.125/test.pdf";
        model.localPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        model.resumePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/VideoTemp"];
        model.title = [NSString stringWithFormat:@"测试下载视频标题：%@", uid];
        [videoModels addObject:model];
    }
    [[CKVideoManager shared] addVideoModels:videoModels];
    [self.tableView reloadData];
    self.tableView.tableFooterView = [[UIView alloc] init];

}

#pragma mark -  tableView dataSource & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section  {
    return [CKVideoManager shared].videoModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    CKVideoModel *model = [CKVideoManager shared].videoModels[indexPath.row];
    cell.textLabel.text = model.title;
    cell.detailTextLabel.text = model.progressText;
    model.videoStatusChanged = ^(CKVideoModel *videomodel,CKVideoStatus videoStatus){
        NSLog(@"status >>>>  %ld",(long)videoStatus);
    };
    model.videoProgressChanged = ^(CKVideoModel *videomodel,CGFloat progress) {
        NSInteger index = [[CKVideoManager shared].videoModels indexOfObject:videomodel];
        UITableViewCell *downLoadCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        downLoadCell.detailTextLabel.text = videomodel.progressText;
    };
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CKVideoModel *model = [CKVideoManager shared].videoModels[indexPath.row];
    [[CKVideoManager shared] startWithVideoModel:model];
}



@end
