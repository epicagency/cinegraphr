class CMGCustomNavBar < UINavigationBar
  def didMoveToSuperview
    @custom_background = UIImage.imageNamed("images/background-navigation.png") if @custom_background.nil?
  end

  def drawRect(rect)
    if @custom_background.nil?
      super
    else
      @custom_background.drawInRect(rect)
    end
  end

end
