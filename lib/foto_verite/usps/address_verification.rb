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
              # address 1 and address 2 are actually switched in the USPS API for some reason
              # so we need to switch them before sending
              xm.Address1(l.address2)
              xm.Address2(l.address1)
              if api_request != "CityStateLookupRequest"
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
          RAILS_DEFAULT_LOGGER.debug "--- Response ---"
          RAILS_DEFAULT_LOGGER.debug xml
        end
        i = 0
        addresses = []
        doc = Nokogiri::XML(xml)
        incomplete_address = nil
        if error = doc.at_css("Error")
          msg = error.at_css("Description").inner_text
          if msg =~ /multiple addresses were found/i
            # we need an apartment, suite, or box number to really find the address
            incomplete_address = true
          elsif msg =~ /address not found|invalid/i
            raise AddressNotFoundError
          else
            raise Error, "Error during address verification: '#{msg}'"
          end
        end
        doc.css("Address").each_with_index do |address, i|
          loc = Location.new
          # Check if there was an error in an address element
          if error = address.at_css("Error")
            msg = error.at_css("Description").inner_text
            if incomplete_address || msg =~ /multiple addresses were found/i
              loc.incomplete = true
            else
              raise Error, "Error during address verification for address ##{i}: '#{msg}'"
            end
          end
          address.children.each do |elem| 
            name = elem.name
            next if name == 'ReturnText' || name == 'Error'
            # address 1 and address 2 are actually switched in the USPS API for some reason
            # so we need to unswitch them before storing
            if name == "Address1"
              name = "Address2"
            elsif name == "Address2"
              name = "Address1"
            end
            loc.send("#{name.downcase}=", elem.inner_text) unless elem.inner_text.blank?
          end
          if incomplete_address || (t = address.at_css("ReturnText") and t.inner_text =~ /(more information is needed|multiple addresses were found)/i)
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