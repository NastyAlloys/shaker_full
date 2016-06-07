//
//  NHTableViewCell.h
//  Pods
//
//  Created by Sergey Minakov on 17.09.15.
//
//

#import <UIKit/UIKit.h>

@interface NHTableViewCell<__covariant T> : UITableViewCell

- (void)reset;
- (void)reload:(T)value;

@end
