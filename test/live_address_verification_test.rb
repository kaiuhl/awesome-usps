require File.dirname(__FILE__) + '/test_helper.rb'

class LiveAddressVerificationTest < Test::Unit::TestCase
  include AwesomeUsps
  
  def setup
    @api = AwesomeUsps::Api.new(:username => USERNAME, :server => :production)
  end
  
  
  
  def test_uncanned_verify_address_call_on_test_api
    sloppy_address = [{:street => '3558 Jeffreson Av', :city => 'StL', :state => 'Missouri', :zip5 => '63118'}]
    expected_result = [{:address2 => '3558 S JEFFERSON AVE', :city => 'ST LOUIS', :state => 'MO', :zip5 => '63118', :verified => true}]
    assert_equal expected_result, @api.verify_address(sloppy_address)
  end
  
  
  
  
  # def canned_verify_address_test
  #   locations = [Location.new(:address2 => "6406 Ivy Lane", :city =>"Greenbelt", :state => "MD"), Location.new(:address2=>"8 Wildwood Drive", :city => "Old Lyme",:state => "CT", :zip5 => "06371"   )]
  #   api_request = "AddressValidateRequest"
  #   request = xml_for_address_information_api(api_request, locations)
  #   gateway_commit(:verify_address, 'Verify', request, :test)
  # end
  # 
  # def canned_zip_lookup_test
  #   locations = [Location.new(:address2 => "6406 Ivy Lane", :city =>"Greenbelt", :state => "MD"), Location.new(:address2=>"8 Wildwood Drive", :city => "Old Lyme",:state => "CT", :zip5 => "06371"   )]
  #   api_request = "ZipCodeLookupRequest"
  #   request = xml_for_address_information_api(api_request, locations)
  #   gateway_commit(:zip_lookup, 'ZipCodeLookup', request, :test)
  # end
  # 
  # def canned_city_state_lookup_test
  #   locations = [Location.new(:address2 => "6406 Ivy Lane", :city =>"Greenbelt", :state => "MD"), Location.new(:address2=>"8 Wildwood Drive", :city => "Old Lyme",:state => "CT", :zip5 => "06371")]
  #   api_request = "CityStateLookupRequest"
  #   request = xml_for_address_information_api(api_request, locations)
  #   gateway_commit(:zip_lookup, 'CityStateLookup', request, :test)
  # end
  
  
  
end
