#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <Webkit/Webkit.h>
#import <ChromiumTabs/ChromiumTabs.h>
#import "Browser.h"

@interface TabContents()
@property WebView* webview;
@end

@implementation Browser
- (CTBrowser*) init {
    self = [super init];
    return self;
}

- (CTToolbarController *)createToolbarController {
    return [[ToolbarController alloc] init];
}

-(CTTabContents*)createBlankTabBasedOn:(CTTabContents*)baseContents {
  // Create a new instance of my tab type.
  return [[TabContents alloc] initWithBaseTabContents:baseContents];
}

- (void) closeCurrentTab: (id) sender {
    [self closeTab];
    [self selectPreviousTab];
}
- (void) openNewTab: (id) sender {
    [self addBlankTabInForeground:YES];
    [self.windowController close];
    [self.windowController showWindow:self];
}
- (void) openNewWindow: (id) sender {
    [self newWindow];
}

@end

@implementation ToolbarController
- (ToolbarController*) init {
    NSView* view = [[BackgroundGradientView alloc] init];
    self = [super init];
    [self setView:view];
    return self;
}
@end

@implementation TabContents

// Allow links to open in the same tab even with target=_blank.
- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request {
    [[sender mainFrame] loadRequest:request];
    return sender;
}

-(id)initWithBaseTabContents:(CTTabContents*)baseContents {
    NSLog(@"New tab 2");
    _webview = [[WebView alloc] init];
    [_webview setMainFrameURL: @"http://127.0.0.1:8778/tree"];
    [_webview setUIDelegate:self];
    self.view = _webview;
    return self;
}

@end
