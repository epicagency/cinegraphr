$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'
require 'rubygems'
require 'sugarcube'

Motion::Project::App.setup do |app|
  app.vendor_project('vendor/OAuth2Client',
                     :xcode,
                     :target => 'OAuth2Client',
                     :headers_dir => 'Sources/OAuth2Client'
                    )
  app.vendor_project('vendor/GPUImage',
                     :xcode,
                     :headers_dir => 'Source'
                    )
  app.libs << "/usr/lib/libz.dylib"

  app.name = 'Cinegraphr'
  app.identifier = 'net.epic.'+app.name

  app.device_family = :iphone
  ['GLKit', 'OpenGLES', 'QuartzCore', 'MobileCoreServices', 'CoreText', 'CoreMedia', 'AVFoundation', 'CoreVideo', 'ImageIO', 'CoreLocation', 'Security', 'CoreImage'].each {|framework|
    app.frameworks << framework
  }
  app.files_dependencies 'app/capture/editor_manager.rb' => ['app/capture/mask/mask_controller.rb', 'app/capture/states/freeze.rb', 'app/capture/states/generate.rb', 'app/capture/states/mask.rb', 'app/capture/states/preview.rb', 'app/capture/states/trim.rb']
  app.prerendered_icon = true

  v = IO.read('.version').to_i
  app.info_plist['CFBundleShortVersionString'] = '0.1.0'
  app.info_plist['CFBundleVersion'] = v.to_s(16)
  app.info_plist['UIApplicationExitsOnSuspend'] = true
  app.info_plist['UIFileSharingEnabled'] = true
  app.entitlements['keychain-access-groups'] = [
    app.seed_id + '.' + app.identifier
  ]
  app.entitlements['get-task-allow'] = true
end
