#import "Util.h"
#import "ViewDelegate.h"

#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>
#import <cassert>

constexpr NSTimeInterval FrameDuration = 16.66 / 1000.0; // 16.66 ms
constexpr MTLClearColor  ClearColour   = { 0.1, 0.2, 0.5, 1.0 };
constexpr NSRect         WindowRect    = {
               {   0,   0},
               {1280, 720}
};

int
main( int, char ** )
{
   [NSApplication sharedApplication];

   NSError *Errors;

   NSWindow *Window = [[NSWindow alloc]
       initWithContentRect:WindowRect
                 styleMask:( NSWindowStyleMaskTitled |
                             NSWindowStyleMaskClosable |
                             NSWindowStyleMaskMiniaturizable )
                   backing:NSBackingStoreBuffered
                     defer:NO];

   GOT_HERE();

   [Window setTitle:@"Esther messing around with Metal"];
   [Window center];

   MTKView      *MetalView = [[MTKView alloc] initWithFrame:WindowRect];
   ViewDelegate *Delegate  = [ViewDelegate new];

   GOT_HERE();

   id<MTLDevice> Device = [Delegate getDevice];

   [MetalView setDevice:Device];
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
