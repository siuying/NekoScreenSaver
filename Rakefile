require 'rubygems'

task :build do
  sh "xcodebuild -project ./NekoScreenSaverOSX.xcodeproj -scheme NekoScreenSaverOSX -parallelizeTargets -configuration Release -derivedDataPath Build build | xcpretty -c"
end

task :run do
  sh "/System/Library/Frameworks/ScreenSaver.framework/Resources/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine -module NekoScreenSaverOSX"
end