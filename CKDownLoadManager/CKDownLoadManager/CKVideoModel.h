//
//  CKVideoModel.h
//  CKDownLoadManager
//
//  Created by Yck on 16/7/1.
//  Copyright © 2016年 CK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CKVideoModel;

typedef NS_ENUM(NSInteger, CKVideoStatus) {
    kCKVideoStatusNone = 0,       // 初始状态
    kCKVideoStatusRunning = 1,    // 下载中
    kCKVideoStatusSuspended = 2,  // 下载暂停
    kCKVideoStatusCompleted = 3,  // 下载完成
    kCKVideoStatusFailed  = 4,    // 下载失败
    kCKVideoStatusWaiting = 5    // 等待下载
};

typedef void(^CKVideoStatusChanged)(CKVideoModel *model);
typedef void(^CKVideoProgressChanged)(CKVideoModel *model);

@interface CKVideoModel : NSObject

@property (nonatomic, copy) NSString *videoId;
@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong        ) NSString               *fileName;
//记录断点下载
@property (nonatomic, strong        ) NSData                 *resumeData;
@property (nonatomic, strong        ) NSString               *resumePath;
// 下载后存储到此处
@property (nonatomic, copy          ) NSString               *localPath;
@property (nonatomic, copy          ) NSString               *progressText;
@property (nonatomic, assign        ) CGFloat                progress;
@property (nonatomic, assign        ) CKVideoStatus          status;
@property (nonatomic, readonly, copy) NSString               *statusText;
//@property (nonatomic, strong) CKVideoOperation *operation;
@property (nonatomic, copy          ) CKVideoStatusChanged   onStatusChanged;
@property (nonatomic, copy          ) CKVideoProgressChanged onProgressChanged;

@end
