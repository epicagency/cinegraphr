class CMGLibraryCellView < UITableViewCell
  attr_reader :time_label
  attr_reader :place_label
  attr_reader :thumb_view

  def initWithStyle(style, reuseIdentifier: reuseIdentifier)
    super

    iv = UIImageView.alloc.initWithImage(UIImage.imageNamed("images/cell-header.png"))
    self.contentView.addSubview(iv)
    container = UIView.alloc.initWithFrame(
      CGRectMake(
        0.0,
        iv.image.size.height,
        self.contentView.frame.size.width,
        27.0
      )
    )
    container.backgroundColor = UIColor.whiteColor
    iv = UIImageView.alloc.initWithImage(UIImage.imageNamed("images/cell-icon-time.png"))
    iv.frame = CGRectMake(10.0, 8.0, 16.0, 16.0)
    container.addSubview(iv)
    @time_label = UILabel.alloc.initWithFrame(CGRectMake(30.0, 5.0, 50.0, 21.0))
    @time_label.text = "time holder"
    @time_label.font = UIFont.fontWithName("Helvetica", size: 10.0)
    @time_label.textColor = UIColor.colorWithRed(0.541, green: 0.541, blue: 0.541, alpha: 1.0)
    container.addSubview(@time_label)
    iv = UIImageView.alloc.initWithImage(UIImage.imageNamed("images/cell-icon-place.png"))
    iv.frame = CGRectMake(80.0, 8.0, 16.0, 16.0)
    container.addSubview(iv)
    @place_label = UILabel.alloc.initWithFrame(CGRectMake(100.0, 5.0, 150.0, 21.0))
    @place_label.text = "place holder"
    @place_label.font = UIFont.fontWithName("Helvetica", size: 10.0)
    @place_label.textColor = UIColor.colorWithRed(0.541, green: 0.541, blue: 0.541, alpha: 1.0)
    container.addSubview(@place_label)
    self.contentView.addSubview(container)

    @thumb_view = UIImageView.alloc.initWithFrame(CGRectMake(0.0, container.frame.origin.y+container.frame.size.height, self.contentView.frame.size.width, 160))
    self.contentView.addSubview(@thumb_view)
    iv = UIImageView.alloc.initWithImage(UIImage.imageNamed("images/cell-rip.png"))
    iv.frame = CGRectMake(0.0, @thumb_view.frame.origin.y, self.contentView.frame.size.width, iv.image.size.height);
    self.contentView.addSubview(iv)
    self
  end
end
