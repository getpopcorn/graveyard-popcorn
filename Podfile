use_frameworks!

source 'https://cdn.cocoapods.org/'
source 'https://github.com/PopcornTimeTV/Specs'

def pods
    pod 'PopcornTorrent', '~> 1.3.0'
    pod 'XCDYouTubeKit', '~> 2.8.0'
    pod 'Alamofire', '~> 4.9.0'
    pod 'AlamofireImage', '~> 3.5.0'
    pod 'SwiftyTimer', '~> 2.1.0'
    pod 'ObjectMapper', '~> 3.5.0'
end

target 'Popcorn-iOS' do
    platform :ios, '13.0'
    pods
    pod 'AlamofireNetworkActivityIndicator', '~> 2.4.0'
    pod 'MobileVLCKit', '~> 3.3.0'
    pod 'QuickTableViewController'
    pod 'GzipSwift'
    pod 'GSKStretchyHeaderView'
    pod 'RPCircularProgress'

    pod 'Firebase/Auth'
    pod 'Firebase/Firestore'
end

target 'Popcorn-tvOS' do
    platform :tvos, '13.0'
    pods
    pod 'TvOSMoreButton', '~> 1.2.0'
    pod 'TVVLCKit', '~> 3.3.0'
    pod 'MBCircularProgressBar', '~> 0.3.5-1'
    pod 'GzipSwift'
end

def kitPods
    pod 'Alamofire', '~> 4.9.0'
    pod 'ObjectMapper', '~> 3.5.0'
    pod 'SwiftyJSON', '~> 5.0.0'
    pod 'Locksmith', '~> 4.0.0'
end

target 'PopcornKit' do
    platform :ios, '13.0'
    kitPods
    pod 'google-cast-sdk', '~> 4.4'
end

target 'PopcornKit-tvOS' do
    platform :tvos, '13.0'
    kitPods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
            config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
            config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
        end
        if ['FloatRatingView-iOS', 'FloatRatingView-tvOS'].include? target.name
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '5.0'
            end
        end
    end
end
