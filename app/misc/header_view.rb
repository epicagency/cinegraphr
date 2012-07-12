class CMGHeaderView < UIView

  attr_reader :label

  def initWithFrame(frame)
    super(frame)
    iv = UIImageView.alloc.initWithImage(UIImage.imageNamed("images/background-navigation.png"))
    self.addSubview(iv)
    frame = CGRectMake(frame.origin.x, frame.origin.y, iv.frame.size.width, iv.frame.size.height)
    self.frame = frame

    lb = UILabel.alloc.initWithFrame(iv.frame)
    lb.font = UIFont.fontWithName("Bodoni Std", size:24.0)
    lb.textColor = UIColor.whiteColor
    lb.textAlignment = UITextAlignmentCenter
    lb.shadowColor = UIColor.colorWithRed(0.333, green: 0.008, blue: 0.118, alpha: 1.0)
    lb.shadowOffset = CGSizeMake(0.0, 2.0)
    lb.opaque = false
    lb.backgroundColor = UIColor.clearColor
    self.addSubview(lb)
    @label = lb

    self
  end
end
