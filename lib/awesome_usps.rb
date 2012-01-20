require 'rubygems'
require 'hpricot'
require 'net/https'
require 'active_support/all'

require 'awesome_usps/tracking'
require 'awesome_usps/gateway'
require 'awesome_usps/shipping'
require 'awesome_usps/delivery_and_signature_confirmation'
require 'awesome_usps/service_standard'
require 'awesome_usps/open_distrubute_priority'
require 'awesome_usps/electric_merchandis_return'
require 'awesome_usps/express_mail'
require 'awesome_usps/address_verification'
require 'awesome_usps/international_mail_labels'
require 'awesome_usps/package'
require 'awesome_usps/location'
# require 'awesome_usps/international_item'

module AwesomeUsps
  class USPS
    
    def initialize(username, platform=:ssl)
      @username = validate(username)
	  @platform = platform
    end
    
    def validate(param)
      raise ERROR_MSG if param.blank?
      param
    end
    
    include AwesomeUsps::Tracking
    include AwesomeUsps::Gateway
    include AwesomeUsps::Shipping
    include AwesomeUsps::DeliveryAndSignatureConfirmation
    include AwesomeUsps::ServiceStandard
    include AwesomeUsps::OpenDistrubutePriority
    include AwesomeUsps::ElectricMerchandisReturn
    include AwesomeUsps::ExpressMail
    include AwesomeUsps::AddressVerification
    include AwesomeUsps::InternationalMailLabels

  end
end
