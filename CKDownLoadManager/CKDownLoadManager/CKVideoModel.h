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

@class CKVideoModel;


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
