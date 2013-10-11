/*extern number width;
extern number height;
*/
extern number lightCount = 0;
extern number intensities[4];
extern vec2 positions[4];
extern vec4 colors[4];

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
{
  vec4 texcolor = Texel(texture, texture_coords);
  
  for (int i = 0 ; i < lightCount ; i++)
  {
    number d = distance(pixel_coords, positions[i]);
      
    if (d <= intensities[i])
    {
      texcolor.a *= 1 - d / intensities[i];
      texcolor.rgb = colors[i].rgb * (1 - d / intensities[i]);
    }
  }
  
  return texcolor;
}
