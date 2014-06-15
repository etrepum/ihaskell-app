#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "DirectoryChooser.h"

BOOL isDirectory(NSString* dir) {
    NSFileManager* manager = [[NSFileManager alloc] init];
    BOOL isDir = false;
    BOOL exists = [manager fileExistsAtPath:dir isDirectory:&isDir];
    return exists && isDir;
}

@implementation DirectoryChooser

- (DirectoryChooser*) initWithDirectory: (NSString*) directory {
    self = [super init];
    _directory = directory;
    return self; 
}

- (void) chooseDirectory:(id) sender {
    // Create the alert with a textbox input view.
    NSAlert *alert = [NSAlert alertWithMessageText:@"Enter Notebook Directory: "
                                     defaultButton:@"OK"
                                     alternateButton:@"Cancel"
                                         otherButton:nil
                           informativeTextWithFormat:@""];
    NSTextField* input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 300, 40)];
    [input setStringValue:_directory];
    [alert setAccessoryView:input];

    // Run the alert.
    NSInteger result = [alert runModal];

    // If we get a success, store new directory.
    if (result == NSAlertDefaultReturn) {
        NSString* newDirectory = [[input stringValue] stringByExpandingTildeInPath];
        if(isDirectory(newDirectory)) {
            _directory = [newDirectory copy];
        } else {
            NSAlert* errorAlert = [[NSAlert alloc] init];
            [errorAlert setMessageText:[@"Invalid Directory: " stringByAppendingString:newDirectory]];
            [errorAlert runModal];
        }
    }
}

@end
