class CMGLibraryListController < UITableViewController
  def initWithStyle(style)
    super
    self.title = "Cinegraphr"
    @data = UIApplication.sharedApplication.delegate.data_manager.data
    @path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).lastObject
    NSNotificationCenter.defaultCenter.addObserver(self, selector:"new_image", name: "newimage", object:nil)
    self
  end

  def new_image
    self.tableView.reloadData()
  end

  def loadView
    tv = CMGLibraryTableView.alloc.initWithFrame(CGRectZero, style:UITableViewStylePlain);
    tv.separatorStyle = UITableViewCellSeparatorStyleNone;
    tv.delegate = self
    tv.dataSource = self
    self.view = tv
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    (interfaceOrientation == UIInterfaceOrientationPortrait);
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    if @data.size > 0
      193.0
    else
      222.0
    end
  end

  def numberOfSectionsInTableView(tableView)
    1
  end

  def tableView(tableView, numberOfRowsInSection:section)
    if @data.size > 0
      @data.size
    else
      1
    end
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    if @data.size > 0
      cell = tableView.dequeueReusableCellWithIdentifier("LibraryCell")
      if cell.nil?
        cell = CMGLibraryCellView.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:"LibraryCell")
      end
      cine = @data[indexPath.row]
      cell.selectionStyle = UITableViewCellSelectionStyleNone
      cell.thumb_view.image = UIImage.imageWithContentsOfFile(@path.stringByAppendingPathComponent(cine['path']))
      cell.time_label.text = NSDateFormatter.localizedStringFromDate(cine['timestamp'], dateStyle: NSDateFormatterShortStyle, timeStyle: NSDateFormatterNoStyle)
      cell.place_label.text = cine['tag']
    else
      cell = tableView.dequeueReusableCellWithIdentifier("DefaultCell")
      if cell.nil?
        cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "DefaultCell")
        iv = UIImageView.alloc.initWithImage(UIImage.imageNamed("images/zoidberg.png"))
        cell.frame = iv.frame
        cell.addSubview(iv)
      end
    end
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    return if @data.size <= 0
    UIApplication.sharedApplication.statusBarHidden = true
    @viewer = CMGViewerController.alloc.init
    @viewer.loadView()
    @viewer.data = @data[indexPath.row]
    self.presentModalViewController(@viewer, animated: false)
  end
end
