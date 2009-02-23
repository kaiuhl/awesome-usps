module FotoVerite #:nodoc:
  class USPS
    class Location
      
      @@valid_attributes = %w(
        first_name
        last_name
        firm_name
        address1
        address2
        address3
        city
        state
        zip5
        zip4
        country
        phone
        facility_type
        from_urbanization
      )
      
      @@valid_attributes.each do |attr|
        define_method(attr) { @attributes[attr] }
        define_method("#{attr}=") {|value| @attributes[attr] = value }
      end
      
      # address 1 and address 2 are actually switched in the USPS API... dumb or what?!
      %w(address).each do |m|
        alias_method :"#{m}", :address2
        alias_method :"#{m}=", :address2=
      end
      %w(postal_code postcode postalcode postal zip).each do |m|
        alias_method :"#{m}", :zip5
        alias_method :"#{m}=", :zip5=
      end
      %w(province territory region).each do |m|
        alias_method :"#{m}", :state
        alias_method :"#{m}=", :state=
      end
      
      def self.from(location_or_hash)
        location_or_hash.is_a?(Location) ? location_or_hash : Location.new(location_or_hash)
      end

      def initialize(attributes = {})
        @attributes = {}
        attributes.each {|k, v| send("#{k}=", v) }
      end
      
      def full_name
        compact(first_name, last_name).join(" ")
      end
      
      def full_address
        compact(address2, address1, address3).join("\n")
      end
      
      def full_zip
        zip5 + (zip4.blank? ? "" : "-#{zip4}")
      end

      def inspect
        "#<#{self.class}:#{self.hash} " +
        @@valid_attributes.inject([]) {|a,k| v = @attributes[k]; a << "@#{k}=#{v.inspect}" unless v.blank?; a }.join(" ") +
        ">"
      end

      def to_s
        pretty_print.gsub(/\n/, ' ')
      end

      def pretty_print
        compact(full_name, firm_name, full_address, city_state_zip).join("\n")
      end
      
    private
      def city_state
        compact(city, state).join(", ")
      end
      
      def city_state_zip
        city_state + " " + full_zip
      end
    
      def compact(*strings)
        strings.reject(&:blank?)
      end
      
    end # Location
  end # USPS
end # FotoVerite