class CMGProfileController < UITableViewController
  # {{{ Table delegate
  def numberOfSectionsInTableView(tableView)
    1
  end

  def tableView(tableView, numberOfRowsInSection: section)
    3
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    case indexPath.row
    when 0
      @name_cell
    when 1
      @username_cell
    when 2
      @email_cell
    end
  end

  def textFieldShouldReturn(textField)
    textField.resignFirstResponder
    true
  end
  # }}}

  def viewWillAppear(animated)
    super
    callback = Proc.new{|response, responseData, error|
      p response
      p responseData
      p error

    }
    UIApplication.sharedApplication.delegate.api_client.me(callback)

  end

  def initWithStyle(style)
    super
    @name_cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "name_cell")
    @name_cell.textLabel.text = "Name"
    @name_cell.textLabel.textColor = UIColor.whiteColor
    @username_cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "username_cell")
    @username_cell.textLabel.text = "Username"
    @username_cell.textLabel.textColor = UIColor.whiteColor
    @email_cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "email_cell")
    @email_cell.textLabel.text = "Email"
    @email_cell.textLabel.textColor = UIColor.whiteColor
    self
  end

  def loadView
    super

    self.tableView.backgroundColor = UIColor.colorWithPatternImage(UIImage.imageNamed("images/background-texture.png"))
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone
  end

end
