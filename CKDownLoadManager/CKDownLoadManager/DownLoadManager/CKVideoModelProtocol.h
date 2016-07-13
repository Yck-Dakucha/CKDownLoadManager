//
//  CKVideoModelProtocol.h
//  CKDownLoadManager
//
//  Created by Yck on 16/7/13.
//  Copyright © 2016年 CK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CKVideoStatus) {
    kCKVideoStatusNone = 0,       // 初始状态
    kCKVideoStatusRunning = 1,    // 下载中
    kCKVideoStatusSuspended = 2,  // 下载暂停
    kCKVideoStatusCompleted = 3,  // 下载完成
    kCKVideoStatusFailed  = 4,    // 下载失败
    kCKVideoStatusWaiting = 5    // 等待下载
};

@protocol CKVideoModelProtocol <NSObject>

@required
- (NSString *)videoUrl;

@optional
- (void)videoStateDidChanged:(CKVideoStatus)state;

- (void)videoProgressDidChanged:(CGFloat)progress
              videoDownLoadSize:(long long)vodeoDownLoadSize
                      videoSize:(long long)videoSize;

- (void)videoSpeedDidChanged:(int)videoDownloadSpeed;

@end
