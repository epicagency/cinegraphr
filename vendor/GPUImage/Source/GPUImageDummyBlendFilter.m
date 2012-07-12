#import "GPUImageDummyBlendFilter.h"

NSString *const kGPUImageDummyBlendFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 void main()
 {
   lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
   lowp vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate);
   
   gl_FragColor = textureColor2;
 }
 );

@implementation GPUImageDummyBlendFilter

- (id)init;
{
  if (!(self = [super initWithFragmentShaderFromString:kGPUImageDummyBlendFragmentShaderString]))
  {
		return nil;
  }
  
  return self;
}

@end
