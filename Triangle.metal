#import <metal_math>
#import "ShaderDecls.h"

struct VertexIn {
   float4 Position [[attribute(attributes::Position)]];
};

struct VertexOut {
   float4 Position [[position]];
   unsigned ID;
};

vertex VertexOut
VertMain( uint VertexID [[vertex_id]], VertexIn Input [[stage_in]] )
{
   return (VertexOut) {
      .Position = Input.Position,
      .ID       = VertexID,
   };
}

fragment float4
FragMain( VertexOut Input [[stage_in]] )
{
   constexpr float4 Colour[3] = {
      float4(1, 0, 0, 1),
      float4(0, 1, 0, 1),
      float4(0, 0, 1, 1)
   };

   return Colour[Input.ID];
}