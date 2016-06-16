Pod::Spec.new do |s|
  s.name             = "SlatePanToDismissController"
  s.version          = "3.4.2.1"
  s.summary          = "A SlatePanToDismissController."
  s.description      = <<-DESC
			A SlatePanToDismissController. Pan to dismiss the controler. 
                       DESC
  s.homepage         = "https://github.com/islate/SlatePanToDismissController"
  s.license          = 'Apache 2.0'
  s.author           = { "linyize" => "linyize@gmail.com" }
  s.source           = { :git => "https://github.com/islate/SlatePanToDismissController.git", :tag => s.version.to_s }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'SlatePanToDismissController/*.{h,m}'
end
