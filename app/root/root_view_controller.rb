class CMGRootViewController < UITabBarController 
  ROOTSTATE_RESTING = 0
  ROOTSTATE_RECORDING = 1
  ROOTSTATE_EDITING = 2
  ROOTSTATE_SHARING = 3

# {{{ Editor

  def capture_did_cancel(capture)
    UIApplication.sharedApplication.statusBarHidden = false
    p = Proc.new {
      @capture_controller = nil
    }
    self.dismissViewControllerAnimated(true, completion:p)
  end

  def capture_did_finish(capture, meta)
    UIApplication.sharedApplication.statusBarHidden = false
    p = Proc.new {
      @capture_controller = nil
    }
    self.dismissViewControllerAnimated(true, completion:p)

    UIApplication.sharedApplication.delegate.data_manager.add_image(meta)
  end

# Editor }}}

  def capture_video(sender)
    UIApplication.sharedApplication.statusBarHidden = true
    @capture_controller = CMGCaptureController.alloc.init()
    @capture_controller.delegate = self
    self.presentModalViewController(@capture_controller, animated: true)
  end

  def init
    super
    @current_state = ROOTSTATE_RESTING
    @capture_controller = nil
    self
  end

  def loadView
    super

    nib = UINib.nibWithNibName("LibraryView", bundle: nil)
    @library_view = nib.instantiateWithOwner(nil, options:nil).lastObject

    if @library_view.navigationBar.respondsToSelector("setTitleTextAttributes:")
      font = UIFont.fontWithName("Bodoni Std", size:24.0)
      attributes = {
        UITextAttributeFont => font,
        UITextAttributeTextShadowOffset => NSValue.valueWithUIOffset(UIOffsetMake(0.0, 2.0)),
        UITextAttributeTextShadowColor => UIColor.colorWithRed(0.333, green: 0.008, blue: 0.118, alpha: 1.0)
      }
      @library_view.navigationBar.titleTextAttributes = attributes
    end

    viewControllers = [@library_view, UIViewController.alloc.init, CMGProfileController.alloc.initWithStyle(UITableViewStylePlain)]
    viewControllers[2].tabBarItem = UITabBarItem.alloc.initWithTitle("Profile", image: nil, tag: 2)
    self.setViewControllers(viewControllers, animated: false)
    self.delegate = self

    share = UIButton.buttonWithType(UIButtonTypeCustom)
    share.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
    shareImg = UIImage.imageNamed("images/button-share.png")
    share.setBackgroundImage(
      shareImg,
      forState: UIControlStateNormal
    )
    share.setBackgroundImage(
      UIImage.imageNamed("images/button-share-highlight.png"),
      forState: UIControlStateHighlighted
    )
    share.frame = CGRectMake(0.0, 0.0, shareImg.size.width, shareImg.size.height)

    hd = shareImg.size.height - self.tabBar.frame.size.height
    center = self.tabBar.center
    if hd >= 0
      center.y = center.y - (hd/2)
    end
    share.center = center
    share.addTarget(self, action:"capture_video:", forControlEvents: UIControlEventTouchUpInside)
    self.view.addSubview(share)

  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    interfaceOrientation == UIInterfaceOrientationPortrait
  end
end
