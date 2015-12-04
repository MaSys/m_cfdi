# business_name -> Razon Social
# fiscal_regime -> Regimen Fiscal
# address -> Domicilio Fiscal
# issued_in -> Expedido en

#
module MCFDI
  # Entity Class for transmitter and receptor
  class Entity < Base
    attr_accessor :rfc, :business_name, :fiscal_regime, :address, :issued_in

    def initialize(args = {})
      args.each { |key, value| send("#{key}=", value) }
    end

    # if address is a hash, create a class of address with the hash.
    def address=(data)
      data = Address.new(data) unless data.is_a? Address
      @address = data
    end

    # if address is a hash, create a class of address with the hash.
    def issued_in=(address)
      return unless address
      data = Address.new(data) unless data.is_a? Address
      @address = data
    end


    # return hash with values for invoice xml.
    def to_x
      { nombre: @business_name, rfc: @rfc }
    end

    # return original string without fiscal regime.
    def original_string
      issued = @issued_in ? @issued_in.original_string : nil
      co = [@rfc, @business_name, @address.original_string]
      co.insert(3, issued) if issued
      co.flatten
    end
  end
end
