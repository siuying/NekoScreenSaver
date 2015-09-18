require 'rubygems'

task :build do
  sh "xcodebuild -workspace ./NekoScreenSaverOSX.xcworkspace -scheme NekoScreenSaverOSX -parallelizeTargets -configuration Release -derivedDataPath Build build | xcpretty"
end