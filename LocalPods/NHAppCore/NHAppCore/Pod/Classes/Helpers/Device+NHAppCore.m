//
//  Device+NHAppCore.m
//  Pods
//
//  Created by Sergey Minakov on 01.10.15.
//
//

#import "Device+NHAppCore.h"

extern BOOL isIPad() {
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

extern BOOL isIPhone() {
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
}

extern UIImage * _Nullable takeScreenshot(UIView * _Nullable view, CGRect screenshotRect) {
    if (view) {
        UIImage *resultImage;
        UIGraphicsBeginImageContextWithOptions(screenshotRect.size, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        if (context) {
            CGContextConcatCTM(context,
                               CGAffineTransformMakeTranslation(
                                                                -screenshotRect.origin.x,
                                                                -screenshotRect.origin.y));
            
            if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
                [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
            }
            else {
                
                [view.layer renderInContext:context];
            }
            
            resultImage = UIGraphicsGetImageFromCurrentImageContext();
        }
        UIGraphicsEndImageContext();
        
        return resultImage;
    }
    
    return nil;
}


extern NSString * _Nullable pathForDirectory(NSSearchPathDirectory directory, NSString *path) {
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES).firstObject;
    return [documentsDirectory stringByAppendingPathComponent:path];
}

extern BOOL pathExistsForDirectory(NSSearchPathDirectory directory, NSString *path) {
    return [[NSFileManager defaultManager] fileExistsAtPath:pathForDirectory(directory, path)];
}

extern BOOL removeAtPathForDirectory(NSSearchPathDirectory directory, NSString *path) {
    return [[NSFileManager defaultManager] removeItemAtPath:pathForDirectory(directory, path) error:nil];
}

extern NSDictionary * _Nullable pathDataInDirectory(NSSearchPathDirectory directory, NSString *path) {
    return [[NSFileManager defaultManager] attributesOfItemAtPath:pathForDirectory(directory, path)
                                                            error:nil];
}

extern NSString * _Nullable createFolderInDirectory(NSSearchPathDirectory directory, NSString *folderName) {
    NSError *error;
    NSString *folderPath = pathForDirectory(directory, folderName);
    BOOL directoryExists = NO;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath isDirectory:&directoryExists]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:&error];
    }
    else {
        return directoryExists ? folderPath : nil;
    }
    
    if (error) {
        return nil;
    }
    
    return folderPath;
}

extern NSString * _Nullable createFileInDirectory(NSSearchPathDirectory directory, NSString *fileName) {
    NSString *filePath = pathForDirectory(directory, fileName);
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        if (![[NSFileManager defaultManager] createFileAtPath:filePath
                                                     contents:nil
                                                   attributes:nil]) {
            return nil;
        }
    }
    else {
        return nil;
    }
    
    return filePath;
}

extern NSString * _Nullable createFileInDirectoryFolder(NSSearchPathDirectory directory, NSString *folderName, NSString *fileName) {
    NSString *folderPath = createFolderInDirectory(directory, folderName);
    
    if (folderPath) {
        NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            if ([[NSFileManager defaultManager] createFileAtPath:filePath
                                                        contents:nil
                                                      attributes:nil]) {
                return filePath;
            }
        }
    }
    
    return nil;
}