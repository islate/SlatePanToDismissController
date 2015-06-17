Pod::Spec.new do |s|
  s.name             = "SlatePanToDismissController"
  s.version          = "0.1.0"
  s.summary          = "A SlatePanToDismissController."
  s.description      = <<-DESC
			A SlatePanToDismissController. Pan to dismiss the controler. 
                       DESC
  s.homepage         = "https://github.com/mmslate/SlatePanToDismissController"
  s.license          = 'MIT'
  s.author           = { "linyize" => "linyize@gmail.com" }
  s.source           = { :git => "https://github.com/mmslate/SlatePanToDismissController.git", :tag => s.version.to_s }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = '*.{h,m}'
end
