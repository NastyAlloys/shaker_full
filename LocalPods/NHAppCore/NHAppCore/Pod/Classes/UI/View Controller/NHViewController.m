//
//  NHViewController.m
//  Pods
//
//  Created by Sergey Minakov on 17.09.15.
//
//

#import "NHViewController.h"

@interface NHViewController ()

@end

@implementation NHViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIView performWithoutAnimation:^{
        [self.searchController hideSearch];
    }];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.searchController showSearch];
}

- (void)dealloc {
    self.searchController.nhDelegate = nil;
    self.searchController = nil;
}

@end
