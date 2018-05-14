//
//  DownloadButtonWebView.m
//  PirateRadio
//
//  Created by A-Team User on 11.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "DownloadButtonWebView.h"
#import "VideoModel.h"
#import "DownloadModel.h"
#import "YoutubeDownloadManager.h"

@implementation DownloadButtonWebView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.navigationDelegate = self;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
}
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSLog(@"decidePolicyForNavigationResponse");
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)navigationResponse.response;
    BOOL isMp3 = [[[httpResponse allHeaderFields] objectForKey:@"Content-Type"] isEqualToString:@"audio/mpeg"];
    BOOL isMp32 = [[[httpResponse allHeaderFields] objectForKey:@"Content-Type"] isEqualToString:@"application/force-download"];
    if (isMp3 || isMp32) {
        
        DownloadModel *download = [[DownloadModel alloc] initWithVideoModel:self.videoModel andURL:httpResponse.URL];
        [YoutubeDownloadManager.sharedInstance downloadVideoWithDownloadModel:download];
        
        decisionHandler(WKNavigationResponsePolicyCancel);
        NSLog(@"Cancel response");
    }
    else {
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
}





@end
