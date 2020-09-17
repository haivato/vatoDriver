<h2>Use framework in Vato iOS projects by cocoapods</h2>
<h3> How to use: </h3>

1> Install <b>cocoapods</b> if needed:

    brew install cocoapods
2>In Podfile:

    target 'YourTarget' do
        # Comment the next line if you don't want to use dynamic frameworks
        use_frameworks!
        pod 'VatoFramework', :git => 'https://github.com/vatoio/vato-ios-framework' #, :branch => 'your branch'
    end
  
3> <b>pod install</b> or <b>pod update</b> done. :)
