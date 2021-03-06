
Pod::Spec.new do |s|
  s.name         = "KMCAgoraVRTC"
  s.version      = "2.0.4"
  s.summary      = "金山魔方视频连麦方案"
  s.ios.deployment_target = "8.0"
  s.description  = <<-DESC
                   * 金山魔方视频连麦方案iOS：声网1对1视频直播连麦产品，是全球首个基于UDP的直播连麦SDK，支持iOS、Android、多平台互通，适配了5000+机型，在回声消除、降噪、防啸叫方面表现优异。。
                   DESC

  s.homepage     = "https://kmc.console.ksyun.com/"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See http://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  s.license      = {:type => 'Proprietary', :text => <<-LICENSE
  Copyright 2015 kingsoft Ltd. All rights reserved.
  LICENSE
  }

  s.author             = { "Noiled" => "zhangjun5@kingsoft.com" }

  s.source       = { :git => "https://github.com/ksvcmc/KMCAgoraVRTC_iOS.git", :tag => "v#{s.version}" }

  s.vendored_frameworks = "framework/KMCAgoraVRTC.framework"
  s.requires_arc = true

  
end
