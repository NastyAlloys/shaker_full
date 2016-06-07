//
//  NHSearchTextField.m
//  Pods
//
//  Created by Sergey Minakov on 13.08.15.
//
//

#import "NHSearchTextField.h"

const CGFloat kNHSearchTextFieldMinLeftInset = 5;
//const UIEdgeInsets kNHSearchTextFieldInsets = (UIEdgeInsets) { .left = 25, .right = 20 };


@interface NHSearchTextField ()

@property (nonatomic, strong) id textChange;
@property (nonatomic, assign) UIEdgeInsets textInset;
@property (nonatomic, assign) NSTextAlignment nhTextAlignment;
@end

@implementation NHSearchTextField

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    [super setTextAlignment:NSTextAlignmentLeft];
    _nhTextAlignment = textAlignment;
    [self resetTextInsets];
}

- (NSTextAlignment)textAlignment {
    return NSTextAlignmentLeft;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self resetTextInsets];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [self resetTextInsets];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self nhCommonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self nhCommonInit];
    }
    
    return self;
}

- (void)nhCommonInit {
    [self addObserver:self
           forKeyPath:@"text"
              options:NSKeyValueObservingOptionNew
              context:nil];
    
    __weak __typeof(self) weakSelf = self;
    self.textChange = [[NSNotificationCenter defaultCenter]
                       addObserverForName:UITextFieldTextDidChangeNotification
                       object:self
                       queue:nil usingBlock:^(NSNotification *note) {
                           __strong __typeof(weakSelf) strongSelf = weakSelf;
                           [strongSelf changeText:strongSelf.text];
                       }];
    
//    self.textAlignment = NSTextAlignmentCenter;
    [self resetTextInsets];
    
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return UIEdgeInsetsInsetRect(bounds, self.textInset);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return UIEdgeInsetsInsetRect(bounds, self.textInset);
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    CGRect rect = [super leftViewRectForBounds:bounds];
    rect.origin.x = self.textInset.left - rect.size.width - 5;
    
    return rect;
}

- (void)setLeftView:(UIView *)leftView {
    [super setLeftView:leftView];
    
    [self resetTextInsets];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    
    [self resetTextInsets];
}

- (void)setPlaceholder:(NSString *)placeholder {
    [super setPlaceholder:placeholder];
    
    [self resetTextInsets];
}

- (void)resetTextInsets {
    switch (_nhTextAlignment) {
        case NSTextAlignmentLeft: {
            CGFloat value = (self.leftView
                             ? self.leftView.bounds.size.width + 5
                             : 5);
            self.textInset = UIEdgeInsetsMake(0, MAX(kNHSearchTextFieldMinLeftInset, value), 0, 20);
        } break;
        default: {
            CGSize size = [self.placeholder
                           boundingRectWithSize:self.bounds.size
                           options:NSStringDrawingUsesDeviceMetrics|NSStringDrawingUsesFontLeading
                           attributes:@{ NSFontAttributeName : self.font ?: [UIFont systemFontOfSize:17]}
                           context:nil].size;
            
            CGFloat value = (self.bounds.size.width - size.width) / 2;
            
            self.textInset = UIEdgeInsetsMake(0, MAX((self.leftView ? self.leftView.bounds.size.width : 0) + kNHSearchTextFieldMinLeftInset, value), 0, 20);
        } break;
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [self setNeedsDisplay];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (object == self
        && [keyPath isEqualToString:@"text"]) {
        NSString *newText = change[NSKeyValueChangeNewKey];
        [self changeText:newText];
    }
}

- (void)changeText:(NSString*)text {
    __weak __typeof(self) weakSelf = self;
    
    if ([weakSelf.nhDelegate respondsToSelector:@selector(nhSearchTextField:didChangeText:)]) {
        [weakSelf.nhDelegate nhSearchTextField:weakSelf didChangeText:text];
    }
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"dealloc search text field");
#endif
    self.nhDelegate = nil;
    self.delegate = nil;
    
    [self removeObserver:self
              forKeyPath:@"text"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.textChange];
}

@end
