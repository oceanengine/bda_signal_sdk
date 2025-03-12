

Pod::Spec.new do |spec|

  spec.name         = "BDASignalSDK"
  spec.version      = "1.0.5"
  spec.summary      = "激活sdk"

  spec.description  = "用于广告主进行归因参数采集"
  spec.homepage = "home"
  spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  spec.author             = { "AchillesL2398" => "AchillesL2398" }

  spec.ios.deployment_target = '10.0'

  spec.source       = { :git => "https://github.com/oceanengine/bda_signal_sdk.git", :branch => 'main', :tag => spec.version.to_s}


  spec.source_files  = "BDASignalSDK", "BDASignalSDK/**/*.{h,m}"
  spec.exclude_files = "Classes/Exclude"
  spec.resource_bundles = {
    'BDASignalSDK' => [
    'Assets/PrivacyInfo.xcprivacy'
  ]
}

  # spec.public_header_files = "Classes/**/*.h"
  # spec.dependency 'Protobuf'


end
