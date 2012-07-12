class CMGFirstRunViewController < UIViewController

  def display_login(sender)
    self.view.choice_view.hidden = true
    self.view.login_view.hidden = false
  end

  def do_login(sender)
    @success_observer = NSNotificationCenter.defaultCenter.addObserverForName(
      NXOAuth2AccountStoreAccountsDidChangeNotification,
      object: NXOAuth2AccountStore.sharedStore,
      queue: nil,
      usingBlock: lambda do |notification|
        CMGModelessAlertView.show_alert_in_view(self.view, "Authentication successful", "Placeholder text", nil, "images/background-alert-blue.png".uiimage)
        NSNotificationCenter.defaultCenter.removeObserver @success_observer
        NSNotificationCenter.defaultCenter.removeObserver @failure_observer
      end
    )
    @failure_observer = NSNotificationCenter.defaultCenter.addObserverForName(
      NXOAuth2AccountStoreDidFailToRequestAccessNotification,
      object: NXOAuth2AccountStore.sharedStore,
      queue: nil,
      usingBlock: lambda do|notification|
        error = notification.userInfo.objectForKey(NXOAuth2AccountStoreErrorKey)
        CMGModelessAlertView.show_alert_in_view(self.view, "Failed to authenticate", error.localizedDescription, nil, "images/background-alert-red.png".uiimage)
        NSLog(error.localizedDescription)
        NSNotificationCenter.defaultCenter.removeObserver @success_observer
        NSNotificationCenter.defaultCenter.removeObserver @failure_observer
      end
    )
    CMGApiClient.default_client.authenticate self.view.login_field.text, self.view.password_field.text
  end

  def init
    super
    self
  end

  def loadView
    self.view = CMGFirstRunView.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    self.view.login_button.addTarget(self, action: "display_login:", forControlEvents: UIControlEventTouchUpInside)
    self.view.validate_login_button.addTarget(self, action: "do_login:", forControlEvents: UIControlEventTouchUpInside)
  end
end
