class CMGFilter
  attr_accessor :output
  attr_accessor :images
  attr_accessor :mask

  def mask=(mask)
    @mask = mask
    @compo.setValue(@mask, forKey: "inputImage")
  end

  def self.filter_named(filter)
    begin
      c = Object::const_get("CMGFilter#{filter.to_s.camelize}").alloc.init()
    rescue StandardError => err
      p err
      nil
    end
  end

  def run 
    dst_ref = CGImageDestinationCreateWithURL(
      @output,
      KUTTypeGIF,
      @images.count,
      nil
    )
    frame_props = {
      KCGImagePropertyGIFDictionary => {
        KCGImagePropertyGIFDelayTime => 0.1
      }
    }
    gif_props  = {
      KCGImagePropertyGIFDictionary => {
        KCGImagePropertyGIFLoopCount => 0
      }
    }

    #ctx = CIContext.contextWithOptions({KCIContextUseSoftwareRenderer => true})
    ctx = CIContext.contextWithOptions(nil)
    #self.init_filter
    @images.each {|image|
      #result = self.apply_filter(image)

      CGImageDestinationAddImage(
        dst_ref,
        ctx.createCGImage(image, fromRect:image.extent),
        frame_props
      )
    }
    CGImageDestinationSetProperties(dst_ref, gif_props)
    CGImageDestinationFinalize(dst_ref)
  end

  def init
    super
    @compo = CIFilter.filterWithName("CISourceOverCompositing")
    @compo.setDefaults
    self
  end

  def apply_filter(image)
    @compo.setValue(image, forKey: "inputBackgroundImage")
    @compo.outputImage
  end

end
