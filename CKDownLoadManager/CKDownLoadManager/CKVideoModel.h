//
//  CKVideoModel.h
//  CKDownLoadManager
//
//  Created by Yck on 16/7/1.
//  Copyright © 2016年 CK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CKVideoModelProtocol.h"

@interface CKVideoModel : NSObject<CKVideoModelProtocol>

@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *title;

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

/**
 下载进度
 */
@property (nonatomic, assign) CGFloat progress;
/**
 下载进度 0.0M/10.0M
 */
@property (nonatomic, copy) NSString *progressText;

/**
 下载状态变化的回调
 */
@property (nonatomic, copy) CKVideoStatusChanged videoStatusChanged;
/**
 下载进度变化的回调
 */
@property (nonatomic, copy) CKVideoProgressChanged videoProgressChanged;



@end
