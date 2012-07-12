class CMGEditorManager
  EDITORSTATE_TRIM = 0
  EDITORSTATE_FREEZE = 1
  EDITORSTATE_MASK = 2
  EDITORSTATE_PREVIEW = 3
  EDITORSTATE_GENERATE = 4

  include ::States::Trim
  include ::States::Freeze
  include ::States::Mask
  include ::States::Preview
  include ::States::Generate

  # {{{ ScrollThumbView Delegate
  def current=(pos)
    @player.pause
    @player.seekToTime(CMTimeMakeWithSeconds(pos, 600), toleranceBefore: KCMTimeZero, toleranceAfter: KCMTimeZero)
  end
  # }}}

  # {{{ Actions
  def toggle_chrome
    @play_button.hidden = !@play_button.hidden?
    @cancel_button.hidden = !@cancel_button.hidden?
    @validate_button.hidden = !@validate_button.hidden?
    @switch_button.hidden = !@switch_button.hidden?
    @previous_button.hidden = !@previous_button.hidden?
    @loop_button.hidden = !@loop_button.hidden?
  end

  def hide_chrome
    @play_button.hidden = true
    @cancel_button.hidden = true
    @validate_button.hidden = true
    @previous_button.hidden = true
    @loop_button.hidden = true
  end

  def show_chrome
    @play_button.hidden = false
    @cancel_button.hidden = false
    @validate_button.hidden = false
    @previous_button.hidden = false
    @loop_button.hidden = false
  end

  def switch(switch, changedState:state)
    return if @current_state != EDITORSTATE_MASK

    if state == "pen"
      @mask_controller.state = CMGMaskController::MASKSTATE_DRAW
    else
      @mask_controller.state = CMGMaskController::MASKSTATE_CLEAR
    end
  end

  def toggle_play(sender)
    if @player.rate > 0
      @player.pause
      @play_button.selected = false
    else
      @player.play
      @play_button.selected = true
    end
  end

  def toggle_loop(sender)
    @loop = !@loop
    @loop_button.selected = @loop
  end

  def cancel_edit(sender)
    @capture_controller.end_editing
    @player.pause unless @player.nil? or  @player.rate == 0
    @capture_controller.delegate.capture_did_cancel(@capture_controller)
  end

  def next_step(sender)
    case @current_state
    when EDITORSTATE_TRIM
      @asset_loaded = :load_freeze
      self.unload_trim()
    when EDITORSTATE_FREEZE
      self.unload_freeze()
      self.load_mask()
    when EDITORSTATE_MASK
      self.unload_mask()
      self.load_preview()
    when EDITORSTATE_PREVIEW
      self.unload_preview(true)
      self.load_generate()
    end
  end

  def save_graph(sender)
    @player.pause unless @player.nil? or @player.rate == 0
    self.unload_preview(true)
    self.load_generate()
  end

  def prev_step(sender)
    case @current_state
    when EDITORSTATE_FREEZE
      self.unload_freeze()
      self.load_trim()
    when EDITORSTATE_MASK
      self.unload_mask()
      self.load_freeze()
    when EDITORSTATE_PREVIEW
      self.unload_preview(false)
      self.load_mask()
    end
  end
  # }}}

  def playerItemDidReachEnd(sender)
    @player.seekToTime(KCMTimeZero)
    @player.play
  end

  def observeValueForKeyPath(keyPath, ofObject:object, change:change, context:context)

    if object == @player_item
      if @autoplay
        Dispatch::Queue.main.async do
          @play_button.selected = true
          @player.play
        end
      end
    else
      super
    end
  end

  def load_asset(asset_path)
    unless @asset.nil?
      @player_item.removeObserver(self, forKeyPath: "status", context: @player_context) unless @player_item.nil?
      NSNotificationCenter.defaultCenter.removeObserver(self, name:AVPlayerItemDidPlayToEndTimeNotification, object:@player_item)
      @player_item = nil
      @player = nil
    end
    @asset = AVURLAsset.URLAssetWithURL(NSURL.fileURLWithPath(asset_path), options: nil)
    @asset.loadValuesAsynchronouslyForKeys(["tracks"], completionHandler: lambda do
      Dispatch::Queue.main.async do
        error = Pointer.new(:object)
        status = @asset.statusOfValueForKey("tracks", error:error)
        if status == AVKeyValueStatusLoaded
          self.send(@asset_loaded) unless @asset_loaded.nil?
          @player_item = AVPlayerItem.playerItemWithAsset(@asset);
          @player_item.addObserver(self, forKeyPath: "status", options: 0, context: @player_context)
          NSNotificationCenter.defaultCenter.addObserver(self, selector:"playerItemDidReachEnd:", name:AVPlayerItemDidPlayToEndTimeNotification, object:@player_item)
          @player = AVPlayer.playerWithPlayerItem(@player_item)
          @player_layer.player = @player
        else
          error = error[0]
          p error.localizedDescription
        end
      end
    end)
  end

  def load_thumbs
    @thumbs.duration = CMTimeGetSeconds(@asset.duration)
    @generator = AVAssetImageGenerator.assetImageGeneratorWithAsset(@asset)
    interval = CMTimeGetSeconds(@asset.duration) / 5.0
    scale = @asset.duration.timescale
    times = []
    6.times {|i|
      times << NSValue.valueWithCMTime(CMTimeMakeWithSeconds(i.to_f * interval, scale))
    }
    @generator.maximumSize = CGSizeMake(CMGScrollThumbsView::THUMBS_WIDTH, CMGScrollThumbsView::THUMBS_HEIGHT)
    @generator.generateCGImagesAsynchronouslyForTimes(times ,completionHandler: lambda do |time, image, real_time, result, error|
      if result == AVAssetImageGeneratorSucceeded
        @thumbs.images << UIImage.imageWithCGImage(image)
        @thumbs.redisplay
      end
    end)
  end

  def init(capture_controller)
    super()

    @loop = false
    @autoplay = false
    @capture_controller = capture_controller

    bounds = @capture_controller.view.bounds
    @player_view = UIView.alloc.initWithFrame(CGRectMake(0.0, 0.0, bounds.size.height, bounds.size.width))
    @player_view.transform = CGAffineTransformMakeRotation(-Math::PI/2.0)
    @capture_controller.view.addSubview(@player_view)
    @player_view.center = CGPointMake(@capture_controller.view.bounds.size.width/2.0, @capture_controller.view.bounds.size.height/2.0)
    @player_layer = AVPlayerLayer.playerLayerWithPlayer(@player)
    @player_layer.videoGravity = AVLayerVideoGravityResizeAspectFill
    @player_layer.frame = @player_view.bounds
    @player_view.layer.addSublayer(@player_layer)
    @player_context = Pointer.new(:object)
    @player_context[0] = ""

    @asset = nil
    @asset_loaded = :load_trim
    load_asset(@capture_controller.current_file)

    @mask_controller = CMGMaskController.alloc.init()
    @capture_controller.addChildViewController(@mask_controller)
    @mask_controller.view.frame = @capture_controller.view.bounds
    @mask_controller.hide()
    @capture_controller.view.addSubview(@mask_controller.view)

    @thumbs = CMGScrollThumbsView.alloc.initWithFrame(CGRectZero)
    @thumbs.delegate = self
    @capture_controller.view.addSubview(@thumbs)

    @cancel_button = UIButton.buttonWithType(UIButtonTypeCustom)
    img = UIImage.imageNamed("images/button-cancel.png")
    @cancel_button.setImage(img, forState:UIControlStateNormal)
    @cancel_button.frame = CGRectMake(480-img.size.width-10, 10, img.size.width, img.size.height)
    @cancel_button.addTarget(self, action:"cancel_edit:", forControlEvents:UIControlEventTouchUpInside)
    @capture_controller.view.addSubview(@cancel_button)

    @play_button = UIButton.buttonWithType(UIButtonTypeCustom)
    img = UIImage.imageNamed("images/button-play.png")
    @play_button.setImage(img, forState:UIControlStateNormal)
    img = UIImage.imageNamed("images/button-pause.png")
    @play_button.setImage(img, forState:UIControlStateSelected)
    @play_button.frame = CGRectMake(480-img.size.width-11, 60, img.size.width, img.size.height)
    @play_button.addTarget(self, action:"toggle_play:", forControlEvents:UIControlEventTouchUpInside)
    @capture_controller.view.addSubview(@play_button)

    @loop_button = UIButton.buttonWithType(UIButtonTypeCustom)
    img = UIImage.imageNamed("images/button-loop-disabled.png")
    @loop_button.setImage(img, forState:UIControlStateNormal)
    img = UIImage.imageNamed("images/button-loop.png")
    @loop_button.setImage(img, forState:UIControlStateSelected)
    @loop_button.frame = CGRectMake(480-img.size.width-11, 110, img.size.width, img.size.height)
    @loop_button.addTarget(self, action:"toggle_loop:", forControlEvents:UIControlEventTouchUpInside)
    @capture_controller.view.addSubview(@loop_button)

    @previous_button = UIButton.buttonWithType(UIButtonTypeCustom)
    img = UIImage.imageNamed("images/button-back.png")
    @previous_button.setImage(img, forState:UIControlStateNormal)
    @previous_button.frame = CGRectMake(10, 255, img.size.width, img.size.height)
    @previous_button.addTarget(self, action:"prev_step:", forControlEvents:UIControlEventTouchUpInside)
    @previous_button.hidden = true
    @capture_controller.view.addSubview(@previous_button)

    @validate_button = UIButton.buttonWithType(UIButtonTypeCustom)
    img = UIImage.imageNamed("images/button-validate.png")
    @validate_button.setImage(img, forState:UIControlStateNormal)
    @validate_button.frame = CGRectMake(480-img.size.width-10, 255, img.size.width, img.size.height)
    @validate_button.addTarget(self, action:"next_step:", forControlEvents:UIControlEventTouchUpInside)
    @capture_controller.view.addSubview(@validate_button)

    @switch_button = CMGToolSwitchView.alloc.initWithFrame(CGRectMake(25.0, 10.0, 0.0, 0.0))
    @switch_button.addTarget(self, withAction:"switch:changedState:")
    @switch_button.hidden = true
    @capture_controller.view.addSubview(@switch_button)

    @save_button = UIButton.buttonWithType(UIButtonTypeCustom)
    img = UIImage.imageNamed("images/button-save.png")
    @save_button.setImage(img, forState:UIControlStateNormal)
    @save_button.frame = CGRectMake(480-img.size.width-10, 255, img.size.width, img.size.height)
    @save_button.addTarget(self, action:"save_graph:", forControlEvents:UIControlEventTouchUpInside)
    @save_button.hidden = true
    @capture_controller.view.addSubview(@save_button)

    self
  end
end
