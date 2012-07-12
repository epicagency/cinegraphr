class CMGProgressHudView < UIView

  @@current_progress = nil

  def self.show_progress_in_view(view, withTitle: title)

    if @@current_progress.nil?
      progress = CMGProgressHudView.alloc.initWithFrame(CGRectMake(120.0, 80.0, 240.0, 160.0))
      @@current_progress = progress
    else
      progress = @@current_progress
      @@current_progress.removeFromSuperview()
    end
    progress.title.text = title
    progress.progress.setProgress(0, animated: false)
    view.addSubview(progress)

    progress
  end

  def self.hide_progress
    unless @@current_progress.nil?
      @@current_progress.removeFromSuperview()
      @@current_progress = nil
    end
  end

  attr_reader :title
  attr_reader :progress

  def initWithFrame(frame)
    super

    base = self.bounds

    background = UIImageView.alloc.initWithImage(UIImage.imageNamed("images/background-hud.png").resizableImageWithCapInsets(UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)))
    #background.alpha = 0.9
    background.frame = base
    self.addSubview(background)

    @title = UILabel.alloc.initWithFrame(CGRectMake(10.0, 10.0, base.size.width-20.0, (base.size.height/2)-20.0))
    @title.textColor = UIColor.whiteColor
    @title.textAlignment = UITextAlignmentCenter
    @title.font = UIFont.fontWithName("Ultra", size:16.0)
    @title.backgroundColor = UIColor.clearColor
    self.addSubview(@title)

    @progress = UIProgressView.alloc.initWithProgressViewStyle(UIProgressViewStyleDefault)
    @progress.trackImage = UIImage.imageNamed("images/progress-background.png").resizableImageWithCapInsets(UIEdgeInsetsMake(0, 8.0, 0, 8.0))
    @progress.progressImage = UIImage.imageNamed("images/progress.png").resizableImageWithCapInsets(UIEdgeInsetsMake(0, 8.0, 0, 8.0))
    @progress.frame = CGRectMake(10.0, base.size.height-(base.size.height/4.0)-(@progress.trackImage.size.height/2), base.size.width-20.0, @progress.trackImage.size.height)
    self.addSubview(@progress)

    self
  end
end
