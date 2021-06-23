#import <metal_math>

struct VertexOut {
   float4 Position [[position]];
};

vertex VertexOut
VertMain(uint VertexID [[vertex_id]])
{
   float4 Triangle[3] = {
      float4( -1, 0, 0, 1 ),
      float4(  1, 0, 0, 1 ),
      float4(  0, 1, 0, 1 )
   };

   return (VertexOut) {
      .Position = Triangle[VertexID],
   };
}

fragment float4
FragMain(VertexOut input [[stage_in]])
{
   return metal::fabs(input.Position);
}