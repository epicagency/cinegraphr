class UILabel
  def sizeToFitFixedWidth(fixedWidth)
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, fixedWidth, 0)
    self.lineBreakMode = UILineBreakModeWordWrap
    self.numberOfLines = 0
    self.sizeToFit
  end
end

class CMGModelessAlertView < UIView
  HORIZONTAL_PADDING =  15.0
  VERTICAL_PADDING =  15.0
  IMAGE_PADDING =  45.0
  TITLE_FONT_SIZE = 16.0
  DETAIL_FONT_SIZE = 13.0
  ANIMATION_DURATION =  0.3

  @@current_alert_view = nil

  attr_accessor :title_text
  attr_accessor :detail_text
  attr_accessor :min_height
  attr_accessor :background_image
  attr_accessor :accessory_image
  attr_accessor :on_touch
  attr_accessor :on_hide
  attr_accessor :should_animate
  attr_accessor :title_label_color
  attr_accessor :detail_label_color

  def self.current_alert_view
    @@current_alert_view
  end

  def self.show_alert_in_view(view, title, detail = nil, image = nil, background_image = nil, title_color = nil, detail_color = nil, animated = true, delay = 3.0)
    unless @@current_alert_view.nil?
      @@current_alert_view.hide_using_animation(animated)
    end

    alert = CMGModelessAlertView.alloc.initWithFrame(CGRectMake(0, 0, view.bounds.size.width, 44.0))
    @@current_alert_view = alert

    alert.title_text = title
    alert.detail_text = detail || nil
    alert.accessory_image = image || nil
    alert.background_image = background_image || UIImage.imageNamed("images/background-alert-yellow.png")
    alert.title_label_color = title_color || nil
    alert.detail_label_color = detail_color || nil
    alert.should_animate = animated

    if view.kind_of? UIWindow
      alert_frame = alert.frame
      app_frame = UIScreen.mainScreen.applicationFrame
      alert_frame.origin.x = app_frame.origin.y
      alert.frame = alert_frame
    end
    view.addSubview(alert)
    alert.show(animated)
    if delay > 0.0
      alert.performSelector("hide_using_animation:", withObject: animated, afterDelay: delay + ANIMATION_DURATION)
    end
    alert
  end

  def self.remove_alert
    return if @@current_alert_view.nil?
    @@current_alert_view.removeFromSuperview
    @@current_alert_view = nil
  end


  def self.remove_alert_in_view(view, animated = true)
    unless @@current_alert_view.nil?
      @@current_alert_view.hide_using_animation(animated)
      return true
    end

    view_to_remove = nil
    view.subviews.each {|v|
      if v.kind_of? CMGModelessAlertView
        view_to_remove = v
      end
    }
    if view_to_remove.nil?
      false
    else
      view_to_remove.hide_using_animation(animated)
      true
    end
  end

  def title_text=(text)
    if NSThread.isMainThread
      self.update_title_label(text)
      self.setNeedsLayout
      self.setNeedsDisplay
    else
      self.performSelectorOnMainThread("updateTitleLabel:", withObject:text, waitUntilDone:false)
      self.performSelectorOnMainThread("setNeedsLayout", withObject:nil, waitUntilDone:false)
      self.performSelectorOnMainThread("setNeedsDisplay", withObject:nil, waitUntilDone:false)
    end
  end

  def detail_text=(text)
    if NSThread.isMainThread
      self.update_detail_label(text)
      self.setNeedsLayout
      self.setNeedsDisplay
    else
      self.performSelectorOnMainThread("updateDetailLabel:", withObject:text, waitUntilDone:false)
      self.performSelectorOnMainThread("setNeedsLayout", withObject:nil, waitUntilDone:false)
      self.performSelectorOnMainThread("setNeedsDisplay", withObject:nil, waitUntilDone:false)
    end
  end

  def init
    super.initWithFrame(CGRectMake(0, 0, 320.0, 44.0))
    self
  end

  def initWithFrame(frame)
    super
    return nil if self.nil?

    self.title_text = nil
    self.detail_text = nil
    self.min_height = 44.0
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin

    @title_label = UILabel.alloc.initWithFrame(self.bounds)
    @detail_label = UILabel.alloc.initWithFrame(self.bounds)

    @background_image_view = UIImageView.alloc.initWithFrame(self.bounds)
    @background_image_view.autoresizingMask = UIViewAutoresizingFlexibleWidth
    #@background_image_view.image = @background_image.stretchableImageWithLeftCapWidth(1, topCapHeight:@background_image.size.height/2)

    @accessory_image_view = UIImageView.alloc.initWithFrame(self.bounds)
    self.addSubview(@background_image_view)
    self.opaque = true
    @on_touch = nil
    @on_hide = nil
    self
  end

  def show(animated)
    if animated
      self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y-self.frame.size.height, self.frame.size.width, self.frame.size.height)
      self.alpha = 0.02
      UIView.animateWithDuration(
        ANIMATION_DURATION,
        delay:0.0,
        options:UIViewAnimationOptionCurveEaseInOut,
        animations: lambda do
          self.alpha = 1.0
          self.frame = CGRectMake(
            self.frame.origin.x,
            self.frame.origin.y+self.frame.size.height,
            self.frame.size.width, self.frame.size.height
          )
        end,
        completion: lambda do |finished|
          if finished
          end
        end
      )
    end
  end

  def hide(animated)
    self.hide_using_animation(animated)
  end

  def touchesBegan(touches, withEvent:event)
    if @on_touch.nil?
      self.hide_using_animation(self.should_animate)
    else
      @on_touch.call(self)
    end
  end

  def layoutSubviews
    @title_label.font = UIFont.boldSystemFontOfSize(TITLE_FONT_SIZE)
    @title_label.adjustsFontSizeToFitWidth = true
    @title_label.opaque = true
    @title_label.backgroundColor = UIColor.clearColor
    @title_label.textColor = @title_label_color


    gray = Pointer.new(:float)
    alpha = Pointer.new(:float)
    @title_label.textColor.getWhite(gray, alpha: alpha)
    if gray[0] > 0.5
      @title_label.shadowColor = UIColor.colorWithWhite(0, alpha:0.25)
      @title_label.shadowOffset = CGSizeMake(0, -1 / UIScreen.mainScreen.scale)
    else
      @title_label.shadowColor = UIColor.colorWithWhite(1, alpha:0.35)
      @title_label.shadowOffset = CGSizeMake(0, 1 / UIScreen.mainScreen.scale)
    end

    @title_label.text = @title_text
    @title_label.sizeToFitFixedWidth(self.bounds.size.width - (2 * HORIZONTAL_PADDING))
    @title_label.frame = CGRectMake(
      self.bounds.origin.x + HORIZONTAL_PADDING,
      self.bounds.origin.y + VERTICAL_PADDING - 8,
      self.bounds.size.width - (2 * HORIZONTAL_PADDING),
      @title_label.frame.size.height
    )

    self.addSubview(@title_label)

    unless @detail_text.nil?
      @detail_label.font = UIFont.systemFontOfSize(DETAIL_FONT_SIZE)
      @detail_label.numberOfLines = 0
      @detail_label.adjustsFontSizeToFitWidth = false
      @detail_label.opaque = true
      @detail_label.backgroundColor = UIColor.clearColor
      @detail_label.textColor = @detail_label_color

      gray = Pointer.new(:float)
      alpha = Pointer.new(:float)
      @detail_label.textColor.getWhite(gray, alpha: alpha)
      if gray[0] > 0
        @detail_label.shadowColor = UIColor.colorWithWhite(0, alpha:0.25)
        @detail_label.shadowOffset = CGSizeMake(0, -1 / UIScreen.mainScreen.scale)
      else
        @detail_label.shadowColor = UIColor.colorWithWhite(1, alpha:0.35)
        @detail_label.shadowOffset = CGSizeMake(0, 1 / UIScreen.mainScreen.scale)
      end

      @detail_label.text = @detail_text
      @detail_label.sizeToFitFixedWidth(self.bounds.size.width - (2 * HORIZONTAL_PADDING))
      @detail_label.frame = CGRectMake(
        self.bounds.origin.x + HORIZONTAL_PADDING,
        @title_label.frame.origin.y + @title_label.frame.size.height,
        self.bounds.size.width - (2 * HORIZONTAL_PADDING),
        @detail_label.frame.size.height
      )
      self.addSubview(@detail_label)
    else
      @title_label.frame = CGRectMake(
        @title_label.frame.origin.x,
        9,
        @title_label.frame.size.width,
        @title_label.frame.size.height
      )
    end

    unless @accessory_image.nil?
      @accessory_image_view.image = @accessory_image
      @accessory_image_view.frame = CGRectMake(
        self.bounds.origin.x + HORIZONTAL_PADDING,
        self.bounds.origin.y + VERTICAL_PADDING,
        @accessory_image.size.width,
        @accessory_image.size.height
      )
      @title_label.sizeToFitFixedWidth(self.bounds.size.width - IMAGE_PADDING - (HORIZONTAL_PADDING * 2))
      @title_label.frame = CGRectMake(
        @title_label.frame.origin.x + IMAGE_PADDING,
        @title_label.frame.origin.y,
        @title_label.frame.size.width,
        @title_label.frame.size.height
      )
      unless @detail_text.nil?
        @detail_label.sizeToFitFixedWidth(self.bounds.size.width - IMAGE_PADDING - (HORIZONTAL_PADDING * 2))
        @detail_label.frame = CGRectMake(
          @detail_label.frame.origin.x + IMAGE_PADDING,
          @detail_label.frame.origin.y,
          @detail_label.frame.size.width,
          @detail_label.frame.size.height
        )
      end
      self.addSubview(@accessory_image_view)
    end

    height = 44.0
    unless @detail_text.nil?
      height = [CGRectGetMaxY(self.bounds), CGRectGetMaxY(@detail_label.frame)].max
      height += VERTICAL_PADDING
    else
      height = [CGRectGetMaxY(self.bounds), CGRectGetMaxY(@title_label.frame)].max
      unless height == 44
        height += VERTICAL_PADDING
      end
    end
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height)

    @background_image_view.image = @background_image.stretchableImageWithLeftCapWidth(1, topCapHeight: @background_image.size.height/2)
    @background_image_view.frame = self.bounds
  end

  protected

  def update_title_label(text)
    return if @title_text == text
    @title_text = text
    @title_label.text = text
  end

  def update_detail_label(text)
    return if @detail_text == text
    @detail_text = text
    @detail_label.text = text
  end

  def hide_using_animation(animated)
    if animated
      UIView.animateWithDuration(
        ANIMATION_DURATION,
        delay:0.0,
        options:UIViewAnimationOptionCurveEaseInOut,
        animations: lambda do
          self.alpha = 0.02
          self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y-self.frame.size.height, self.frame.size.width, self.frame.size.height)
        end,
        completion: lambda do |finished|
          self.done if finished
        end
      )
    else
      self.alpha = 0.0
      self.done
    end
  end

  def done
    self.removeFromSuperview
    @on_hide.call(self) unless @on_hide.nil?
    @@current_alert_view = nil
  end
end
