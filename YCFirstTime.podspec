Pod::Spec.new do |spec|
  spec.name             = 'YCFirstTime'
  spec.version          = '1.0'
  spec.license          =  :type => 'MIT' 
  spec.homepage         = 'https://github.com/yuppiu/YCFirstTime'
  spec.authors          = 'Fabio Knoedt' => 'fabioknoedt@gmail.com'
  spec.summary          = 'A lightweight library to execute Objective-C codes only once in app life or version life. Execute code/blocks only for the first time the app runs, for example.'
  spec.source           =  :git => 'https://github.com/yuppiu/YCFirstTime.git'
  spec.source_files     = '*.{h,m}'
  spec.requires_arc     = true
end