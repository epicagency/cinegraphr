class CMGRecorderManager

  def captureOutput(captureOutput, didFinishRecordingToOutputFileAtURL:outputFileURL, fromConnections:connections, error:error)
    success = true
    if not error.nil? and error.code != 0
      val = error.userInfo.objectForKey(AVErrorRecordingSuccessfullyFinishedKey)
      success = value.boolValue unless value.nil?
    end

    if success
      @capture_controller.start_editing
    else
    end
  end

  def init(capture_controller)
    super()

    @capture_controller = capture_controller

    unless UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceTypeCamera)
      alert = CMGModelessAlertView.show_alert_in_view(@capture_controller.view, "Can't initialize capture", "Your device doesn't have a suitable camera. Sorry", nil, UIImage.imageNamed("images/background-alert-red.png"))
      alert.on_hide = lambda do |sender|
        @capture_controller.dismissViewControllerAnimated(true, completion: lambda do
        end)
      end
      return self
    end
    @dq = Dispatch::Queue.new('net.epic.capture')
    begin
      @session = AVCaptureSession.alloc.init
      @session.beginConfiguration
      @session.sessionPreset = AVCaptureSessionPreset640x480
      device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
      device.lockForConfiguration(nil)
      device.focusMode = AVCaptureFocusModeLocked
      device.unlockForConfiguration
      @session.addInput(AVCaptureDeviceInput.deviceInputWithDevice(device,error:nil))
      @output = AVCaptureMovieFileOutput.alloc.init
      maxDuration = CMTimeMakeWithSeconds(5.0, 600)
      @output.maxRecordedDuration = maxDuration
      @session.addOutput(@output)
      @session.commitConfiguration
    rescue => e
      $stderr.puts e.message
      alert = CMGModelessAlertView.show_alert_in_view(@capture_controller.view, "Can't initialize capture", e.message, nil, UIImage.imageNamed("images/background-alert-red.png"))
      alert.on_hide = lambda do |sender|
        @capture_controller.dismissViewControllerAnimated(true, completion: lambda do
        end)
      end
      return self
    end

    @counter = 0

    bounds = UIScreen.mainScreen.bounds
    frame = CGRectMake(0, 0, bounds.size.height, bounds.size.width)

    @preview_layer = AVCaptureVideoPreviewLayer.alloc.initWithSession(@session)
    @preview_layer.frame = frame
    @preview_layer.videoGravity = AVLayerVideoGravityResizeAspectFill
    @preview_layer.orientation = AVCaptureVideoOrientationLandscapeRight
    @capture_controller.view.layer.addSublayer(@preview_layer)

    @overlay_view = CMGRecorderOverlayView.alloc.initWithFrame(frame)
    double_tap = UITapGestureRecognizer.alloc.initWithTarget(self, action:"start_recording:")
    double_tap.numberOfTapsRequired = 2
    @overlay_view.addGestureRecognizer(double_tap)
    single_tap = UITapGestureRecognizer.alloc.initWithTarget(self, action:"set_focus:")
    single_tap.numberOfTapsRequired = 1
    single_tap.requireGestureRecognizerToFail(double_tap)
    @overlay_view.addGestureRecognizer(single_tap)
    @capture_controller.view.addSubview(@overlay_view)

    @session.startRunning

    self
  end

  def set_focus(sender)
    return if @is_capturing or sender.state != UIGestureRecognizerStateEnded
    pos = sender.locationInView(@overlay_view)
    focus = CGPointMake(pos.x/@overlay_view.bounds.size.width, pos.y/@overlay_view.bounds.size.height)
    device = @session.inputs[0].device
    device.lockForConfiguration(nil)
    device.focusPointOfInterest = focus
    device.focusMode = AVCaptureFocusModeAutoFocus
    device.unlockForConfiguration
  end

  def end_recording(sender)
    @output.stopRecording
    @preview_layer.removeFromSuperlayer
    @overlay_view.removeFromSuperview
    @is_capturing = false
    @dq = nil
    #@capture_controller.performSelectorOnMainThread('start_editing', withObject: nil, waitUntilDone: false)
  end

  def start_recording(sender)
    return if @is_capturing or sender.state != UIGestureRecognizerStateEnded
    begin
      @overlay_view.hide_start_screen
      @overlay_view.show_rec_grid
      @is_capturing = true
      @output.startRecordingToOutputFileURL(NSURL.fileURLWithPath(@capture_controller.current_file), recordingDelegate: self)
      NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "end_recording:", userInfo: nil, repeats: false)
    rescue => e
      $stderr.puts e.message
      alert = CMGModelessAlertView.show_alert_in_view(@capture_controller.view, "Can't start recording", e.message, nil, UIImage.imageNamed("images/background-alert-red.png"))
      alert.on_hide = lambda do |sender|
        @capture_controller.dismissViewControllerAnimated(true, completion: lambda do
        end)
      end
      return self
    end
  end

end
