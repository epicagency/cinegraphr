class CMGMetaView < UIView
  attr_reader :caption
  attr_reader :ok_button
  attr_reader :geotag
  attr_reader :geotag_label
  attr_reader :twitter
  attr_reader :facebook
  attr_reader :geoactivity
  attr_reader :generateactivity

  def initWithFrame(frame)
    super
    self.backgroundColor = UIColor.colorWithPatternImage(UIImage.imageNamed("images/background-texture.png"))

    current = 0

    # {{{ header
    header = CMGHeaderView.alloc.initWithFrame(CGRectZero)
    header.label.text = "Share it..."
    self.addSubview(header)

    @generateactivity = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleWhite)
    frm = @generateactivity.frame
    frm.origin.x = 10.0
    frm.origin.y = (header.frame.size.height - frm.size.height) / 2
    @generateactivity.frame = frm
    @generateactivity.hidesWhenStopped = true
    header.addSubview(@generateactivity)

    @ok_button = UISegmentedControl.alloc.initWithItems(["Done"])
    @ok_button.segmentedControlStyle = UISegmentedControlStyleBar
    @ok_button.momentary = true
    @ok_button.tintColor = UIColor.colorWithRed(0.859, green: 0.000, blue:0.302, alpha:1.0)
    @ok_button.center = CGPointMake(header.frame.size.width - (@ok_button.frame.size.width / 2) - 10, header.frame.size.height/2);
    header.addSubview(@ok_button)
    # }}}

    sv = UIScrollView.alloc.initWithFrame(CGRectMake(0.0, header.frame.size.height, frame.size.width, frame.size.height - header.frame.size.height))
    self.addSubview(sv)

    current = 10.0

    # {{{ caption
    @caption = UITextField.alloc.initWithFrame(CGRectMake(10.0, current, frame.size.width - 20.0, 27.0))
    @caption.placeholder = "Caption..."
    @caption.borderStyle = UITextBorderStyleRoundedRect
    sv.addSubview(@caption)
    # }}}

    current += @caption.frame.size.height + 10.0

    # {{{ geotag
    @geotag = UISwitch.alloc.initWithFrame(CGRectMake(0, current, 0, 0))
    frm = @geotag.frame
    frm.origin.x = frame.size.width - frm.size.width - 10
    @geotag.frame = frm
    @geotag.onTintColor = UIColor.colorWithRed(0.859, green: 0.000, blue:0.302, alpha:1.0)
    sv.addSubview(@geotag)

    @geotag_label = UILabel.alloc.initWithFrame(CGRectMake(10.0, current, @geotag.origin.x - 20, 27.0))
    @geotag_label.text = "Geotagged"
    @geotag_label.backgroundColor = UIColor.clearColor
    @geotag_label.textColor = UIColor.whiteColor
    sv.addSubview(@geotag_label)

    @geoactivity = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleWhite)
    frm = @geoactivity.frame
    frm.origin.x = @geotag.frame.origin.x - frm.size.width - 5.0
    frm.origin.y = @geotag.frame.origin.y + ((@geotag.frame.size.height - frm.size.height)/2)
    @geoactivity.frame = frm
    @geoactivity.hidesWhenStopped = true
    if @geoactivity.respond_to? "setColor:"
      @geoactivity.color = UIColor.colorWithRed(0.859, green: 0.000, blue:0.302, alpha:1.0)
    end
    sv.addSubview(@geoactivity)
    # }}}

    current += @geotag_label.frame.size.height + 10

    # {{{ Shares
    @twitter = UISwitch.alloc.initWithFrame(CGRectMake(0, current))
    frm = @twitter.frame
    frm.origin.x = frame.size.width - frm.size.width - 10
    @twitter.frame = frm
    @twitter.onTintColor = UIColor.colorWithRed(0.859, green: 0.000, blue:0.302, alpha:1.0)
    sv.addSubview(@twitter)

    lb = UILabel.alloc.initWithFrame(CGRectMake(10.0, current, @twitter.origin.x - 20, 27.0))
    lb.text = "Share on twitter"
    lb.backgroundColor = UIColor.clearColor
    lb.textColor = UIColor.whiteColor
    sv.addSubview(lb)

    current += lb.frame.size.height + 10

    @facebook = UISwitch.alloc.initWithFrame(CGRectMake(0, current))
    frm = @facebook.frame
    frm.origin.x = frame.size.width - frm.size.width - 10
    @facebook.frame = frm
    @facebook.onTintColor = UIColor.colorWithRed(0.859, green: 0.000, blue:0.302, alpha:1.0)
    sv.addSubview(@facebook)

    lb = UILabel.alloc.initWithFrame(CGRectMake(10.0, current, @facebook.origin.x - 20, 27.0))
    lb.text = "Share on facebook"
    lb.backgroundColor = UIColor.clearColor
    lb.textColor = UIColor.whiteColor
    sv.addSubview(lb)
    # }}}

    current += lb.frame.size.height + 10

    sv.contentSize = CGSizeMake(frame.size.width, current)
    self
  end

end
