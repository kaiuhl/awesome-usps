require 'awesome_usps'
require 'test/unit'
require 'redgreen'
require File.dirname(__FILE__) + '/../lib/awesome_usps'

USERNAME = ENV['USPSUSER']
if USERNAME.blank?
  raise "run tests supplying USPSUSER={0} where {0} is your USPS user name."
end
