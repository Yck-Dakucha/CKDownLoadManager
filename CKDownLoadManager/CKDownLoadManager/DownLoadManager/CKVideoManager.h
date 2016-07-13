//
//  ZXVideoManager.h
//  CKDownLoadManager
//
//  Created by Yck on 16/7/1.
//  Copyright © 2016年 CK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CKVideoModelProtocol.h"


@class CKVideoModel;

@interface CKVideoManager : NSObject

@property (nonatomic, readonly, strong) NSArray *videoModels;

+ (instancetype)shared;

- (void)addVideoModels:(NSArray<id<CKVideoModelProtocol>> *)videoModels;
- (void)startWithVideoModel:(id<CKVideoModelProtocol>)videoModel;
- (void)suspendWithVideoModel:(id<CKVideoModelProtocol>)videoModel;
- (void)suspendAllVideoModel;
- (void)resumeWithVideoModel:(id<CKVideoModelProtocol>)videoModel;
- (void)stopWiethVideoModel:(id<CKVideoModelProtocol>)videoModel;

@end
