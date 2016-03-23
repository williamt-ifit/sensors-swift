Pod::Spec.new do |spec|
    spec.name           = 'SwiftySensors'
    spec.version        = '0.0.1'
    spec.license        = { :type => 'MIT' }
    spec.homepage       = 'https://github.com/kinetic-fit/sensors-swift'
    spec.authors        = { 'Kinetic' => 'admin@kinetic.fit' }
    spec.summary        = 'BLE Fitness Sensors Communication Utilities for iOS and OSX'
    spec.source         = { :git => 'https://github.com/kinetic-fit/sensors-swift.git',
                            :tag => spec.version.to_s }
    spec.source_files   = 'Source/**/*.swift'

    spec.ios.deployment_target  = '8.4'
    spec.osx.deployment_target  = '10.11'
end
