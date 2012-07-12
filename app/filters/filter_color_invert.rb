class CMGFilterColorInvert < CMGFilter

  def init
    super
    @invert_filter = CIFilter.filterWithName("CIColorInvert")
    @invert_filter.setDefaults
    self
  end

  def apply_filter(image)
    image = super(image)
    @invert_filter.setValue(image, forKey:"inputImage")
    @invert_filter.outputImage
  end

end
