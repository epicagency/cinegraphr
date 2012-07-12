class CMGCaptureController < UIViewController

  attr_accessor :delegate
  attr_reader :current_manager
  attr_reader :current_file

  def start_editing
    @current_manager = CMGEditorManager.alloc.init(self)
  end

  def end_editing
    File.delete! @current_file if File.exist? @current_file
    new_path = @current_file[0..-5]+'-trim.mov'
    File.delete! new_path if File.exist? new_path
    new_path = @current_file[0..-5]+'-filter.mov'
    File.delete! new_path if File.exist? new_path
  end

  def init
    super

    @current_file = NSTemporaryDirectory().stringByAppendingPathComponent("%d.mov" % Time.new.to_i)

    rect = UIScreen.mainScreen.bounds
    self.view = UIView.alloc.initWithFrame(CGRectMake(0, 0, rect.size.height, rect.size.width))

    self
  end

  def viewDidAppear(animated)
    super
    @current_manager = CMGRecorderManager.alloc.init(self)
    #paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)

    #@current_file = "%s/1336640267.mov" % paths[0]
    #start_editing
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
   UIInterfaceOrientationLandscapeRight == interfaceOrientation
  end
end
