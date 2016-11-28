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

typedef void(^CKVideoStatusChanged)(id<CKVideoModelProtocol>,CKVideoStatus videoStatus);
typedef void(^CKVideoProgressChanged)(id<CKVideoModelProtocol>,CGFloat progress);

@required

/**
 文件保存名
 */
@property (nonatomic, copy) NSString *fileName;
/**
 *  下载对象下载地址
 *
 *  @return
 */
@property (nonatomic, copy) NSString *videoUrl;
/**
 *  缓存位置
 *
 *  @return
 */
@property (nonatomic, copy) NSString *resumePath;
/**
 *  本地下载对象存储位置
 *
 *  @return
 */
@property (nonatomic, copy) NSString *localPath;
/**
 *  下载对象当前状态
 *
 *  @return
 */
@property (nonatomic, assign) CKVideoStatus videoStatus;

@optional

/**
 下载进度
 */
@property (nonatomic, assign) CGFloat progress;
/**
 下载进度 0.0M/10.0M
 */
@property (nonatomic, copy) NSString *progressText;
/**
 当前下载量  单位Bytes
 */
@property (nonatomic, assign) int64_t totalBytesWritten;
/**
 文件大小 单位Bytes
 */
@property (nonatomic, assign) int64_t totalBytesExpectedToWrite;

/**
 下载状态变化的回调
 */
@property (nonatomic, copy) CKVideoStatusChanged videoStatusChanged;

/**
 下载进度变化的回调
 */
@property (nonatomic, copy) CKVideoProgressChanged videoProgressChanged;


///**
// *  下载对象状态发生变化回调
// *
// *  @param state 对象状态
// */
//- (void)ck_videoStateDidChanged:(CKVideoStatus)state;
///**
// *  下载进度发生变化
// *
// *  @param progress          进度百分比
// *  @param vodeoDownLoadSize 已下载大小
// *  @param videoSize         目标总大小
// */
//- (void)ck_videoProgressDidChanged:(CGFloat)progress
//              videoDownLoadSize:(long long)vodeoDownLoadSize
//                      videoSize:(long long)videoSize;
///**
// *  网速变化回调
// *
// *  @param videoDownloadSpeed 网速
// */
//- (void)ck_videoSpeedDidChanged:(int)videoDownloadSpeed;

@end
