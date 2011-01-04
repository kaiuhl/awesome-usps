require 'awesome_usps/location'
require 'builder'


module AwesomeUsps
  module AddressVerification
    
    
    
    # Examines address and fills in missing information. Address must include city & state or the zip to be processed.
    # Can do up to an array of five
    def verify_address(*locations)
      marshal_address_verification_request!(:verify, locations)
    end
    
    def zip_lookup(*locations)
      marshal_address_verification_request!(:zip_code_lookup, locations)
    end
    
    def city_state_lookup(*locations)
      marshal_address_verification_request!(:city_state_lookup, locations)
    end
    
    
    
  private
    
    
    
    def marshal_address_verification_request!(api, locations)
      locations = locations.first if locations.first.is_a?(Array)
      request   = write_xml_of_locations              api, locations
      response  = marshal_request!                    api, request
                  parse_address_verification_response response
    end
    
    
    
    # Builder is a pain in the ass
    def write_xml_of_locations(api, locations)
      xml = ""
      # xm = Builder::XmlMarkup.new(xml)
      locations.each_with_index do |l, i|
        xml << <<-XML
        <Address ID="#{i}">
          <FirmName>#{l.firm_name}</FirmName>
          <Address1>#{l.address1}</Address1>
          <Address2>#{l.address2}</Address2>
          <City>#{l.city}</City>
          <State>#{l.state}</State>
          <Zip5>#{l.zip5}</Zip5>
          <Zip4>#{l.zip4}</Zip4>
        </Address>
        XML
        # xm.Address("ID" => i.to_s) do
        #   xm.FirmName(l.firm_name)
        #   xm.Address1(l.address1)
        #   xm.Address2(l.address2)
        #   if api != :city_state_lookup
        #     xm.City(l.city)
        #     xm.State(l.state)
        #   end
        #   if api != :zip_code_lookup
        #     xm.Zip5(l.zip5)
        #     xm.Zip4(l.zip4)
        #   end
        # end
      end
      xml
    end
    
    
    
    # Parses the XML into an array broken up by each address.
    # For verify_address :verified will be false if multiple address were found.
    def parse_address_verification_response(xml)
      i = 0
      list_of_verified_addresses = []
      (Hpricot.parse(xml)/:address).each do |address|
        i+=1
        h = {}
        # Check if there was an error in an address element
        if address.search("error") != []
          RAILS_DEFAULT_LOGGER.info("Address number #{i} has the error '#{address.search("description").inner_html}' please fix before continuing")
          
          return "Address number #{i} has the error '#{address.search("description").inner_html}' please fix before continuing"
        end
        if address.search("ReturnText") != []
          h[:verified] = false
        else
          h[:verified] = true
        end
        address.children.each { |elem| h[elem.name.to_sym] = elem.inner_text unless elem.inner_text.blank? }
        list_of_verified_addresses << h
      end
      #Check if there was an error in the basic XML formating
      if list_of_verified_addresses == []
        error = Hpricot.parse(xml)/:error
        return error.search("description").inner_html
      end
      return list_of_verified_addresses
    end
    
    
    
  end
end