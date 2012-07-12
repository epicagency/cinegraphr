class CMGFilterSepiaTone < CMGFilter

  def init
    super
    @sepia_filter = CIFilter.filterWithName("CISepiaTone")
    @sepia_filter.setDefaults
    self
  end

  def apply_filter(image)
    image = super(image)
    @sepia_filter.setValue(image, forKey:"inputImage")
    @sepia_filter.setValue(1.0, forKey:"inputIntensity")
    @sepia_filter.outputImage
  end

end
