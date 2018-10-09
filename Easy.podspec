#
# Be sure to run `pod lib lint Easy.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'Easy'
    s.version          = '0.1.0'
    s.summary          = 'develop Swift with Easy'
    
    s.description      = <<-DESC
    Reduce development time and increase development efficiency
    DESC
    
    s.homepage         = 'https://github.com/OctMon/Easy'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'OctMon' => 'octmon@qq.com' }
    s.source           = { :git => 'https://github.com/OctMon/Easy.git', :tag => "#{s.version}" }
    
    s.ios.deployment_target = '9.0'
    s.swift_version = '4.2'
    
    s.subspec 'Core' do |ss|
        ss.source_files = 'Easy/Classes/Core/*'
        ss.dependency 'SnapKit'#, '~> 4.0.1'
    end
    
    s.subspec 'Session' do |ss|
        ss.source_files = 'Easy/Classes/Session/*'
        ss.dependency 'Alamofire'#, '~> 4.7.3'
    end
    
#    s.subspec 'Test' do |ss|
#        ss.source_files = 'Easy/Classes/Test/*'
#        ss.dependency 'FLEX', '~> 2.4.0'
#        ss.dependency 'GDPerformanceView-Swift', '~> 1.3.2'
#        ss.dependency 'NotificationBannerSwift', '~> 1.7.1'
#    end
    
end
