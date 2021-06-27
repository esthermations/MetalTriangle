#import "ViewDelegate.h"

#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <cassert>

constexpr NSRect         WindowRect    = {{0, 0}, {1280, 720}};
constexpr NSTimeInterval FrameDuration = 16.66 / 1000.0; // 16.66 ms
constexpr MTLClearColor  ClearColour   = {0.1, 0.2, 0.5, 1.0};

int
main(int, char **)
{
   [NSApplication sharedApplication];

   NSError *Errors;

   NSWindow *Window =
       [[NSWindow alloc] initWithContentRect:WindowRect
                                   styleMask:(NSWindowStyleMaskTitled |
                                              NSWindowStyleMaskClosable |
                                              NSWindowStyleMaskMiniaturizable)
                                     backing:NSBackingStoreBuffered
                                       defer:NO];

   [Window setTitle:@"Esther messing around with Metal"];
   [Window center];

   MTKView *     MetalView = [[MTKView alloc] initWithFrame:WindowRect];
   ViewDelegate *Delegate  = [ViewDelegate new];

   [MetalView setDevice:[Delegate getDevice]];
   [MetalView setDelegate:Delegate];
   [MetalView setFramebufferOnly:YES];
   [MetalView setColorPixelFormat:MTLPixelFormatBGRA8Unorm];
   [MetalView setAutoResizeDrawable:NO];
   [MetalView setDrawableSize:WindowRect.size];
   [MetalView setClearColor:ClearColour];
   [MetalView setEnableSetNeedsDisplay:NO];

   [Window setContentView:MetalView];
   [Window makeKeyAndOrderFront:nil];

   [MetalView setPaused:NO];

   [NSApp run];
}
