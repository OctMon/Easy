#
# Be sure to run `pod lib lint Easy.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'Easy'
    s.version          = '0.6.1'
    s.summary          = 'develop Swift with Easy'
    
    s.description      = <<-DESC
    Reduce development time and increase development efficiency
    DESC
    
    s.homepage         = 'https://github.com/OctMon/Easy'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'OctMon' => 'octmon@qq.com' }
    s.source           = { :git => 'https://github.com/OctMon/Easy.git', :tag => s.version }
    
    s.ios.deployment_target = '9.0'
    s.swift_version = '4.2'
    s.default_subspec = ['Core', 'Device', 'Session']
    
    s.subspec 'Core' do |ss|
        ss.source_files = 'Easy/Classes/Core/*'
        ss.resources = ['Easy/Resources/EasyCore.bundle']
        ss.dependency 'SnapKit'#, '~> 4.0.1' # https://github.com/SnapKit/SnapKit
    end
    
    s.subspec 'Device' do |ss|
        ss.source_files = 'Easy/Classes/Device/*'
        ss.dependency 'Easy/Core'
    end
    
    s.subspec 'Common' do |ss|
        ss.dependency 'MBProgressHUD'#, '~> 1.1.0' # https://github.com/jdg/MBProgressHUD
        ss.dependency 'MJRefresh'#, '~> 3.1.15.7' # https://github.com/CoderMJLee/MJRefresh
        ss.dependency 'RTRootNavigationController'#, '~> 0.6.7' # https://github.com/rickytan/RTRootNavigationController
        ss.dependency 'SDWebImage'#, '~> 4.4.2' # https://github.com/rs/SDWebImage
        #ss.dependency 'SwiftyAttributes'#, '~> 5.0.0' # https://github.com/eddiekaiger/SwiftyAttributes
    end
    
    s.subspec 'Session' do |ss|
        ss.source_files = 'Easy/Classes/Session/*'
        ss.dependency 'Easy/Core'
        ss.dependency 'Alamofire'#, '~> 4.7.3' # https://github.com/Alamofire/Alamofire
    end
    
    s.subspec 'Social' do |ss|
        ss.source_files = 'Easy/Classes/Social/*'
        ss.resources = ['Easy/Resources/EasySocial.bundle']
        ss.dependency 'Easy/Core'
        ss.dependency 'Easy/Device'
        ss.dependency 'MonkeyKing'#, '~> 1.12.1' # https://github.com/nixzhu/MonkeyKing
    end
    
    s.subspec 'Scan' do |ss|
        ss.source_files = 'Easy/Classes/Scan/*'
        ss.dependency 'Easy/Core'
    end
    
    s.subspec 'Page' do |ss|
        ss.source_files = 'Easy/Classes/Page/*'
        ss.dependency 'Easy/Core'
        ss.dependency 'WMPageController'#, '~> 1.6.1' # https://github.com/wangmchn/WMPageController
    end
    
    s.subspec 'Beta' do |ss|
        ss.source_files = 'Easy/Classes/Beta/*'
        ss.dependency 'Easy/Core'
        ss.dependency 'Easy/Session'
        ss.dependency 'FLEX'#, '~> 2.4.0' # https://github.com/Flipboard/FLEX
        #ss.dependency 'GDPerformanceView-Swift'#, '~> 1.3.2' # https://github.com/dani-gavrilov/GDPerformanceView-Swift
        ss.dependency 'NotificationBannerSwift'#, '~> 1.7.3' # https://github.com/Daltron/NotificationBanner
        ss.xcconfig = { 'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => '$(inherited) BETA' }
    end
    
end
