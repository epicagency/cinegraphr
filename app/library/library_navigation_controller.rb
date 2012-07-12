class CMGLibraryNavigationController < UINavigationController
  def tabBarItem
    UITabBarItem.alloc.initWithTitle("My Cinemagraphs", image:nil, tag:0)
  end

  def viewDidLoad
    super

    @list = CMGLibraryListController.alloc.initWithStyle(UITableViewStylePlain)
    controllers = [@list]
    self.setViewControllers([@list], animated: false)
    self.view.backgroundColor = UIColor.colorWithPatternImage(UIImage.imageNamed("images/background-texture.png"))
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    interfaceOrientation == UIInterfaceOrientationPortrait
  end

end
