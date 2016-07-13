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
@property (nonatomic, strong) NSArray *dataArray;

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
        model.videoUrl = [NSString stringWithFormat:@"%@/pages/mnks23/voide/1/course2/%@.MP4",
                          kBaseURL, uid];
        model.imageUrl = [NSString stringWithFormat:@"%@/pages/mnks23/imageurl/1/course2/%@.jpg",
                          kBaseURL, uid];
        model.videoId = uid;
        model.title = [NSString stringWithFormat:@"测试下载视频标题：%@", uid];
        [videoModels addObject:model];
    }
    [[CKVideoManager shared] addVideoModels:videoModels];

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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    CKVideoModel *model = self.dataArray[indexPath.row];
    cell.textLabel.text = model.title;
    cell.detailTextLabel.text = [NSString ]
}



@end
