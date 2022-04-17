#import "ViewDelegate.h"

#import "ShaderDecls.h"
#import "Util.h"

#import <Foundation/Foundation.h>
#import <Metal/MTLBuffer.h>
#import <Metal/MTLResource.h>
#import <cassert>


static void
FillDescriptorArray( MTLVertexAttributeDescriptorArray *Array )
{
   assert( Array );
   Array[ attributes::Position ].format      = MTLVertexFormatFloat3;
   Array[ attributes::Position ].offset      = 0;
   Array[ attributes::Position ].bufferIndex = 0;
}


@implementation ViewDelegate

constexpr simd::packed::float4 TriangleVertexData[ 3 ] = {
    {-0.5, -0.5, 0, 1},
    { 0.5, -0.5, 0, 1},
    {   0,  0.5, 0, 1}
};

static_assert(
    sizeof( TriangleVertexData ) == ( 3 * 4 * sizeof( float ) ), ""
);

id<MTLDevice>              Device;
id<MTLCommandQueue>        Queue;
id<MTLLibrary>             Library;
id<MTLRenderPipelineState> Pipeline;
id<MTLBuffer>              VertexBuffer;

NSError *Errors;


- (id<MTLDevice>)getDevice
{
   assert( Device );
   return Device;
}


- (instancetype)init
{
   self = [super init];

   Device  = MTLCreateSystemDefaultDevice();
   Queue   = [Device newCommandQueue];
   Library = [Device newLibraryWithFile:@"Triangle.metallib" error:&Errors];

   util::ReportErrors( Errors );

   GOT_HERE();

   VertexBuffer = [Device newBufferWithBytes:&TriangleVertexData
                                      length:( 3 * 4 * sizeof( float ) )
                                     options:MTLResourceStorageModeManaged];

   id<MTLFunction> VertShader = [Library newFunctionWithName:@"VertMain"];
   id<MTLFunction> FragShader = [Library newFunctionWithName:@"FragMain"];

   auto *PipelineDesc = [MTLRenderPipelineDescriptor new];
   [PipelineDesc setVertexFunction:VertShader];
   [PipelineDesc setFragmentFunction:FragShader];

   GOT_HERE();

   auto *VertexDescriptor = [MTLVertexDescriptor vertexDescriptor];
   FillDescriptorArray( VertexDescriptor.attributes );

   VertexDescriptor.layouts[ 0 ].stride = ( 4 * sizeof( float ) );

   GOT_HERE();

   [PipelineDesc setVertexDescriptor:VertexDescriptor];
   [PipelineDesc setLabel:@"Triangle Pipeline Descriptor"];

   PipelineDesc.colorAttachments[ 0 ].pixelFormat = MTLPixelFormatBGRA8Unorm;

   GOT_HERE();

   Pipeline = [Device newRenderPipelineStateWithDescriptor:PipelineDesc
                                                     error:&Errors];

   GOT_HERE();

   util::ReportErrors( Errors );
   assert( Pipeline );

   return self;
}


- (void)mtkView:(MTKView *)View drawableSizeWillChange:(CGSize)size
{
   NSLog( @"%s doing nothing.", __PRETTY_FUNCTION__ );
}


- (void)drawInMTKView:(MTKView *)View
{
   assert( View );

   static unsigned FrameNumber = 0;
   NSLog( @"Drawing frame %u", FrameNumber );
   ++FrameNumber;

   id<CAMetalDrawable> Drawable = [View currentDrawable];
   assert( Drawable );

   MTLRenderPassDescriptor *PassDesc = [View currentRenderPassDescriptor];
   assert( PassDesc );

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
      [Encoder setVertexBuffer:VertexBuffer offset:0 atIndex:0];
      [Encoder drawPrimitives:MTLPrimitiveTypeTriangle
                indirectBuffer:VertexBuffer
          indirectBufferOffset:0];
      [Encoder popDebugGroup];
   }

   [Encoder endEncoding];
   [CmdBuf presentDrawable:Drawable];
   [CmdBuf commit];
}


@end