#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

#import "ViewDelegate.h"

constexpr NSRect WindowRect = {.origin = {0, 0}, .size = {1280, 720}};

int
main(int, char **) {
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
   [Window makeKeyAndOrderFront:nil];

   MTKView *MetalView = [[MTKView alloc] initWithFrame:WindowRect];

   id<MTLDevice>       Device = MTLCreateSystemDefaultDevice();
   id<MTLCommandQueue> Queue  = [Device newCommandQueue];
   id<MTLLibrary> Library     = [Device newLibraryWithFile:@"Triangle.metallib"
                                                 error:&Errors];

   ViewDelegate *Delegate = [ViewDelegate init];

   [MetalView setDevice:Device];
   [MetalView setDelegate:Delegate];
   [MetalView setFramebufferOnly:YES];
   [MetalView setColorPixelFormat:MTLPixelFormatBGRA8Unorm];
   [MetalView setAutoResizeDrawable:NO];

   id<MTLFunction> VertShader = [Library newFunctionWithName:@"VertMain"];
   id<MTLFunction> FragShader = [Library newFunctionWithName:@"FragMain"];

   MTLRenderPipelineDescriptor *PipelineDesc =
       [MTLRenderPipelineDescriptor new];
   [PipelineDesc setVertexFunction:VertShader];
   [PipelineDesc setFragmentFunction:FragShader];

   PipelineDesc.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;

   id<MTLRenderPipelineState> Pipeline =
       [Device newRenderPipelineStateWithDescriptor:PipelineDesc
                                              error:&Errors];

   NSAssert(Pipeline, @"Failed to create a pipeline");

   id<CAMetalDrawable> Drawable = [MetalView currentDrawable];
   NSAssert(Drawable, @"No drawable!");

   [MetalView setClearColor:MTLClearColorMake(0.1, 0.5, 0.1, 1.0)];

   MTLRenderPassDescriptor *PassDesc = [MetalView currentRenderPassDescriptor];
   NSAssert(PassDesc, @"No pass descriptor!");

   constexpr NSTimeInterval FrameDuration = 16.66 / 1000.0;

   while (true) {
      NSDate *Deadline = [NSDate dateWithTimeIntervalSinceNow:FrameDuration];

      id<MTLCommandBuffer> CmdBuf = [Queue commandBuffer];

      id<MTLRenderCommandEncoder> Encoder =
          [CmdBuf renderCommandEncoderWithDescriptor:PassDesc];

      [Encoder setRenderPipelineState:Pipeline];
      [Encoder drawPrimitives:MTLPrimitiveTypeTriangle
                  vertexStart:0
                  vertexCount:3];

      [Encoder popDebugGroup];
      [Encoder endEncoding];

      [CmdBuf commit];

      [NSThread sleepUntilDate:Deadline];
   }
}