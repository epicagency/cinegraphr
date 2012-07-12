class CMGRecorderOverlayView < UIView

  # {{{ State manipulation
  def hide_start_screen
    @start_screen.hidden = true
  end

  def show_rec_grid
    @rec_grid.hidden = false
  end

  def hide_rec_grid
    @rec_grid.hidden = true
  end
  # }}}

  def initWithFrame(frame)
    super

    self.opaque = false

    @start_screen = UIView.alloc.initWithFrame(frame)
    @reel_view = UIImageView.alloc.initWithImage(UIImage.imageNamed("images/icon-reel.png"))
    @start_screen.addSubview(@reel_view)

    s = frame.size
    rs = @reel_view.frame.size
    @reel_view.frame = CGRectMake((s.width/2)-(rs.width/2), (s.height/2)-(rs.height*2), rs.width, rs.height)

    @intro_label = UILabel.alloc.initWithFrame(CGRectMake(70.0, 100.0, 340.0, 120.0))
    @intro_label.text = "Tap the screen to focus, double-tap to start recording a video"
    @intro_label.textColor = UIColor.whiteColor
    @intro_label.textAlignment = UITextAlignmentCenter
    @intro_label.font = UIFont.fontWithName("Hiruko", size:23.0)
    @intro_label.backgroundColor = UIColor.clearColor
    @intro_label.lineBreakMode = UILineBreakModeWordWrap
    @intro_label.numberOfLines = 3
    @start_screen.addSubview(@intro_label)

    @rec_grid = UIView.alloc.initWithFrame(frame)
    @rec_view = UIImageView.alloc.initWithImage(UIImage.imageNamed("images/icon-rec.png"))
    @rec_view.frame = CGRectMake(10.0, 10.0, @rec_view.frame.size.width, @rec_view.frame.size.height)
    @rec_grid.addSubview(@rec_view)

    @rec_label = UILabel.alloc.initWithFrame(CGRectMake(20.0, 15.0, 80.0, 20.0))
    @rec_label.text = "rec"
    @rec_label.textColor = UIColor.whiteColor
    @rec_label.textAlignment = UITextAlignmentCenter
    @rec_label.font = UIFont.fontWithName("Hiruko", size:23.0)
    @rec_label.backgroundColor = UIColor.clearColor
    @rec_grid.addSubview(@rec_label)

    self.addSubview(@start_screen)
    self.addSubview(@rec_grid)
    @rec_grid.hidden = true
    self
  end
end
