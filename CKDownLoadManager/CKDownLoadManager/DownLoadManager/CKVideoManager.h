//
//  ZXVideoManager.h
//  CKDownLoadManager
//
//  Created by Yck on 16/7/1.
//  Copyright © 2016年 CK. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKVideoModel;

@interface CKVideoManager : NSObject

@property (nonatomic, readonly, strong) NSArray *videoModels;

+ (instancetype)shared;

- (void)addVideoModels:(NSArray<CKVideoModel *> *)videoModels;

- (void)startWithVideoModel:(CKVideoModel *)videoModel;
- (void)suspendWithVideoModel:(CKVideoModel *)videoModel;
- (void)suspendAllVideoModel;
- (void)resumeWithVideoModel:(CKVideoModel *)videoModel;
- (void)stopWiethVideoModel:(CKVideoModel *)videoModel;

@end
