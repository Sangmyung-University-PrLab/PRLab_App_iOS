# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'VitalWink' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for VitalWink
  pod 'Alamofire'
  pod 'SwiftyJSON'
  pod 'OpenCV'
  pod 'KakaoSDKCommon'  # 필수 요소를 담은 공통 모듈
  pod 'KakaoSDKAuth'  # 사용자 인증
  pod 'KakaoSDKUser'
  pod 'GoogleSignIn'
  
  target 'VitalWinkTests' do
    inherit! :search_paths
    # Pods for testing
  pod 'ComposableArchitecture'    
  end

  target 'VitalWinkUITests' do
    # Pods for testing
  end

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
