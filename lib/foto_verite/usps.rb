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
    def initialize(username)
      @username = validate(username)
    end

    def validate(param)
      raise ERROR_MSG if param.blank?
      param
    end
    
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
