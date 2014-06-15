#import "Browser.h"

@interface Browser()
    @property WebView* webview;
@end

@implementation Browser

+(Browser*) browserWithURL: (NSString*) url {
    NSString* name = [[NSProcessInfo processInfo] processName];
    Browser* window = [[Browser alloc] 
        initWithContentRect:NSMakeRect(0, 0, 800, 700) 
                  styleMask:NSTitledWindowMask   | NSResizableWindowMask
                    backing:NSBackingStoreBuffered defer:NO];
    [window cascadeTopLeftFromPoint:NSMakePoint(20,20)];
    [window setTitle:name];
    [window makeKeyAndOrderFront:nil];

    window.webview = [[WebView alloc] init];
    [window.webview setMaintainsBackForwardList: NO];
    [window setContentView: window.webview];
    [window.webview setMainFrameURL:url];
    [window.webview setUIDelegate:window];
    [window.webview lockFocus];

    // Set to have webview focused immediately Otherwise, need to click once to
    // focus window, once to focus webview, once to activate link.
    [window makeFirstResponder: window.webview];
    return window;
}

// Allow links to open in the same tab even with target=_blank.
- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request {
    [[sender mainFrame] loadRequest:request];
    return sender;
}

@end
