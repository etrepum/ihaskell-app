#import <Foundation/Foundation.h>
#import <ChromiumTabs/ChromiumTabs.h>

@interface Browser : CTBrowser
-(void)closeCurrentTab: (id) sender;
-(void)openNewTab: (id) sender;
@end

@interface ToolbarController : CTToolbarController
- (ToolbarController*) init;
@end

@interface TabContents : CTTabContents
@end
