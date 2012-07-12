class CMGToolSwitchView < UIView
  def addTarget(target,withAction: action)
    @targets << [target, action]
  end

  def toggle_state
    if @state == "pen"
      @state = "eraser"
      where = 0
      @swipe.direction = UISwipeGestureRecognizerDirectionDown
    else
      @state = "pen"
      where = self.frame.size.height - @thumb.frame.size.height
      @swipe.direction = UISwipeGestureRecognizerDirectionUp
    end

    anim = Proc.new {
      frm = @thumb.frame
      frm.origin.y = where
      @thumb.frame = frm
    }

    @targets.each{|t|
      t[0].send(t[1].to_sym, self, @state)
    }

    @pen.highlighted = (@state == 'pen')
    @eraser.highlighted = (@state == 'eraser')
    UIView.animateWithDuration(0.05, animations: anim)
  end

  def thumbTapped(gesture)
    if gesture.state == UIGestureRecognizerStateEnded
      loc = gesture.locationInView(self)
      half = self.frame.size.height / 2
      if (loc.y < half && @state == "pen") or (loc.y > half && @state == "eraser")
        self.toggle_state()
      end
    end
  end

  def swipped(gesture)
    if gesture.state == UIGestureRecognizerStateEnded
      self.toggle_state()
    end
  end

  def initWithFrame(frame)
    bg = UIImageView.alloc.initWithImage(UIImage.imageNamed("images/tool-switch-background.png"))

    frame = CGRectMake(frame.origin.x, frame.origin.y, bg.frame.size.width, bg.frame.size.height)
    super(frame)

    @targets = []

    self.addSubview(bg)

    @thumb = UIImageView.alloc.initWithImage(UIImage.imageNamed("images/tool-switch-thumb.png"))
    frm = @thumb.frame
    frm.origin.y = frame.size.height - frm.size.height
    @thumb.frame = frm
    self.addSubview(@thumb)

    @eraser = UIImageView.alloc.initWithImage(UIImage.imageNamed("images/tool-switch-eraser-inactive.png"), highlightedImage: UIImage.imageNamed("images/tool-switch-eraser-active.png"))
    @eraser.userInteractionEnabled = false
    self.addSubview(@eraser)

    @pen = UIImageView.alloc.initWithImage(UIImage.imageNamed("images/tool-switch-pen-inactive.png"), highlightedImage: UIImage.imageNamed("images/tool-switch-pen-active.png"))
    @pen.highlighted = true
    @pen.userInteractionEnabled = false
    frm = @pen.frame
    frm.origin.y = frame.size.height - frm.size.height
    @pen.frame = frm
    self.addSubview(@pen)

    @state = "pen"

    @tap = UITapGestureRecognizer.alloc.initWithTarget(self, action: "thumbTapped:")
    self.addGestureRecognizer(@tap)

    @swipe = UISwipeGestureRecognizer.alloc.initWithTarget(self, action: "swipped:")
    @swipe.direction = UISwipeGestureRecognizerDirectionUp
    self.addGestureRecognizer(@swipe)

    self
  end
end
