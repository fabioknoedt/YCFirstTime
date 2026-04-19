Pod::Spec.new do |spec|
  spec.name             = 'YCFirstTime'
  spec.version          = '1.2.0'
  spec.license          = { :type => 'MIT', :file => 'LICENSE' }
  spec.homepage         = 'https://github.com/yuppiu/YCFirstTime'
  spec.authors          = { 'Fabio Knoedt' => 'fabioknoedt@gmail.com' }
  spec.summary          = 'A lightweight library to execute Objective-C codes only once in app life or version life.'
  spec.source           = { :git => 'https://github.com/yuppiu/YCFirstTime.git', :tag => spec.version.to_s }
  spec.source_files     = 'YCFirstTime.{h,m}', 'Classes/*.{swift,h,m}'
  spec.requires_arc     = true
  spec.ios.deployment_target = '15.0'
  spec.swift_versions   = ['5.0']
  # Mixed-language pod: Obj-C sources import the generated `${MODULE}-Swift.h`.
  # static_framework keeps downstream consumers from needing `use_frameworks!`.
  spec.static_framework = true

  spec.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*.{h,m,swift}'
    test_spec.requires_app_host = true
    test_spec.pod_target_xcconfig = {
      'SWIFT_OBJC_BRIDGING_HEADER' => '${PODS_TARGET_SRCROOT}/Tests/YCFirstTimeTests-Bridging-Header.h',
      'SWIFT_VERSION' => '5.0'
    }
  end
end