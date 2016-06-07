//
//  Device+NHAppCore.h
//  Pods
//
//  Created by Sergey Minakov on 01.10.15.
//
//

@import UIKit;

#define SYSTEM_VERSION_EQUAL_TO(v) \
([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)

#define SYSTEM_VERSION_GREATER_THAN(v) \
([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) \
([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define SYSTEM_VERSION_LESS_THAN(v) \
([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v) \
([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

NS_ASSUME_NONNULL_BEGIN

extern BOOL isIPad();
extern BOOL isIPhone();

extern UIImage * _Nullable takeScreenshot(UIView * _Nullable view, CGRect screenshotRect);


extern NSString * _Nullable pathForDirectory(NSSearchPathDirectory directory, NSString *path);
extern BOOL removeAtPathForDirectory(NSSearchPathDirectory directory, NSString *path);
extern BOOL pathExistsForDirectory(NSSearchPathDirectory directory, NSString *path);
extern NSDictionary * _Nullable pathDataInDirectory(NSSearchPathDirectory directory, NSString *path);
extern NSString * _Nullable createFolderInDirectory(NSSearchPathDirectory directory, NSString *folderName);
extern NSString * _Nullable createFileInDirectory(NSSearchPathDirectory directory, NSString *fileName);
extern NSString * _Nullable createFileInDirectoryFolder(NSSearchPathDirectory directory, NSString *folderName, NSString *fileName);

NS_ASSUME_NONNULL_END