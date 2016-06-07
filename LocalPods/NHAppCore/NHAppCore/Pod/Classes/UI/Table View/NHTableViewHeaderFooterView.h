//
//  NHTableViewHeaderFooterView.h
//  Pods
//
//  Created by Sergey Minakov on 17.09.15.
//
//

#import <UIKit/UIKit.h>

@interface NHTableViewHeaderFooterView<__covariant T> : UITableViewHeaderFooterView

- (void)reset;
- (void)reload:(T)value;

@end
