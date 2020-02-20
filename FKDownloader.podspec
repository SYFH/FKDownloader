Pod::Spec.new do |s|
  s.name          = "FKDownloader"
  s.version       = "1.0.0"
  s.summary       = "👍📥 Maybe the best file downloader."
  s.homepage      = "https://github.com/SYFH/FKDownloader"
  s.license       = "MIT"
  s.author        = { "norld" => "syfh@live.com" }
  s.platform      = :ios, "9.0"
  s.source        = { :git => "https://github.com/SYFH/FKDownloader.git", :tag => "#{s.version}" }
  s.source_files  = "FKDownloader/**/*.{h,m}"
  s.exclude_files = "FKDownloader/*.plist"
  s.requires_arc  = true
  s.static_framework = true
  s.frameworks    = 'CoreServices'
end
