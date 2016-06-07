//
//  NHWebViewController.m
//  Pods
//
//  Created by Sergey Minakov on 01.06.15.
//
//

#import "NHWebViewController.h"

@interface NHWebViewController ()<UIWebViewDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NHWebViewTitleView *titleView;

@property (nonatomic, weak) UIBarButtonItem *backButton;
@property (nonatomic, weak) UIBarButtonItem *forwardButton;
@property (nonatomic, weak) UIBarButtonItem *updateButton;

@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic, strong) NSURL *lastUrl;

@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, assign) long long currentProgressSize;

@end

@implementation NHWebViewController

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    self.webView = [[UIWebView alloc] init];
    self.webView.scalesPageToFit = YES;
    [self.webView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.webView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.webView.delegate = self;
    
    [self.view addSubview:self.webView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:0]];
    
    self.titleView = [[NHWebViewTitleView alloc]
                      initWithFrame:CGRectMake(0,
                                               0,
                                               self.view.frame.size.width,
                                               self.view.frame.size.width > self.view.frame.size.height
                                               ? 30 : 42)];
    self.titleView.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = self.titleView;
    
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    self.progressView.progress = 0;
    self.progressView.progressTintColor = [UIColor blueColor];
    
    
    [self.view addSubview:self.progressView];
    [self.progressView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.progressView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.progressView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.progressView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
}

- (void)viewWillLayoutSubviews {
    self.titleView.frame = CGRectMake(0,
                                      0,
                                      self.view.frame.size.width,
                                      self.view.frame.size.width > self.view.frame.size.height
                                      ? 30 : 42);
    
    [self.titleView setState:self.titleView.currentState];
    
    [super viewWillLayoutSubviews];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setToolbarItems:(NSArray *)toolbarItems animated:(BOOL)animated {
    [super setToolbarItems:toolbarItems animated:animated];
    
    self.backButton = self.toolbarItems[0];
    self.forwardButton = self.toolbarItems[1];
    self.updateButton = self.toolbarItems[3];
    
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
}

- (void)setUrlPath:(NSString*)urlPath {
    NSURL *url = [NSURL URLWithString:urlPath];
    [self setUrl:url];
}

- (void)setUrl:(NSURL*)url {
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:urlRequest];
}

- (void)updateCurrentPage {
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:self.lastUrl];
    [self.webView loadRequest:urlRequest];
}

- (void)moveToPreviousPage {
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }
}

- (void)moveToNextPage {
    if (self.webView.canGoForward) {
        [self.webView goForward];
    }
}

- (void)openInSafari {
    NSURL *url = [NSURL URLWithString:self.lastUrl.absoluteString];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)copyLink {
    [[UIPasteboard generalPasteboard] setString:self.lastUrl.absoluteString];
}


//MARK: web view delegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.progressView.hidden = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.progressView.hidden = YES;
    [self.titleView setState:NHWebViewTitleViewStateText];
    self.titleView.titleLabel.text = [self webPageTitle];
    self.titleView.urlLabel.text = [self webPageUrl];
    [self updateButtonState];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    self.progressView.hidden = YES;
    [self.titleView setState:NHWebViewTitleViewStateFailed];
    [self updateButtonState];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if ([request.URL.absoluteString isEqualToString:@"about:blank"]) {
        return NO;
    }
    
    if (self.lastUrl == nil || navigationType != UIWebViewNavigationTypeOther) {
        self.progressView.hidden = NO;
        self.lastUrl = request.URL;
        [self.titleView setState:NHWebViewTitleViewStateLoading];
        self.titleView.urlLabel.text = [self webPageUrlForRequest:request];
    }
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (!connection) {
        return NO;
    }
    
    return YES;
}

- (NSString*)webPageTitle {
    NSString *documentTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    return (documentTitle && [documentTitle isKindOfClass:[NSString class]] && [documentTitle length] > 0)
    ? documentTitle
    : @" ";
}

- (NSString*)webPageUrl {
    return [self.lastUrl.absoluteString.lowercaseString
            stringByTrimmingCharactersInSet:[NSCharacterSet
                                             whitespaceAndNewlineCharacterSet]];
}

- (NSString*)webPageUrlForRequest:(NSURLRequest*)request {
    return [request.URL.absoluteString.lowercaseString
            stringByTrimmingCharactersInSet:[NSCharacterSet
                                             whitespaceAndNewlineCharacterSet]];
}

//MARK: URL connection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([response isKindOfClass:[NSHTTPURLResponse class]]
        && ((NSHTTPURLResponse*)response).statusCode == 200) {
        self.response = (NSHTTPURLResponse*)response;
        self.currentProgressSize = 0;
        [self updateProgress];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    self.currentProgressSize += [data length];
    
    [self updateProgress];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.webView.delegate webView:self.webView didFailLoadWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.webView.delegate webViewDidFinishLoad:self.webView];
}

- (void)updateProgress {
    if (self.response.expectedContentLength
        && self.response.expectedContentLength != NSURLResponseUnknownLength) {
        float value = (float)self.currentProgressSize / (float)self.response.expectedContentLength;
        self.progressView.progress = value;
    }
    else {
        self.progressView.progress = 0;
    }
}

- (void)updateButtonState {
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
}

@end
