#
# Be sure to run `pod lib lint SwiftChart.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SwiftChart"
  s.version          = "1.0.0"
  s.summary          = "Line and Area Chart library"

  s.description      = "Support with multiple and partially filled series, signed floats and touch events and partially filled series."

  s.homepage         = "https://github.com/gpbl/SwiftChart"

  s.license          = 'MIT'
  s.author           = { "Giampaolo Bellavite" => "io@gpbl.org" }
  s.source           = { :git => "https://github.com/gpbl/SwiftChart.git", :tag => 'v1.0.0' }
  s.social_media_url = 'https://twitter.com/gpblv'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Chart/**/*'

end
