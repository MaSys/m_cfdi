module CFDI
  # Concepts Class
  class Concept < Base
    attr_accessor :code, :name, :measure_unit, :quantity, :price, :import

    def initialize(args = {})
      args.each { |key, value| send("#{key}=", value) }
    end

    def price=(price)
      @price = format('%.2f', price).to_f
    end

    def import=(import)
      @import = format('%.2f', import).to_f
    end

    def original_string
      [@quantity, @measure_unit, @code, @name, @price.to_f, @import]
    end

    def to_x
      { cantidad: @quantity, unidad: @measure_unit, noIdentificacion: @code,
        descripcion: @name, valorUnitario: @price, importe: @import }
    end
  end
end
