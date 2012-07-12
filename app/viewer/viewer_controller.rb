class CMGViewerController < UIViewController

  def data=(new_data)
    @frames = nil
    path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).lastObject
    src = CGImageSourceCreateWithURL(NSURL.fileURLWithPath(path.stringByAppendingPathComponent(new_data['path'])), nil)
    return if src.nil?
    l = CGImageSourceGetCount(src);
    @frames = []
    (0..l-1).each {|i|
      img = CGImageSourceCreateImageAtIndex(src, i, nil)
      unless img.nil?
        @frames << UIImage.imageWithCGImage(img)
        #CGImageRelease(img)
      end
    }
    #CFRelease(src)

    frm = self.view.frame
    img_size = @frames.first.size
    ratio = [(frm.size.width / img_size.width), (frm.size.height / img_size.height)].min
    target = CGSizeMake((img_size.width*ratio).floor, (img_size.height*ratio).floor)
    @animation.frame = CGRectMake(((frm.size.width-target.width)/2).floor, ((frm.size.height-target.height)/2).floor, target.width, target.height)
    @animation.animationImages = @frames
    @animation.animationDuration = @frames.size.to_f / 10.0
    @animation.startAnimating
  end

  def tapped
    @animation.stopAnimating
    @frames = nil
    @animation.animationImages = nil
    UIApplication.sharedApplication.statusBarHidden = false
    self.dismissModalViewControllerAnimated(false)
  end

  def init
    super
    @frames = nil
    self
  end

  def loadView
    bounds = UIScreen.mainScreen.bounds
    frame = CGRectMake(0, 0, bounds.size.height, bounds.size.width)

    self.view = UIView.alloc.initWithFrame(frame)
    self.view.backgroundColor = UIColor.colorWithPatternImage(UIImage.imageNamed("images/background-texture.png"))
    @animation = UIImageView.alloc.initWithFrame(frame)
    self.view.addSubview(@animation)

    @tap = UITapGestureRecognizer.alloc.initWithTarget(self, action: "tapped")
    self.view.addGestureRecognizer(@tap)

  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    UIInterfaceOrientationLandscapeLeft == interfaceOrientation
  end
end
