

Pod::Spec.new do |spec|

  spec.name         = "BDASignalSDK"
  spec.version      = "2.0.0"
  spec.summary      = "激活sdk"

  spec.description  = "用于广告主进行归因参数采集"
  spec.homepage = "home"
  spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  spec.author             = { "AchillesL2398" => "AchillesL2398" }

  spec.ios.deployment_target = '15.0'

  spec.source       = { :git => "https://github.com/oceanengine/bda_signal_sdk.git", :branch => 'main', :tag => spec.version.to_s}

  spec.vendored_frameworks = 'lib/BDASignalRequestLib.xcframework'
  spec.source_files  = "BDASignalSDK", "BDASignalSDK/**/*.{h,m,swift}"
  spec.exclude_files = "Classes/Exclude"
  spec.resource_bundles = {
    'BDASignalSDK' => [
    'Assets/PrivacyInfo.xcprivacy'
  ]
}

  spec.swift_version = '5.0'
  spec.pod_target_xcconfig = {
     'ENABLE_MODULES' => 'YES',
     'OTHER_LDFLAGS' => '-ObjC'
  }

end
