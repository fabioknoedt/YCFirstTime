Pod::Spec.new do |spec|
  spec.name             = 'YCFirstTime'
  spec.version          = '2.1.0'
  spec.license          = { :type => 'MIT', :file => 'LICENSE' }
  spec.homepage         = 'https://github.com/fabioknoedt/YCFirstTime'
  spec.authors          = { 'Fabio Knoedt' => 'fabioknoedt@gmail.com' }
  spec.summary          = 'Run Swift code once per install, once per app version, or once every N days.'
  spec.source           = { :git => 'https://github.com/fabioknoedt/YCFirstTime.git', :tag => spec.version.to_s }
  spec.source_files     = 'Sources/YCFirstTime/*.swift'
  spec.ios.deployment_target = '15.0'
  spec.swift_versions   = ['5.0']

  spec.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/YCFirstTimeTests/*.swift'
    test_spec.requires_app_host = true
    test_spec.pod_target_xcconfig = {
      'SWIFT_VERSION' => '5.0'
    }
  end
end
