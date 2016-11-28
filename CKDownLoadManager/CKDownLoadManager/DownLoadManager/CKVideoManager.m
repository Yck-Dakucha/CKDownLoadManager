//
//  ZXVideoManager.m
//  CKDownLoadManager
//
//  Created by Yck on 16/7/1.
//  Copyright © 2016年 CK. All rights reserved.
//

#import "CKVideoManager.h"
#import "CKVideoOperation.h"
#import "CKVideoModelProtocol.h"

static CKVideoManager *_sg_videoManager = nil;

@interface CKVideoManager ()<NSURLSessionDownloadDelegate> {
    NSMutableArray *_videoModels;
}
@property (nonatomic, strong) NSMutableDictionary *operationDic;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation CKVideoManager

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sg_videoManager = [[self alloc] init];
    });
    return _sg_videoManager;
}

- (instancetype)init {
    if (self = [super init]) {
        _videoModels = [[NSMutableArray alloc] init];
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 4;
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        // 不能传self.queue
        self.session = [NSURLSession sessionWithConfiguration:config
                                                     delegate:self
                                                delegateQueue:nil];
    }
    
    return self;
}

- (NSArray *)videoModels {
    return _videoModels;
}

- (void)addVideoModels:(NSArray<id<CKVideoModelProtocol>> *)videoModels {
    if ([videoModels isKindOfClass:[NSArray class]]) {
        [_videoModels addObjectsFromArray:videoModels];
    }
}

- (void)startWithVideoModel:(id<CKVideoModelProtocol>)videoModel {
    if (videoModel.videoStatus != kCKVideoStatusCompleted) {
        videoModel.videoStatus = kCKVideoStatusRunning;
        CKVideoOperation *tempOperation = [self.operationDic valueForKey:videoModel.videoUrl];
        if (tempOperation == nil) {
            tempOperation = [[CKVideoOperation alloc] initWithModel:videoModel
                                                                    session:self.session];
            [self.queue addOperation:tempOperation];
            [self.operationDic setObject:tempOperation forKey:videoModel.videoUrl];
            [tempOperation start];
            [_videoModels addObject:videoModel];
        } else {
            [tempOperation resume];
        }
    }
}

- (void)suspendWithVideoModel:(id<CKVideoModelProtocol>)videoModel {
    if (videoModel.videoStatus != kCKVideoStatusCompleted) {
        videoModel.videoStatus = kCKVideoStatusSuspended;
        CKVideoOperation *tempOperation = [self.operationDic valueForKey:videoModel.videoUrl];
        if (tempOperation == nil) {
            tempOperation = [[CKVideoOperation alloc] initWithModel:videoModel
                                                            session:self.session];
            [self.queue addOperation:tempOperation];
            [self.operationDic setObject:tempOperation forKey:videoModel.videoUrl];
        }
        [tempOperation suspend];
    }
}

- (void)suspendAllVideoModel {
    for (id<CKVideoModelProtocol> videoModel in self.videoModels) {
        @autoreleasepool {
            [self suspendWithVideoModel:videoModel];
        }
    }
}

- (void)resumeWithVideoModel:(id<CKVideoModelProtocol>)videoModel {
    if (videoModel.videoStatus != kCKVideoStatusCompleted) {
        videoModel.videoStatus = kCKVideoStatusRunning;
        CKVideoOperation *tempOperation = [self.operationDic valueForKey:videoModel.videoUrl];
        if (tempOperation == nil) {
            tempOperation = [[CKVideoOperation alloc] initWithModel:videoModel
                                                            session:self.session];
            [self.queue addOperation:tempOperation];
            [self.operationDic setObject:tempOperation forKey:videoModel.videoUrl];
        }
        [tempOperation resume];
    }
}

- (void)stopWiethVideoModel:(id<CKVideoModelProtocol>)videoModel {
    CKVideoOperation *tempOperation = [self.operationDic valueForKey:videoModel.videoUrl];
    if (tempOperation) {
        [tempOperation cancel];
    }
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    
    //本地的文件路径，使用fileURLWithPath:来创建
    if (downloadTask.zx_videoModel.localPath) {
        NSString *filePath = [downloadTask.zx_videoModel.localPath stringByAppendingPathComponent:downloadTask.zx_videoModel.fileName];
        NSURL *toURL = [NSURL fileURLWithPath:filePath isDirectory:NO];
        NSFileManager *manager = [NSFileManager defaultManager];
        NSString *videoPath = downloadTask.zx_videoModel.localPath;
        BOOL existed = [manager fileExistsAtPath:videoPath];
        if (!existed) {
            NSError *error;
            [manager createDirectoryAtPath:videoPath withIntermediateDirectories:NO attributes:nil error:&error];
            if (error) {
                NSLog(@"ERROR >>>>> %@",error);
            }
        }
        NSError *error;
        [manager moveItemAtURL:location toURL:toURL error:&error];
        if (error) {
            NSLog(@"ERROR >>>>> %@",error);
        }
    }
    NSString *key = downloadTask.zx_videoModel.videoUrl;
    CKVideoOperation *operation = self.operationDic[key];
    [operation downloadFinished];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error == nil) {
            CKVideoOperation *operation = [self.operationDic objectForKey:task.zx_videoModel.videoUrl];
            [operation downloadFinished];
            NSFileManager *manager = [NSFileManager defaultManager];
            NSString *pathName = [task.zx_videoModel.resumePath stringByAppendingPathComponent:task.zx_videoModel.fileName];
            NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:pathName];
            if ([manager fileExistsAtPath:filePath]) {
                NSError *error;
                [manager removeItemAtPath:filePath error:&error];
                if (error) {
                    NSLog(@"删除缓存错误 >>> %@",error);
                }
            }
            task.zx_videoModel.videoStatus = kCKVideoStatusCompleted;
            [_videoModels removeObject:task.zx_videoModel];
        } else if ([error code] < 0) {
            // 网络异常
            task.zx_videoModel.videoStatus = kCKVideoStatusFailed;
        }else if (task.zx_videoModel.videoStatus == kCKVideoStatusSuspended) {
            task.zx_videoModel.videoStatus = kCKVideoStatusSuspended;
        }
    });
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    double byts =  totalBytesWritten * 1.0 / 1024 / 1024;
    double total = totalBytesExpectedToWrite * 1.0 / 1024 / 1024;
    NSString *text = [NSString stringWithFormat:@"%.1lfMB/%.1fMB",byts,total];
    CGFloat progress = totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([downloadTask.zx_videoModel respondsToSelector:@selector(setProgressText:)]) {
             downloadTask.zx_videoModel.progressText = text;
        }
        if ([downloadTask.zx_videoModel respondsToSelector:@selector(setProgress:)]) {
            downloadTask.zx_videoModel.progress = progress;
        }
        if ([downloadTask.zx_videoModel respondsToSelector:@selector(setTotalBytesWritten:)]) {
            downloadTask.zx_videoModel.totalBytesWritten = totalBytesWritten;
        }
        if ([downloadTask.zx_videoModel respondsToSelector:@selector(setTotalBytesExpectedToWrite:)]) {
            downloadTask.zx_videoModel.totalBytesExpectedToWrite = totalBytesExpectedToWrite;
        }
    });
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    double byts =  fileOffset * 1.0 / 1024 / 1024;
    double total = expectedTotalBytes * 1.0 / 1024 / 1024;
    NSString *text = [NSString stringWithFormat:@"%.1lfMB/%.1fMB",byts,total];
    CGFloat progress = fileOffset / (CGFloat)expectedTotalBytes;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([downloadTask.zx_videoModel respondsToSelector:@selector(setProgressText:)]) {
            downloadTask.zx_videoModel.progressText = text;
        }
        if ([downloadTask.zx_videoModel respondsToSelector:@selector(setProgress:)]) {
            downloadTask.zx_videoModel.progress = progress;
        }
        if ([downloadTask.zx_videoModel respondsToSelector:@selector(setTotalBytesWritten:)]) {
            downloadTask.zx_videoModel.totalBytesWritten = fileOffset;
        }
        if ([downloadTask.zx_videoModel respondsToSelector:@selector(setTotalBytesExpectedToWrite:)]) {
            downloadTask.zx_videoModel.totalBytesExpectedToWrite = expectedTotalBytes;
        }
    });
}

@end
