//
//  ZXVideoOperation.h
//  CKDownLoadManager
//
//  Created by Yck on 16/7/1.
//  Copyright © 2016年 CK. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKVideoModel;

@interface NSURLSessionTask (VideoModel)

@property (nonatomic, weak) CKVideoModel *zx_videoModel;

@end

@interface CKVideoOperation : NSOperation

- (instancetype)initWithModel:(CKVideoModel *)model session:(NSURLSession *)session;

@property (nonatomic, weak) CKVideoModel *model;
@property (nonatomic, strong, readonly) NSURLSessionDownloadTask *downloadTask;

- (void)suspend;
- (void)resume;
- (void)downloadFinished;

@end
