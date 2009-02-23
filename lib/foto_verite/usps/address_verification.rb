module FotoVerite
  class USPS
    module AddressVerification
      
      class Error < FotoVerite::USPS::Error; end
      class GeneralAddressFoundError < Error; end
      class AddressNotFoundError < Error; end
      
      API_CODES ={
        :verify_address => 'Verify',
        :zip_lookup => 'ZipCodeLookup',
        :city_state_lookup => "CityStateLookup"
      }
      
      TEST_LOCATIONS = [
        Location.new(:address2 => "6406 Ivy Lane", :city => "Greenbelt", :state => "MD"),
        Location.new(:address2 => "8 Wildwood Drive", :city => "Old Lyme", :state => "CT", :zip => "06371")
      ]

      # Examines address and fills in missing information. Address must include city & state or the zip to be processed.
      # Can do up to an array of five
      def verify_address(locations)
        locations = [locations].flatten.map {|loc| Location.from(loc) }
        api_request = "AddressValidateRequest"
        request = xml_for_address_information_api(api_request, locations)
        gateway_commit(:verify_address, 'Verify', request, :live)
      end

      def zip_lookup(locations)
        locations = [locations].flatten.map {|loc| Location.from(loc) }
        api_request = "ZipCodeLookupRequest"
        request = xml_for_address_information_api(api_request, locations)
        gateway_commit(:zip_lookup, 'ZipCodeLookup', request, :live)
      end

      def city_state_lookup(locations)
        locations = [locations].flatten.map {|loc| Location.from(loc) }
        api_request = "CityStateLookupRequest"
        request = xml_for_address_information_api(api_request, locations)
        gateway_commit(:zip_lookup, 'CityStateLookup', request, :live)
      end


      def canned_verify_address_test
        api_request = "AddressValidateRequest"
        request = xml_for_address_information_api(api_request, TEST_LOCATIONS)
        gateway_commit(:verify_address, 'Verify', request, :test)
      end

      def canned_zip_lookup_test
        api_request = "ZipCodeLookupRequest"
        request = xml_for_address_information_api(api_request, TEST_LOCATIONS)
        gateway_commit(:zip_lookup, 'ZipCodeLookup', request, :test)
      end

      def canned_city_state_lookup_test
        api_request = "CityStateLookupRequest"
        request = xml_for_address_information_api(api_request, TEST_LOCATIONS)
        gateway_commit(:zip_lookup, 'CityStateLookup', request, :test)
      end

      # XML from  Builder::XmlMarkup.new
      def xml_for_address_information_api(api_request, locations)
        xm = Builder::XmlMarkup.new
        xm.tag!("#{api_request}", "USERID"=>"#{@username}") do
          locations.each_index do |id|
            l=locations[id]
            xm.Address("ID" => "#{id}") do
              xm.FirmName(l.firm_name)
              xm.Address1(l.address1)
              xm.Address2(l.address2)
              if api_request !="CityStateLookupRequest"
                xm.City(l.city)
                xm.State(l.state)
              end
              if api_request != "ZipCodeLookupRequest"
                xm.Zip5(l.zip5)
                xm.Zip4(l.zip4)
              end
            end
          end
        end
      end

      # Parses the XML into an array broken up by each address.
      # For verify_address :verified will be false if multiple address were found.
      #--
      # TODO: This needs to have access to the original location list
      def parse_address_information(xml)
        if @options[:debug]
          puts "--- Response ---"
          puts xml
        end
        i = 0
        addresses = []
        doc = Hpricot.parse(xml)
        if error = doc.at("error")
          msg = error.at("description").inner_text
          if msg =~ /address not found/i
            raise AddressNotFoundError
          else
            raise Error, "Error during address verification: '#{msg}'"
          end
        end
        doc.search("address").each_with_index do |address, i|
          # Check if there was an error in an address element
          if error =  address.at("error")
            raise Error, "Error during address verification for address ##{i}: '#{error.at("description").inner_text}'"
          end
          loc = Location.new
          address.children.each do |elem|
            next if elem.name == 'returntext'
            loc.send("#{elem.name}=", elem.inner_text) unless elem.inner_text.blank?
          end
          if t = address.at("returntext") and t.inner_text =~ /more information is needed/
            # we need an apartment, suite, or box number to really find the address
            loc.incomplete = true
          end
          addresses << loc
        end
        return addresses
      end

    end # AddressVerification
  end # USPS
end # FotoVerite