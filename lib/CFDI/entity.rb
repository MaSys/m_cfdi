module CFDI
  # Entity Class
  class Entity < Base
    attr_accessor :rfc, :business_name, :fiscal_regime, :address, :issued_in

    def initialize(args = {})
      args.each { |key, value| send("#{key}=", value) }
    end

    def address=(data)
      data = Address.new(data) unless data.is_a? Address
      @address = data
    end

    def issued_in=(address)
      return unless address
      data = Address.new(data) unless data.is_a? Address
      @address = data
    end

    def ns
      { nombre: @business_name, rfc: @rfc }
    end

    def original_string
      issued = @issued_in ? @issued_in.original_string : nil
      co = [@rfc, @business_name, @address.original_string]
      co.insert(3, issued) if issued
      co.flatten
    end
  end
end
