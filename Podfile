source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

def prod_and_dev
    pod 'AFNetworking/UIKit'#, '~> 3.0'
    pod 'AFNetworking'#, '~> 3.0'

    pod 'JSONModel'
    pod 'GoogleMaps', '2.7.0'
    pod 'GooglePlaces'
    pod 'LGPlusButtonsView', '~> 1.1.0'
    pod 'SVPullToRefresh'
    pod 'MBCircularProgressBar'
    pod 'SPSlideTabBarController'
    pod 'KYDrawerController-ObjC'
    pod 'Shimmer'
    pod 'GoogleSignIn'
#    pod 'AXPhotoViewer'

    pod 'Firebase/Core'
    pod 'Firebase/Auth'
    pod 'Firebase/Database'
    pod 'Firebase/Messaging'
    pod 'Firebase/Storage'
    pod 'Firebase/DynamicLinks'
    pod 'Firebase/Firestore'
    pod 'Firebase/Analytics'
    pod 'Firebase/RemoteConfig'

    pod 'ReactiveCocoa', '2.1.8'
    pod 'libextobjc', ' ~> 0.4.1'
    pod 'RSKImageCropper' , '~> 1.6.3'

    pod 'UIAlertView+Blocks'
    pod 'UIImage-ImagePickerCrop'
    pod 'OAStackView'
    pod 'FSCalendar'
    pod 'JVFloatLabeledTextField'
    pod 'PasscodeView'
    pod 'PhoneCountryCodePicker'
    pod 'FCChatHeads'
    pod 'AppAuth','~> 1.2.0'
    pod 'Zip', '~> 1.1'
    pod 'SDWebImagePDFCoder'
    pod 'GSKStretchyHeaderView'
    #pod 'Mixpanel'
    # Momo
    pod 'MomoiOSSwiftSdk', :git => 'https://github.com/momodevelopment/MomoiOSSwiftSdk.git',:branch => "master"
#    pod 'libPhoneNumber-iOS', '~> 0.8'

    pod 'Fabric', '~> 1.9.0'
    pod 'Crashlytics'#, '~> 3.12.0'
    pod 'AXPhotoViewer/SDWebImage'
    pod 'Masonry'
    pod 'KeyPathKit'
    pod 'Atributika'
    pod "GCDWebServer", "~> 3.0"

end

# Vato
def vato
    pod 'VatoFramework', :git => 'https://github.com/vatoio/vato-ios-framework'
end

target 'FC' do
    prod_and_dev
    vato
end

target 'FC DEV' do
    prod_and_dev
    vato
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.2'
        end
    end
end
