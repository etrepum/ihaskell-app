#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <Webkit/Webkit.h>

@interface Browser : NSWindow

+(Browser*) browserWithURL: (NSString*) url;

@end
