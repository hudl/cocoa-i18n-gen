Pod::Spec.new do |s|
  s.name             = 'CocoaLoco'
  s.version          = '1.0.8'
  s.summary          = 'A Swift command line tool to help you make sense of large quantities of localizable strings.'
  s.description      = <<-DESC
A Swift command line tool to help you make sense of large quantities of localizable strings.
It has been designed to work as part of your build pipeline to take a JSON file of string definitions
and create a Swift file of namespaced constants.
                       DESC

  s.homepage         = 'https://github.com/hudl/cocoa-i18n-gen'
  s.license          = { :type => 'MIT', :text => <<-LICENSE
                            Copyright (c) 2019 Brian Clymer <brian.clymer@hudl.com>

                            Permission is hereby granted, free of charge, to any person obtaining a copy
                            of this software and associated documentation files (the "Software"), to deal
                            in the Software without restriction, including without limitation the rights
                            to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
                            copies of the Software, and to permit persons to whom the Software is
                            furnished to do so, subject to the following conditions:

                            The above copyright notice and this permission notice shall be included in
                            all copies or substantial portions of the Software.

                            THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
                            IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
                            FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
                            AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
                            LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
                            OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
                            THE SOFTWARE.
                       LICENSE
                       }
  s.author           = { 'Brian Clymer' => 'brian.clymer@hudl.com' }
  s.source           = { :git => 'git@github.com:hudl/cocoa-i18n-gen.git', :tag => s.version.to_s }

  s.source = { :http => "https://github.com/hudl/cocoa-i18n-gen/releases/download/v#{s.version}/cocoa-loco-#{s.version}.zip" }

  s.preserve_paths = "CocoaLoco"
end
