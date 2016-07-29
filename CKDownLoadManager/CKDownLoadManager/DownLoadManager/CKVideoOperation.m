//
//  ZXVideoOperation.m
//  CKDownLoadManager
//
//  Created by Yck on 16/7/1.
//  Copyright © 2016年 CK. All rights reserved.
//

#import "CKVideoOperation.h"
#import <objc/runtime.h>

#define kKVOBlock(KEYPATH, BLOCK) \
[self willChangeValueForKey:KEYPATH]; \
BLOCK(); \
[self didChangeValueForKey:KEYPATH];

static NSTimeInterval kTimeoutInterval = 60.0;

@interface CKVideoOperation () {
    BOOL _finished;
    BOOL _executing;
}

@property (nonatomic, strong) NSURLSessionDownloadTask *task;
@property (nonatomic, weak  ) NSURLSession             *session;
@property (nonatomic, strong) NSData                   *resumeData;
@property (nonatomic, assign) CKVideoStatus            videoStatus;
@property (nonatomic, assign) CGFloat                  progress;

@end

@implementation CKVideoOperation

- (NSData *)resumeData {
    NSData *data = [NSData dataWithContentsOfFile:[self.model performSelector:@selector(resumePath)]];
    if (data.bytes) {
        return data;
    }else {
        return nil;
    }
}

- (void)setVideoStatus:(CKVideoStatus)videoStatus {
    _videoStatus = videoStatus;
    if ([self.model respondsToSelector:@selector(videoStateDidChanged:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.model performSelector:@selector(videoStateDidChanged:) withObject:@(_videoStatus)];
        });
    }
}

- (instancetype)initWithModel:(id<CKVideoModelProtocol>)model session:(NSURLSession *)session {
    if (self == [super init]) {
        _model = model;
        _session = session;
        _videoStatus = (CKVideoStatus)[self.model performSelector:@selector(videoStatus)];
        [self statRequest];
    }
    return self;
}

- (void)dealloc {
    self.task = nil;
}

- (void)setTask:(NSURLSessionDownloadTask *)task {
    [_task removeObserver:self forKeyPath:@"state"];
    
    if (_task != task) {
        _task = task;
    }
    
    if (task != nil) {
        [task addObserver:self
               forKeyPath:@"state"
                  options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)statRequest {
    NSURL *url = [NSURL URLWithString:[self.model performSelector:@selector(videoUrl)]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTimeoutInterval];
    self.task = [self.session downloadTaskWithRequest:request];
    [self configTask];
}

- (void)configTask {
    self.task.zx_videoModel = self.model;
}

- (void)start {
    if (self.isCancelled) {
        kKVOBlock(@"isFinished", ^{
            _finished = YES;
        });
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    if (self.resumeData) {
        [self resume];
    } else {
        [self.task resume];
        self.videoStatus = kCKVideoStatusRunning;
    }
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isExecuting {
    return _executing;
}

- (BOOL)isFinished {
    return _finished;
}

- (BOOL)isConcurrent {
    return YES;
}

- (void)suspend {
    if (self.task) {
        __weak __typeof(self) weakSelf = self;
        __block NSURLSessionDownloadTask *weakTask = self.task;
        [self willChangeValueForKey:@"isExecuting"];
        __block BOOL isExecuting = _executing;
        
        [self.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            NSFileManager *manager = [NSFileManager defaultManager];
            NSString *kVideoTempPath = [self.model performSelector:@selector(resumePath)];
            BOOL existed = [manager fileExistsAtPath:kVideoTempPath];
            if (!existed) {
                NSError *error;
                [manager createDirectoryAtPath:kVideoTempPath withIntermediateDirectories:YES attributes:nil error:&error];
                if (error) {
                    NSLog(@"ERROR >>>>> %@",error);
                }
            }
            NSString *pathName = [NSString stringWithFormat:@"Documents/VideoTemp/%@.mp4",[weakSelf.model performSelector:@selector(filename)]];
            NSString *firePath = [NSHomeDirectory() stringByAppendingPathComponent:pathName];
            [resumeData writeToFile:firePath options:NSDataWritingAtomic error:nil];

            weakTask = nil;
            isExecuting = NO;
            [weakSelf didChangeValueForKey:@"isExecuting"];
            weakSelf.videoStatus = kCKVideoStatusSuspended;
        }];
        [self.task suspend];
    }
}

- (void)resume {
    if (self.videoStatus == kCKVideoStatusCompleted) {
        return;
    }
    self.videoStatus = kCKVideoStatusRunning;
    
    if (self.resumeData) {
        self.task = [self.session downloadTaskWithResumeData:self.resumeData];
        [self configTask];
    } else if (self.task == nil
               || (self.task.state == NSURLSessionTaskStateCompleted && self.progress < 1.0)) {
        [self statRequest];
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    [self.task resume];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (NSURLSessionDownloadTask *)downloadTask {
    return self.task;
}

- (void)cancel {
    [self willChangeValueForKey:@"isCancelled"];
    [super cancel];
    [self.task cancel];
    self.task = nil;
    [self didChangeValueForKey:@"isCancelled"];
    
    [self completeOperation];
}

- (void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    _executing = NO;
    _finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"state"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.task.error code] < 0) {
                self.videoStatus = kCKVideoStatusFailed;
                return ;
            }
            switch (self.task.state) {
                case NSURLSessionTaskStateSuspended: {
                    self.videoStatus = kCKVideoStatusSuspended;
                    break;
                }
                case NSURLSessionTaskStateCompleted:
                    if (self.progress >= 1.0) {
                        self.videoStatus = kCKVideoStatusCompleted;
                    } else {
                        self.videoStatus = kCKVideoStatusSuspended;
                    }
                default:
                    break;
            }
        });
    }
}

- (void)downloadFinished {
    [self completeOperation];
}

@end

static const void *videoModelKey = "videoModelKey";

@implementation NSURLSessionTask (VideoModel)

- (void)setZx_videoModel:(id<CKVideoModelProtocol>)zx_videoModel {
    objc_setAssociatedObject(self, videoModelKey, zx_videoModel, OBJC_ASSOCIATION_ASSIGN);
}

- (id<CKVideoModelProtocol>)zx_videoModel {
    return objc_getAssociatedObject(self, videoModelKey);
}

@end