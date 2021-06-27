#import "ViewDelegate.h"

#import <Foundation/Foundation.h>
#import <cassert>

@implementation ViewDelegate

id<MTLDevice>              Device;
id<MTLCommandQueue>        Queue;
id<MTLLibrary>             Library;
id<MTLRenderPipelineState> Pipeline;

NSError *Errors;

- (id<MTLDevice>)getDevice
{
   assert(Device);
   return Device;
}

- (instancetype)init
{
   self = [super init];

   Device  = MTLCreateSystemDefaultDevice();
   Queue   = [Device newCommandQueue];
   Library = [Device newLibraryWithFile:@"Triangle.metallib" error:&Errors];

   if (Errors) {
      NSLog(@"%@", Errors);
      assert(not Errors);
   }

   id<MTLFunction> VertShader = [Library newFunctionWithName:@"VertMain"];
   id<MTLFunction> FragShader = [Library newFunctionWithName:@"FragMain"];

   auto *PipelineDesc = [MTLRenderPipelineDescriptor new];
   [PipelineDesc setVertexFunction:VertShader];
   [PipelineDesc setFragmentFunction:FragShader];

   PipelineDesc.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;

   Pipeline = [Device newRenderPipelineStateWithDescriptor:PipelineDesc
                                                     error:&Errors];
   assert(Pipeline);

   return self;
}

- (void)mtkView:(MTKView *)View drawableSizeWillChange:(CGSize)size
{
   NSLog(@"%s doing nothing.", __PRETTY_FUNCTION__);
}

- (void)drawInMTKView:(MTKView *)View
{
   assert(View);

   static unsigned FrameNumber = 0;
   NSLog(@"Drawing frame %u", FrameNumber);
   ++FrameNumber;

   id<CAMetalDrawable> Drawable = [View currentDrawable];
   assert(Drawable);

   MTLRenderPassDescriptor *PassDesc = [View currentRenderPassDescriptor];
   assert(PassDesc);

   auto CmdBuf  = [Queue commandBuffer];
   auto Encoder = [CmdBuf renderCommandEncoderWithDescriptor:PassDesc];

   [Encoder setRenderPipelineState:Pipeline];

   constexpr MTLViewport Viewport = {
       .originX = 0,
       .originY = 0,
       .width   = 1280.0,
       .height  = 720.0,
       .znear   = 0.0,
       .zfar    = 1.0,
   };

   [Encoder setViewport:Viewport];

   // Draw a triangle
   {
      [Encoder pushDebugGroup:@"Drawing a triangle"];
      [Encoder drawPrimitives:MTLPrimitiveTypeTriangle
                  vertexStart:0
                  vertexCount:3];
      [Encoder popDebugGroup];
   }

   [Encoder endEncoding];
   [CmdBuf presentDrawable:Drawable];
   [CmdBuf commit];
}

@end