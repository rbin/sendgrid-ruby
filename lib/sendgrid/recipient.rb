require 'smtpapi'

module SendGrid
  class Recipient
    class NoAddress < StandardError; end

    attr_reader :address, :substitutions

    def initialize(address)
      @address = address
      @substitutions = {}

      raise NoAddress, 'Recipient address cannot be nil' if @address.nil?
    end

    def add_substitution(key, value)
      substitutions[key.to_sym] = value
    end

    def add_to_smtpapi(smtpapi)
      smtpapi.add_to(@address)

      @substitutions.each do |key, value|
        smtpapi.add_substitution(key, value)
      end
    end
  end
end