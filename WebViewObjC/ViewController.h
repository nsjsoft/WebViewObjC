//
//  ViewController.h
//  WebViewObjC
//
//  Created by metanet on 2022/03/25.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "Reachability.h"

@interface ViewController : UIViewController<WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>
{
    Reachability *internetReach;
}

@property (strong, nonatomic)WKWebView *webView;

@end

