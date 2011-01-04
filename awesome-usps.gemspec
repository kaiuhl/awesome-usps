# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
require 'awesome_usps/version'
  
Gem::Specification.new do |s|
  s.name         = "awesome-usps"
  s.version      = AwesomeUsps::VERSION
  s.platform     = Gem::Platform::RUBY
  s.authors      = ["Matthew Bergman", "Bob Lail"]
  s.email        = ["mzbphoto@gmail.com", "robert.lail@cph.org"]
  s.homepage     = "https://github.com/FotoVerite/awesome-usps"
  s.summary      = "A ruby wrapper around the various USPS APIs for generating rates, tracking information, label generation, and address checking."
  s.description  = "A ruby wrapper around the various USPS APIs for generating rates, tracking information, label generation, and address checking."
                   
  s.required_rubygems_version = ">= 1.3.6"
  s.add_dependency "activesupport"
  s.add_dependency "hpricot"
                           
  s.files        = Dir.glob("{lib}/**/*") + %w(MIT-LICENSE README.markdown)
  s.executables  = []
  s.require_path = 'lib'
end
