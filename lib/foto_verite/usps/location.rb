module FotoVerite #:nodoc:
  class USPS
    class Location
      
      class << self
        def from(location_or_hash)
          location_or_hash.is_a?(Location) ? location_or_hash : Location.new(location_or_hash)
        end
      
      private
        def define_attribute_accessors(attribute_names)
          attribute_names.each do |name|
            define_attribute_accessor(name)
          end
        end
        
        def define_attribute_accessor(name)
          define_method(name) { @attributes[name] }
          define_method("#{name}=") {|value| @attributes[name] = value.to_s.upcase }
        end
      
        def define_attribute_aliases(map)
          map.each do |method, method_aliases|
            Array(method_aliases).each do |method_alias|
              alias_accessor method_alias, method
            end
          end
        end
      
        def alias_accessor(method_alias, method)
          alias_method method_alias, method
          alias_method :"#{method_alias}=", :"#{method}="
        end
      end
      
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
      
      define_attribute_accessors @@valid_attributes
      
      define_attribute_aliases :address1 => :address,
                               :zip5 => %w(postal_code postcode postalcode postal zip),
                               :state => %w(province territory region),
                               :firm_name => :firmname

      def initialize(attributes = {})
        @attributes = {}
        attributes.each {|k, v| send("#{k}=", v) }
      end
      
      # used by address verification
      attr_writer :incomplete
      def incomplete?; @incomplete; end
      
      def full_name
        compact(first_name, last_name).join(" ")
      end
      
      def full_address
        compact(address1, address2, address3).join("\n")
      end
      
      def full_zip
        zip5.to_s + (zip4.blank? ? "" : "-#{zip4}")
      end

      def inspect
        attributes = @@valid_attributes.inject([]) {|a,k| v = @attributes[k]; a << "@#{k}=#{v.inspect}" unless v.blank?; a }.join(" ")
        '#<%s:0x%x %s>' % [self.class, self.object_id * 2, attributes]
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
        city_state.to_s + " " + full_zip.to_s
      end
    
      def compact(*strings)
        strings.reject(&:blank?)
      end
      
    end # Location
  end # USPS
end # FotoVerite