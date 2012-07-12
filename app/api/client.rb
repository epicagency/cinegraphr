class CMGApiClient
  CLIENT_ID = 'http://cine2.192.168.1.12.xip.io/clients/4fd394fedddc049b35000002'
  CLIENT_SECRET = '9469bdaec2f6764fa43cff297cd991e24c0590f29f5f26c3d2bb17f4ecf98fca'
  AUTHORIZE_URL = 'http://cine2.192.168.1.12.xip.io/oauth/authorize.json'
  TOKEN_URL = 'http://cine2.192.168.1.12.xip.io/oauth/token.json'
  API_URL = 'http://cine2.192.168.1.12.xip.io/'

  def self.default_client
    @default_client || CMGApiClient.new
  end

  attr_reader :username

  def has_credentials?
    !@username.nil? and NSOAuth2AccountStore.sharedStore.accounts.size > 0
  end

  def initialize
    NXOAuth2AccountStore.sharedStore.setClientID(
      CLIENT_ID,
      secret: CLIENT_SECRET,
      authorizationURL: NSURL.URLWithString(AUTHORIZE_URL),
      tokenURL: NSURL.URLWithString(TOKEN_URL),
      redirectURL: NSURL.URLWithString(API_URL),
      forAccountType: "Cinegraphr"
    )
    @username = NSUserDefaults.standardUserDefaults.stringForKey('username')
  end

  def authenticate(username, password)
    NXOAuth2AccountStore.sharedStore.requestAccessToAccountWithType(
      "Cinegraphr",
      username: username,
      password: password
    )
  end

  def me(response_callback)
    account = NXOAuth2AccountStore.sharedStore.accounts.first
    p account
    NXOAuth2Request.performMethod(
      "GET",
      onResource: NSURL.URLWithString(API_URL + "me.json"),
      usingParameters: nil,
      withAccount: account,
      sendProgressHandler: nil,
      responseHandler:response_callback
    )
  end

end
