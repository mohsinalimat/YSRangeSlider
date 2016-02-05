Pod::Spec.new do |s|
  s.name     = 'YSRangeSlider'
  s.version  = '1.0.0'
  s.license  = { :type => 'MIT', :file => 'LICENSE' }
  s.summary  = 'Range slider'
  s.homepage = 'https://github.com/YardiSystems/YSRangeSlider'
  s.source   = { :git => 'https://github.com/YardiSystems/YSRangeSlider.git',
                 :tag => "#{s.version}" }
  s.authors  = { 'Laurentiu Ungur' => 'laurentiu.ungur@yardi.com' }
  s.description = 'Range Slider'
  s.requires_arc = true
  s.platform     = :ios, "7.0"
  s.source_files = 'YSRangeSlider/*.{swift}'
  s.preserve_paths = 'README*'
  
end
