require File.dirname(__FILE__) + '/test_helper.rb'

class CannedAddressVerificationTest < Test::Unit::TestCase
  include AwesomeUsps
  
  def setup
    @api = AwesomeUsps::Api.new(:username => USERNAME, :server => :test)
  end
  
  
  
  # Run Scripted Test | Address-Information-v3-1.pdf, page 8
  def test_canned_verify_address_test_1
    canned_address = [{:address2 => "6406 Ivy Lane", :city => "Greenbelt", :state => "MD"}]
    expected_result = [{:zip4 => "1440", :state => "MD", :verified => true, :address2 => "6406 IVY LN", :zip5 => "20770", :city => "GREENBELT"}]
    assert_equal expected_result, @api.verify_address(canned_address)
  end
  
  def test_canned_verify_address_test_2
    canned_address = [{:address2 => "8 Wildwood Drive", :city => "Old Lyme", :state => "CT", :zip5 => "06371"}]
    expected_result = [{:zip4 => "1844", :state => "CT", :verified => true, :address2 => "8 WILDWOOD DR", :zip5 => "06371", :city => "OLD LYME"}]
    assert_equal expected_result, @api.verify_address(canned_address)
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
