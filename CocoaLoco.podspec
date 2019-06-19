Pod::Spec.new do |s|
  s.name             = 'CocoaLoco'
  s.version          = '1.0.3'
  s.summary          = 'A Swift command line tool to help you make sense of large quantities of localizable strings.'
  s.description      = <<-DESC
A Swift command line tool to help you make sense of large quantities of localizable strings.
                       DESC

  s.homepage         = 'https://github.com/hudl/cocoa-i18n-gen'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Brian Clymer' => 'brian.clymer@hudl.com' }
  s.source           = { :git => 'git@github.com:hudl/cocoa-i18n-gen.git', :tag => s.version.to_s }

  s.source = { :http => "https://github.com/hudl/cocoa-i18n-gen/releases/download/v#{s.version}/cocoa-loco-#{s.version}.zip" }
end
