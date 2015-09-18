require 'rubygems'

task :build do
  sh "xcodebuild -project ./NekoScreenSaverOSX.xcodeproj -scheme NekoScreenSaverOSX -parallelizeTargets -configuration Release -derivedDataPath Build build | xcpretty -c"
end