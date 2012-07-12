class AppDelegate
  attr_reader :data_manager

  def application(application, didFinishLaunchingWithOptions: launchOptions)

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

    @data_manager = CMGDataManager.new
    @api_client = CMGApiClient.default_client

    if true # @api_client.has_credentials?
      root = CMGRootViewController.alloc.init
    else
      root = CMGFirstRunViewController.alloc.init
    end

    @window.rootViewController = root
    @window.makeKeyAndVisible()

    true
  end

  def show_root
    @window.rootViewController = CMGRootViewController.alloc.init
  end

  def applicationDidEnterBackground(application)
    @data_manager.save_cache
    NSUserDefaults.standardUserDefaults.synchronize
  end
end
