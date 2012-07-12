class CMGMaskView < UIView

  attr_reader :points
  attr_accessor :draw_clear

  BUFFER_WIDTH = 640
  BUFFER_HEIGHT = 480

  def drawRect(rect)
    contextRef = UIGraphicsGetCurrentContext()
    CGContextDrawImage(contextRef, self.bounds, @buffer) if @buffer
    self.drawInContext(contextRef)
  end

  def drawInContext(contextRef)
    return if @points.count < 2
    color_ptr = Pointer.new(:float, 4)
    color_ptr[0] = 1.0
    color_ptr[1] = 1.0
    color_ptr[2] = 1.0
    color_ptr[3] = 1.0
    CGContextSetStrokeColor(contextRef, color_ptr)
    CGContextSetBlendMode(contextRef, KCGBlendModeClear) if @draw_clear
    CGContextSetLineWidth(contextRef, 16.0)
    CGContextSetLineJoin(contextRef, KCGLineJoinRound)
    CGContextSetLineCap(contextRef, KCGLineCapRound)
    CGContextBeginPath(contextRef)
    points_ptr = Pointer.new(CGPoint.type, @points.count)
    @points.each_with_index {|point, i|
      points_ptr[i] = point
    }
    CGContextAddLines(contextRef, points_ptr, @points.count)
    CGContextStrokePath(contextRef)
  end

  def render_mask(sourceImage)
    return sourceImage if @buffer.nil?

    size = self.bounds.size
    colorSpaceRef = CGColorSpaceCreateDeviceRGB()
    contextRef = CGBitmapContextCreate(nil, size.width, size.height, 8, 0, colorSpaceRef, KCGImageAlphaPremultipliedLast)

    flip = CGAffineTransformIdentity
    flip = CGAffineTransformTranslate(flip, 0.0, size.height)
    flip = CGAffineTransformScale(flip, 1.0, -1.0)
    CGContextConcatCTM(contextRef, flip)
    CGContextDrawImage(contextRef, self.bounds, @buffer)
    flipped = CGBitmapContextCreateImage(contextRef)

    mask = CGImageMaskCreate(
      CGImageGetWidth(flipped),
      CGImageGetHeight(flipped),
      CGImageGetBitsPerComponent(flipped),
      CGImageGetBitsPerPixel(flipped),
      CGImageGetBytesPerRow(flipped),
      CGImageGetDataProvider(flipped),
      nil,
      false)

    masked = CGImageCreateWithMask(sourceImage.CGImage, mask)
    #return UIImage.imageWithCGImage(masked)
    return UIImage.imageWithCGImage(flipped)

    #sourceImage = CIImage.imageWithCGImage(sourceImage.CGImage)
    #compo = CIFilter.filterWithName("CISourceOutCompositing")
    #compo.setDefaults
    #compo.setValue(sourceImage, forKey: "inputImage")
    #mask = CIImage.imageWithCGImage(@buffer)
    #transform = CGAffineTransformScale(
      #CGAffineTransformIdentity,
      #sourceImage.extent.size.width / mask.extent.size.width,
      #sourceImage.extent.size.height / mask.extent.size.height
    #)
    ##transform = CGAffineTransformRotate(transform, -Math::PI/2)
    #transform = CGAffineTransformScale(transform, 1.0, -1.0)
    #transform = CGAffineTransformTranslate(transform, 0, -mask.extent.size.height)
    #mask = mask.imageByApplyingTransform(transform)
    #compo.setValue(mask, forKey: "inputBackgroundImage")
    #context = CIContext.contextWithOptions(nil)
    #cgRef = context.createCGImage(compo.outputImage, fromRect: compo.outputImage.extent)
    #out = UIImage.alloc.initWithCGImage(cgRef)
    #out
  end

  def flatten
    colorSpaceRef = CGColorSpaceCreateDeviceRGB()
    contextRef = CGBitmapContextCreate(nil, @buffer_bounds.size.width, @buffer_bounds.size.height, 8, 0, colorSpaceRef, KCGImageAlphaPremultipliedLast)

    if @buffer.nil?
      CGContextClearRect(contextRef, @buffer_bounds)
      CGContextSetFillColorWithColor(contextRef, UIColor.redColor.CGColor)
      CGContextFillRect(contextRef, @buffer_bounds)
    else
      CGContextDrawImage(contextRef, @buffer_bounds, @buffer)
    end
    scale = CGAffineTransformMakeScale(@buffer_bounds.size.width / self.bounds.size.width, @buffer_bounds.size.height / self.bounds.size.height)
    CGContextConcatCTM(contextRef, scale)
    self.drawInContext(contextRef)
    @buffer = CGBitmapContextCreateImage(contextRef)
  end

  def reset
    @points = []
    @buffer = nil
    @draw_clear = false
    @buffer_bounds = CGRectMake(0.0, 0.0, BUFFER_WIDTH, BUFFER_HEIGHT)
  end

  def initWithFrame(frame)
    super

    self.reset()
    self.opaque = false
    self.backgroundColor = UIColor.clearColor
    self.setAutoresizingMask(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)
    self
  end

end
