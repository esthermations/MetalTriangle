#import "ViewDelegate.h"

#import "ShaderDecls.h"
#import "Util.h"

#import <Foundation/Foundation.h>
#import <Metal/MTLBuffer.h>
#import <Metal/MTLResource.h>
#import <cassert>


namespace vertex_data
{
   constexpr simd::float4 Triangle[ 3 ] = {
       {-0.5, -0.5, 0, 1},
       { 0.5, -0.5, 0, 1},
       {   0,  0.5, 0, 1}
   };

   constexpr simd::float4 UpsideDownTriangle[ 3 ] = {
       {-0.5,  0.5, 0, 1},
       { 0.5,  0.5, 0, 1},
       {   0, -0.5, 0, 1}
   };
}


static void
FillDescriptorArray( MTLVertexAttributeDescriptorArray *Array )
{
   assert( Array );
   Array[ attributes::Position ].format      = MTLVertexFormatFloat3;
   Array[ attributes::Position ].offset      = 0;
   Array[ attributes::Position ].bufferIndex = 0;
}


@implementation ViewDelegate

id<MTLDevice>              Device;
id<MTLCommandQueue>        Queue;
id<MTLLibrary>             Library;
id<MTLRenderPipelineState> Pipeline;

id<MTLBuffer> TriangleVertexBuffer;
id<MTLBuffer> UpsideDownTriangleVertexBuffer;

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

   TriangleVertexBuffer =
       [Device newBufferWithBytes:&vertex_data::Triangle
                           length:( 3 * 4 * sizeof( float ) )
                          options:MTLResourceStorageModeManaged];

   UpsideDownTriangleVertexBuffer =
       [Device newBufferWithBytes:&vertex_data::UpsideDownTriangle
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

   bool DrawUpsideDown = ( ( FrameNumber % 200 ) < 100 );

   NSLog(
       @"Frame %u : Triangle is %s", FrameNumber,
       DrawUpsideDown ? "upside-down" : "right-side-up"
   );

   // Draw a triangle
   {
      if ( not DrawUpsideDown )
      {
         [Encoder pushDebugGroup:@"Drawing a triangle"];
         [Encoder setVertexBuffer:TriangleVertexBuffer offset:0 atIndex:0];
         [Encoder drawPrimitives:MTLPrimitiveTypeTriangle
                     vertexStart:0
                     vertexCount:3];
         [Encoder popDebugGroup];
      }
      else
      {
         [Encoder pushDebugGroup:@"Drawing an upside-down triangle"];
         [Encoder setVertexBuffer:UpsideDownTriangleVertexBuffer
                           offset:0
                          atIndex:0];
         [Encoder drawPrimitives:MTLPrimitiveTypeTriangle
                     vertexStart:0
                     vertexCount:3];
         [Encoder popDebugGroup];
      }
   }

   [Encoder endEncoding];
   [CmdBuf presentDrawable:Drawable];
   [CmdBuf commit];
}


@end