class CMGFirstRunView < UIView

  attr_reader :choice_view
  attr_reader :login_button
  attr_reader :register_button
  attr_reader :login_view
  attr_reader :login_field
  attr_reader :password_field
  attr_reader :validate_login_button

  def initWithFrame(frame)
    super
    self.backgroundColor = UIColor.colorWithPatternImage(UIImage.imageNamed("default.png"))

    # {{{ Choice view
    @choice_view = UIView.alloc.initWithFrame(frame)
    @choice_view.opaque = false
    self.addSubview(@choice_view)

    label = UILabel.alloc.initWithFrame(CGRectMake(20.0, 20.0, frame.size.width - 40.0, 150.0))
    label.numberOfLines = 5
    label.backgroundColor = UIColor.clearColor 
    label.text = "Want to make pretty pictures?"
    label.textColor = UIColor.whiteColor
    label.textAlignment = UITextAlignmentCenter
    label.font = UIFont.fontWithName("Ultra", size:23.0)
    @choice_view.addSubview(label)

    @login_button = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    @login_button.setTitle('Login', forState: UIControlStateNormal)
    @login_button.frame = CGRectMake(20.0, 300.0, frame.size.width - 40.0, 32.0)
    @choice_view.addSubview(@login_button)

    @register_button = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    @register_button.setTitle('Register', forState: UIControlStateNormal)
    @register_button.frame = CGRectMake(20.0, 342.0, frame.size.width - 40.0, 32.0)
    @choice_view.addSubview(@register_button)
    # }}}

    # {{{ Login view
    @login_view = UIView.alloc.initWithFrame(frame)
    @login_view.backgroundColor = UIColor.colorWithRed(0, green: 0, blue: 0, alpha: 0.5)
    @login_view.hidden = true
    self.addSubview(@login_view)

    @login_field = UITextField.alloc.initWithFrame(CGRectMake(20.0, 20.0, frame.size.width - 40, 24.0))
    @login_field.placeholder = "Username"
    @login_field.backgroundColor = UIColor.whiteColor
    @login_view.addSubview(@login_field)

    @password_field = UITextField.alloc.initWithFrame(CGRectMake(20.0, 64.0, frame.size.width - 40, 24.0))
    @password_field.placeholder = "Password"
    @password_field.backgroundColor = UIColor.whiteColor
    @password_field.secureTextEntry = true
    @login_view.addSubview(@password_field)

    @validate_login_button = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    @validate_login_button .setTitle('Login', forState: UIControlStateNormal)
    @validate_login_button.frame = CGRectMake(20.0, 108.0, frame.size.width - 40.0, 32.0)
    @login_view.addSubview(@validate_login_button)
    # }}}
    self
  end

end
