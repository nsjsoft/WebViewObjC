//
//  ViewController.m
//  WebViewObjC
//
//  Created by metanet on 2022/03/25.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UILabel *outputText;
@property (strong, nonatomic) IBOutlet UIView *webViewContainer;

@end

@implementation ViewController
{
    WKWebViewConfiguration *config;
    
    WKUserContentController *contentController;
}

@synthesize webView;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initWebview_then_callFromJs];
    
    [self loadUrl];
}

- (void)initWebview_then_callFromJs {
    config = [[WKWebViewConfiguration alloc] init];
    contentController = [[WKUserContentController alloc] init];
    
    [contentController addScriptMessageHandler:self name:@"hello"];
    [contentController addScriptMessageHandler:self name:@"test"];
    
    [config setUserContentController:contentController];
    [config.preferences setJavaScriptEnabled:TRUE];
    
    self.webView = [[WKWebView alloc] initWithFrame:self.webViewContainer.bounds configuration:config];
    
    self.webView.translatesAutoresizingMaskIntoConstraints = FALSE;
    
    [self.webViewContainer addSubview:webView];
    
    [[[self.webView leadingAnchor] constraintEqualToAnchor:self.webViewContainer.leadingAnchor constant:0] setActive:TRUE];
    
    [[[self.webView trailingAnchor] constraintEqualToAnchor:self.webViewContainer.trailingAnchor constant:0] setActive:TRUE];
    
    [[[self.webView topAnchor] constraintEqualToAnchor:self.webViewContainer.topAnchor constant:0] setActive:TRUE];
    
    [[[self.webView bottomAnchor] constraintEqualToAnchor:self.webViewContainer.bottomAnchor constant:0] setActive:TRUE];
}

- (void)loadUrl {
    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
    
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    
    [self.webView loadRequest:request];
    
    [self.webView setUIDelegate:self];
    [self.webView setNavigationDelegate:self];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self networkCheck];
}

#pragma 네트워크 상태 체크
- (void)networkCheck {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    [self updateInterfaceWithReachability:internetReach];
}

- (void)reachabilityChanged:(NSNotification *)note
{
    Reachability *curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}

- (void)updateInterfaceWithReachability:(Reachability *)curReach
{
    if(curReach == internetReach)
    {
        NetworkStatus netStatus = [curReach currentReachabilityStatus];
        NSString *statusString = @"";
        
        switch (netStatus)
        {
            case NotReachable:
                statusString = @"Access Not Available";
                break;
            case ReachableViaWiFi:
                statusString = @"Reachable WiFi";
                break;
            case ReachableViaWWAN:
                statusString = @"Reachable WWAN";
                break;
            default:
                break;
        }
        
        NSLog(@"Net Status changed. current status=%@", statusString);
    }
}

#pragma mark - WKScriptMessageHandler method

- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    NSLog(@"didReceiveScriptMessage !!!");
    
    if([message.name isEqualToString:@"hello"]) {
        NSString *str = [message body];
        self.outputText.text = str;
    } else if([message.name isEqualToString:@"test"]) {
        NSString *str = [message body];
        self.outputText.text = str;
    }
}

#pragma WKUIDelegate Method 3가지 : javascript와 관련된 트리거 이벤트 캐치

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"알림" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"알림" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"알림" message:prompt preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alert.textFields.firstObject.text);
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(nil);
    }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma WKNavigationDelegate Method : 중복적으로 리로드 방지를 위한 함수
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    [self.webView reload];
}

#pragma WKNavigationDelegate Method

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"- didStartProvisionalNavigation : 웹뷰 로딩시 호출되는 델리게이트 함수");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"- didFinishNavigation : 웹뷰 로딩 완료시 호출되는 델리게이트 함수");
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"- didFailNavigation : 웹뷰 로딩 실패시 호출");
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"- decidePolicyForNavigationAction : 웹뷰 로딩 여부 체크를 위한 델리게이트 함수");
    
    decisionHandler(WKNavigationActionPolicyAllow);
    
}

#pragma 자바스크립트 인터페이스 구현

- (IBAction)home:(UIButton *)sender {
    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
    
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    
    [self.webView loadRequest:request];
}

- (IBAction)back:(UIButton *)sender {
    
    if([self.webView canGoBack]) {
        [self.webView goBack];
    } else {
        NSLog(@"뒤로 갈 페이지가 없습니다.");
    }
}

- (IBAction)forward:(UIButton *)sender {
    if([self.webView canGoForward]) {
        [self.webView goForward];
    } else {
        NSLog(@"앞으로 갈 페이지가 없습니다.");
    }
}

- (IBAction)reload:(UIButton *)sender {
    [self.webView reload];
}

- (IBAction)callJS:(UIButton *)sender {
    
    NSString *funcName = @"myJsFunction()";
    [self.webView evaluateJavaScript:funcName completionHandler:^(NSString *result, NSError * _Nullable error) {
        NSLog(@"result : %@", result);
    }];
}

- (IBAction)callJSWithParams:(UIButton *)sender {
    
    NSString *name = @"mynameis..";
    NSString *age = @"22";
    
    NSString *funcName = [[NSString alloc] initWithFormat:@"myJsFunctionParam('%@', '%@')", name, age];
    
    [self.webView evaluateJavaScript:funcName completionHandler:^(NSString *result, NSError * _Nullable error) {
        
        NSLog(@"result : %@", result);
    }];
}

@end
