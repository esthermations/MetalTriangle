#import <metal_math>

struct VertexOut {
   float4 Position [[position]];
   unsigned ID;
};

vertex VertexOut
VertMain(uint VertexID [[vertex_id]])
{
   float4 Triangle[3] = {
      float4( -0.5, -0.5, 0, 1 ),
      float4(  0.5, -0.5, 0, 1 ),
      float4(  0,    0.5, 0, 1 )
   };

   return (VertexOut) {
      .Position = Triangle[VertexID],
      .ID       = VertexID,
   };
}

fragment float4
FragMain(VertexOut input [[stage_in]])
{
   constexpr float4 Colour[3] = {
      float4(1, 0, 0, 1),
      float4(0, 1, 0, 1),
      float4(0, 0, 1, 1)
   };

   return Colour[input.ID];
}