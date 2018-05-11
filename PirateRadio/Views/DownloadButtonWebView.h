//
//  DownloadButtonWebView.h
//  PirateRadio
//
//  Created by A-Team User on 11.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@class VideoModel;

@interface DownloadButtonWebView : WKWebView <WKNavigationDelegate,WKUIDelegate>

@property (strong, nonatomic) VideoModel *videoModel;

@end
