#import <Cocoa/Cocoa.h>
#import <MetalKit/MetalKit.h>

@interface ViewDelegate : NSObject <MTKViewDelegate>

- (instancetype)init;
- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size;
- (void)drawInMTKView:(MTKView *)view;

@end