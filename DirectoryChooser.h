#import <Foundation/Foundation.h>

@interface DirectoryChooser : NSObject

@property (readonly) NSString* directory;

- (DirectoryChooser*) initWithDirectory: (NSString*) directory;
- (void) chooseDirectory:(id) sender;

@end
