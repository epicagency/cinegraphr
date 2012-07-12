class CMGFilterBurn < CMGFilter
  def init
    super
    @overlay_filter = CIFilter.filterWithName("CIOverlayBlendMode")
    @overlay_filter.setDefaults
    @gamma_filter = CIFilter.filterWithName("CIGammaAdjust")
    @gamma_filter.setDefaults
    @gamma_filter.setValue(0.52, forKey:"inputPower")
    @exposure_filter = CIFilter.filterWithName("CIExposureAdjust")
    @exposure_filter.setDefaults
    @exposure_filter.setValue(0.1, forKey:"inputEV")
    @tone_filter = CIFilter.filterWithName("CIToneCurve")
    @tone_filter.setDefaults
    @screen_filter = CIFilter.filterWithName("CIScreenBlendMode")
    @screen_filter.setDefaults
    @screen_image = CIImage.imageWithContentsOfURL(NSBundle.mainBundle.URLForResource("burn", withExtension: "png", subdirectory: "filters"))
    @screen_filter.setValue(@screen_image, forKey: "inputBackgroundImage")

    @tone_point0 = CIVector.vectorWithX(0, Y: 0.209)
    @tone_point1 = CIVector.vectorWithX(0.25, Y: 0.336)
    @tone_point2 = CIVector.vectorWithX(0.5, Y: 0.57)
    @tone_point3 = CIVector.vectorWithX(0.75, Y: 0.769)
    @tone_point4 = CIVector.vectorWithX(1, Y: 1)

    @tone_filter.setValue(@tone_point0, forKey: "inputPoint0")
    @tone_filter.setValue(@tone_point1, forKey: "inputPoint1")
    @tone_filter.setValue(@tone_point2, forKey: "inputPoint2")
    @tone_filter.setValue(@tone_point3, forKey: "inputPoint3")
    @tone_filter.setValue(@tone_point4, forKey: "inputPoint4")
    self
  end

  def apply_filter(image)
    image = super(image)
    @overlay_filter.setValue(image, forKey:"inputImage")
    @overlay_filter.setValue(image, forKey:"inputBackgroundImage")
    #@overlay_filter.outputImage
    @gamma_filter.setValue(@overlay_filter.outputImage, forKey:"inputImage")
    #@gamma_filter.outputImage
    @exposure_filter.setValue(@gamma_filter.outputImage, forKey:"inputImage")
    #@exposure_filter.outputImage
    @tone_filter.setValue(@exposure_filter.outputImage, forKey:"inputImage")
    #@tone_filter.outputImage
    @screen_filter.setValue(@tone_filter.outputImage, forKey: "inputImage")
    @screen_filter.outputImage
  end

end
