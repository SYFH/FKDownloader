Pod::Spec.new do |s|
  s.name          = "FKDownloader"
  s.version       = "0.0.1"
  s.summary       = "Easy to use multi-file downloader, support background download."
  s.homepage      = "https://github.com/SYFH/FKDownloader"
  s.license       = "MIT"
  s.author        = { "norld" => "syfh@live.com" }
  s.platform      = :ios, "8.0"
  s.source        = { :git => "https://github.com/SYFH/FKDownloader.git", :tag => "#{s.version}" }
  s.source_files  = "FKDownloader", "FKDownloader/*.{h,m}"
  s.exclude_files = ""
  s.requires_arc  = true
end
