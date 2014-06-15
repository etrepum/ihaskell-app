#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <Webkit/Webkit.h>
#import "DirectoryChooser.h"
#import "Browser.h"

@interface BrowserManager : NSObject
  -(Browser*) newBrowserWindow: (id) sender;
  -(void) quitBrowser: (id) sender;
  @property NSMutableArray* browsers;
@end

DirectoryChooser* directoryChooser = NULL;

NSString* currentNotebookListURL(){
    return @"http://127.0.0.1:8778/tree";
}

@implementation BrowserManager
  -(Browser*) newBrowserWindow: (id) sender {
    if(_browsers == NULL) {
        _browsers = [[NSMutableArray alloc] init];
    }

    Browser* browser = [Browser browserWithURL:currentNotebookListURL()];
    [_browsers addObject: browser];

    NSButton *closeButton = [browser standardWindowButton:NSWindowCloseButton];
    [closeButton setEnabled:YES];

    return browser;
  }

  -(void) quitBrowser: (id) sender {
      [[NSApp keyWindow] close];
  }
@end

void setupMenuBar(Browser* browser, BrowserManager* manager) {
    NSString* name = [[NSProcessInfo processInfo] processName];

    // Create the menus.
    NSMenu* toplevelMenu = [[NSMenu alloc] init];
    NSMenu* appMenu = [[NSMenu alloc] init];
    NSMenu* fileMenu = [[NSMenu alloc] initWithTitle:@"File"];

    // Link the menus together.
    NSMenuItem* appItem = [[NSMenuItem alloc] init];
    NSMenuItem* fileItem = [[NSMenuItem alloc] init];

    [appItem setSubmenu:appMenu];
    [fileItem setSubmenu:fileMenu];

    [toplevelMenu addItem:appItem];
    [toplevelMenu addItem:fileItem];

    // Put things in submenus.
    NSMenuItem* dirItem = [[NSMenuItem alloc] init];
    [dirItem setTarget:directoryChooser];
    [dirItem setAction:@selector(chooseDirectory:)];
    [dirItem setTitle:@"Set Notebook Directory"];
    [dirItem setKeyEquivalent:@"d"];
    [fileMenu addItem:dirItem];

    NSMenuItem* closeItem = [[NSMenuItem alloc] init];
    [closeItem setTarget:manager];
    [closeItem setAction:@selector(quitBrowser:)];
    [closeItem setTitle:@"Close Window"];
    [closeItem setKeyEquivalent:@"w"];
    [fileMenu addItem:closeItem];

    NSMenuItem* newWinItem = [[NSMenuItem alloc] init];
    [newWinItem setTarget:manager];
    [newWinItem setAction:@selector(newBrowserWindow:)];
    [newWinItem setTitle:@"New Window"];
    [newWinItem setKeyEquivalent:@"n"];
    [fileMenu addItem:newWinItem];

    [appMenu addItemWithTitle:[@"Quit " stringByAppendingString:name]
                       action:@selector(terminate:)
                keyEquivalent:@"q"];
    [NSApp setMainMenu:toplevelMenu];
}

int main() {
    // Create the single application that can run.
    [NSApplication sharedApplication];

    // Set the global directory chooser which chooses the notebook dir.
    directoryChooser = [[DirectoryChooser alloc] initWithDirectory: NSHomeDirectory()];

    // Set the activation policy to the standard one:
    // This app appears in the dock, has a UI, etc.
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];

    // Set up the menu bar and window.
    BrowserManager* manager = [[BrowserManager alloc] init];
    Browser* browser = [manager newBrowserWindow:nil];
    setupMenuBar(browser, manager);

    // Run the application.
    [NSApp run];
    return 0;
}
