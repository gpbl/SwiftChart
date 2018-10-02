
Pod::Spec.new do |s|
  s.name             = "SwiftChart"
  s.version          = "1.0.1"
  s.summary          = "Line and area chart library"
  s.description      = "Support multiple and partially filled series, signed floats, touch events."
  s.homepage         = "https://github.com/gpbl/SwiftChart"
  s.license          = 'MIT'
  s.author           = { "Giampaolo Bellavite" => "io@gpbl.org" }
  s.source           = { :git => "https://github.com/gpbl/SwiftChart.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/gpblv'

  s.platform     = :ios, '8.3'
  s.swift_version = '4.2'
  s.requires_arc = true

  s.source_files = 'Source/*.swift'

  s.frameworks = 'UIKit'
end
