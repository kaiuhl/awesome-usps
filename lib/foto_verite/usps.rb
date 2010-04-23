module FotoVerite
  class USPS
    
    class Error < StandardError
      def initialize(exception_or_message=nil)
        @message = exception_or_message ? (exception_or_message.is_a?(String) ? exception_or_message : exception_or_message.message) : ""
      end
      
      def message
        @message
      end
      alias_method :to_s, :message
    end
    class ConnectionError < Error
      def message
        "While connecting to the USPS API: #{@message}"
      end
    end
    
    def initialize(username, options={})
      @username = validate(username)
      @options = options
    end

    def validate(param)
      raise ERROR_MSG if param.blank?
      param
    end
  end
end

%w(
  package
  location
  international_item

  tracking
  gateway
  shipping
  delivery_and_signature_confirmation
  service_standard
  open_distribute_priority
  electric_merchandise_return
  express_mail
  address_verification
  international_mail_labels
).each do |file|
  require File.join(File.dirname(__FILE__), 'usps', file)
end

module FotoVerite
  class USPS
    include Tracking
    include Gateway
    include Shipping
    include DeliveryAndSignatureConfirmation
    include ServiceStandard
    include OpenDistributePriority
    include ElectricMerchandiseReturn
    include ExpressMail
    include AddressVerification
    include InternationalMailLabels
  end
end