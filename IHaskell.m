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
NSMutableDictionary* directoryToUrl = NULL;
NSString* latestDirectory = NULL;
NSString* ihaskellPath = @"/Users/silver/.cabal/bin/ihaskell";

NSInteger findAvailablePort() {
	for (unsigned short port = 7777; port < 9000; port++) {
		NSSocketPort *socket = [[NSSocketPort alloc] initWithTCPPort:port];
		if (socket) {
			[socket invalidate];
			return port;
		}
	}
	return 0;
}

NSString* runIHaskellAsync() {
    // Find a port on which we can launch this
    NSInteger port = findAvailablePort();

    // Environment
    NSDictionary *env = @{
        @"IHASKELL_IPYTHON_ARGS" : [NSString stringWithFormat:@"--no-browser --port=%ld", port],
                         @"HOME" : NSHomeDirectory(),
                         @"PATH" : @"/usr/local/bin:/bin",
    };

    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath: ihaskellPath];
    [task setEnvironment: env];

    NSArray *arguments = [NSArray arrayWithObjects:@"notebook", @"-s", directoryChooser.directory, nil];
    [task setArguments: arguments];

    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    [task launch];
    
    // Give it a little bit of time to start it
    [NSThread sleepForTimeInterval: 1.0];

    return [NSString stringWithFormat:@"http://127.0.0.1:%ld/tree", port];
}

NSString* currentNotebookListURL(){
    // First time called
    if (directoryToUrl == NULL) {
        directoryToUrl = [@{
            directoryChooser.directory : runIHaskellAsync(),
        } mutableCopy];
        latestDirectory = directoryChooser.directory;
    } 

    // Directory has changed
    else if (![latestDirectory isEqualToString:directoryChooser.directory]) {
        [directoryToUrl setObject:runIHaskellAsync() forKey:directoryChooser.directory];
        latestDirectory = directoryChooser.directory;
    }

    NSString* url = [directoryToUrl objectForKey:directoryChooser.directory];
    NSLog(@"Loading %@", url);
    return url;
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
