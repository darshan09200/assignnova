source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '13.0'

def shared_pods
	pod 'FirebaseAuth'
	pod 'FirebaseFirestore'
	pod 'FirebaseFirestoreSwift'
	pod 'FirebaseAppCheck'
	
	pod "Connectivity"

end

target 'AssignNova' do
	use_frameworks!

	pod 'GoogleMaps', '7.4.0'
	pod 'GooglePlaces', '7.4.0'

	shared_pods

	pod 'FirebaseMessaging'
	pod 'FirebaseStorage'
	pod 'FirebaseStorageUI'
	pod 'FirebaseFunctions'
	
	pod 'GoogleSignIn'
	pod 'GeoFire/Utils'

	pod 'AEOTPTextField'
	pod 'PhoneNumberKit', :git => 'https://github.com/marmelroy/PhoneNumberKit'
	pod 'SDWebImage', '~> 5.0'
	pod "LetterAvatarKit", "1.2.5"
	pod 'EmptyDataSet-Swift'
	pod 'FSCalendar'
	pod 'StripePaymentSheet'
end

target 'Siri' do
	use_frameworks!

	shared_pods
end

post_install do |installer|
	installer.generated_projects.each do |project|
		project.targets.each do |target|
			target.build_configurations.each do |config|
				config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
			end
		end
	end
end
