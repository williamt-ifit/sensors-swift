Pod::Spec.new do |spec|

    spec.name           = 'SwiftySensors'
    spec.version        = '0.1.0'
    spec.summary        = 'BLE Fitness Sensors Communication Utilities for iOS and OSX'

    spec.homepage       = 'https://github.com/kinetic-fit/sensors-swift'
    spec.license        = { :type => 'MIT', :file => 'LICENSE' }    
    spec.author         = { 'Kinetic' => 'admin@kinetic.fit' }
    
    spec.ios.deployment_target  = '8.2'
    spec.osx.deployment_target  = '10.11'

    spec.source         = { :git => 'https://github.com/kinetic-fit/sensors-swift.git',
                            :tag => spec.version.to_s,
                            :submodules => true }
    spec.source_files   = 'Source/**/*.swift'

    spec.dependency     'Signals', '~> 3.0'


    spec.subspec 'Serializers' do |serial|
        serial.source_files = 'Source/Serializers/**/*.swift'
    end
    
end
