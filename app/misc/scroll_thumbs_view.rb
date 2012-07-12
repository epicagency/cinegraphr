class CMGScrollThumbsView < UIImageView
  THUMBS_COUNT = 6
  THUMBS_WIDTH = 56.0
  THUMBS_HEIGHT = 37.0
  WINDOW_WIDTH = 336.0
  BORDER_WIDTH = 4.0
  DBORDER_WIDTH = 8.0
  HANDLES_WIDTH = 22.0
  DHANDLES_WIDTH = 44.0

  # {{{ Properties

  attr_reader :images
  attr_accessor :handlebar_visible
  attr_accessor :frame_selector_visible
  attr_accessor :selected_frame
  attr_accessor :delegate
  attr_accessor :duration

  def redisplay
    @images.each_with_index {|image, index|
      @image_views[index].image = image
    }
  end

  def frame_selector_visible=(visible)
    @frame_selector_visible = visible
    @frame_selector.hidden = !visible
    if visible
      self.bringSubviewToFront(@frame_selector)
    end
  end

  def handlebar_visible=(visible)
    @handlebar_visible = visible
    @handlebars.hidden = !visible
    if visible
      self.bringSubviewToFront(@handlebars)
    end
  end

  def selected_frame=(frame)
    @selected_frame = frame
    x = (frame / @duration) * WINDOW_WIDTH
    @frame_selector.center = CGPointMake(x, 22.5)
  end

  def selected_range
    start = @duration * ((@handlebars.frame.origin.x + 1) / WINDOW_WIDTH)
    stop = @duration * ((@handlebars.frame.origin.x + @handlebars.frame.size.width - (BORDER_WIDTH*2) - 1) / WINDOW_WIDTH)
    [start, stop]
  end

  def frame_for_x(x)
    pos = x/WINDOW_WIDTH
    @time_label.text = "%.2f" % (@duration * pos)
    @time_label.center = CGPointMake(x, -15.0)
    @delegate.current = @duration * pos
    (@duration * pos)
  end
  # }}}

  # {{{ Touches handling
  def touchesBegan(touches, withEvent:event)
    touch = touches.anyObject()
    loc = touch.locationInView(@handlebars)
    loc2 = touch.locationInView(@frame_selector)
    @drag_handle = false
    @drag_selected = false
    if (@handlebar_visible and ((loc.x > -10 && loc.x < 30) || (loc.x > @handlebars.frame.size.width-30 && loc.x < @handlebars.frame.size.width+10)))
      @time_label.hidden = false
      @drag_handle = true
      @drag_origin = (loc.x < 30)
      @drag_current = touch.locationInView(self)
      if @drag_origin
        self.frame_for_x(@handlebars.frame.origin.x + 1)
      else
        self.frame_for_x(@handlebars.frame.origin.x + @handlebars.frame.size.width - (BORDER_WIDTH*2) - 1)
      end
    elsif @frame_selector_visible and loc2.x > 0 and loc2.x < @frame_selector.frame.size.width
      @time_label.hidden = false
      @drag_selected = true
      @drag_current = touch.locationInView(self)
      #@delegate.start_updating
      #@delegate.set_current(self.frame_for_x(@frame_selector.center.x + BORDER_WIDTH), true)
    else
      super
    end
  end

  def touchesMoved(touches, withEvent:event)
    if @drag_handle
      newLoc = touches.anyObject.locationInView(self)
      diff = newLoc.x - @drag_current.x
      frm = @handlebars.frame
      if @drag_origin
        real_diff = if frm.origin.x + diff <= -1 then -1 - frm.origin.x else diff end
        return if real_diff == 0
        frm.origin.x = frm.origin.x + real_diff
        frm.size.width -= real_diff
        @handlebars.frame = frm
        self.frame_for_x(frm.origin.x + 1)
      else
        frm.size.width = if frm.origin.x + frm.size.width + diff >= (WINDOW_WIDTH + DBORDER_WIDTH + 2.0) then WINDOW_WIDTH + DBORDER_WIDTH + 1.0 - frm.origin.x else frm.size.width + diff end
        @handlebars.frame = frm
        self.frame_for_x(frm.origin.x + frm.size.width - (BORDER_WIDTH*2) - 1)
      end
      @drag_current = newLoc
    elsif @drag_selected
      newLoc = touches.anyObject.locationInView(self)
      diff = newLoc.x - @drag_current.x
      center = @frame_selector.center
      center.x = [[center.x+diff, BORDER_WIDTH].max, WINDOW_WIDTH+BORDER_WIDTH].min
      @frame_selector.center = center
      @selected_frame = self.frame_for_x(center.x)
      #@delegate.set_current(@selected_frame, true)
      @drag_current = newLoc
    else
      super
    end
  end

  def touchesEnded(touches, withEvent: event)
    #@delegate.stop_updating
    @time_label.hidden = true
    if @drag_handle
      @drag_handle = false
      return
    elsif @drag_selected
      @drag_selected = false
      return
    else
      super
    end
  end

  def touchesCancelled(touches, withEvent: event)
    #@delegate.stop_updating
    if @drag_handle
      @drag_handle = false
      return
    elsif @drag_selected
      @drag_selected = false
      return
    else
      super
    end
  end
  # }}}

  def initWithFrame(frame)
    super

    @drag_handle = false
    @drag_origin = nil
    @drag_current = nil
    @drag_selected = false
    @images = []
    @selected_frame = 0.0

    frame = CGRectMake(
                       (480.0 - WINDOW_WIDTH - DBORDER_WIDTH)/2.0,
                       320.0 - THUMBS_HEIGHT - DBORDER_WIDTH - 20.0,
                       WINDOW_WIDTH + DBORDER_WIDTH,
                       THUMBS_HEIGHT + DBORDER_WIDTH
                       )
    self.frame = frame
    self.userInteractionEnabled = true
    self.image = UIImage.imageNamed("images/background-thumbs.png").stretchableImageWithLeftCapWidth(BORDER_WIDTH, topCapHeight: 0)

    @image_views = []
    (0..THUMBS_COUNT-1).each {|i|
      img = UIImageView.alloc.initWithFrame(CGRectMake(i*(THUMBS_WIDTH) + BORDER_WIDTH, BORDER_WIDTH, THUMBS_WIDTH, THUMBS_HEIGHT))
      self.addSubview(img)
      @image_views << img
    }

    @handlebar_visible = true
    @frame_selector_visible = false

    image = UIImage.imageNamed("images/handles.png")
    @handlebars = UIImageView.alloc.initWithImage(image.stretchableImageWithLeftCapWidth(HANDLES_WIDTH, topCapHeight:0))
    @handlebars.frame = CGRectMake(-1.0, -1.0, WINDOW_WIDTH + DBORDER_WIDTH + 2.0, THUMBS_HEIGHT + 11.0)
    @handlebars.userInteractionEnabled = true
    self.addSubview(@handlebars)

    @frame_selector = UIImageView.alloc.initWithImage(UIImage.imageNamed("images/frame-selected.png"))
    @frame_selector.userInteractionEnabled = false
    @frame_selector.hidden = true
    self.addSubview(@frame_selector)

    @time_label = UILabel.alloc.initWithFrame(CGRectMake(0.0, -15.0, 40.0, 15.0))
    @time_label.hidden = true
    @time_label.backgroundColor = UIColor.clearColor
    @time_label.text = "0.00"
    @time_label.textColor = UIColor.whiteColor
    @time_label.textAlignment = UITextAlignmentCenter
    @time_label.font = UIFont.fontWithName('Hiruko', size: 12.0)
    self.addSubview(@time_label)

    self
  end

end
