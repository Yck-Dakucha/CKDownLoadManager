//
//  ZXVideoOperation.h
//  CKDownLoadManager
//
//  Created by Yck on 16/7/1.
//  Copyright © 2016年 CK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKVideoModelProtocol.h"

@interface NSURLSessionTask (VideoModel)

@property (nonatomic, weak) id<CKVideoModelProtocol> zx_videoModel;

@end

@interface CKVideoOperation : NSOperation

- (instancetype)initWithModel:(id<CKVideoModelProtocol>)model session:(NSURLSession *)session;

@property (nonatomic, weak) id<CKVideoModelProtocol> model;
@property (nonatomic, strong, readonly) NSURLSessionDownloadTask *downloadTask;

- (void)suspend;
- (void)resume;
- (void)downloadFinished;

@end
