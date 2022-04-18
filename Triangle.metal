#import <metal_math>
#import "ShaderDecls.h"

struct VertexIn {
   float4 Position [[attribute(attributes::Position)]];
};

struct VertexOut {
   float4 Position [[position]];
   uint   ID;
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
   float4 Colour = metal::abs(Input.Position);
   return Colour;
}