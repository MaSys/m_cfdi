# transferred -> Impuestos trasladado
# detained -> Impuestos retenidos
# tax -> Nombre del Impuesto
# rate -> Tasa
# import -> Importe

#
module MCFDI
  class Taxes < Base
    attr_accessor :transferred, :detained
    def initialize
      @transferred = []
      @detained = []
    end

    # return total of all transferred taxes.
    def total_transferred
      return 0 unless @transferred.any?
      @transferred.map(&:import).reduce(:+)
    end

    # return total of all detained taxes.
    def total_detained
      return 0 unless @detained.any?
      @detained.map(&:import).reduce(:+)
    end

    # return count of all taxes.
    def count
      @transferred.count + @detained.count
    end

    def transferred=(tax)
      if data.is_a? Array
        data.map do |c|
          c << Transferred.new(c) unless c.is_a? Tansferred
          @transferred << c
        end
      elsif data.is_a? Hash
        @transferred << Transferred.new(data)
      elsif data.is_a? Transferred
        @transferred << data
      end
      @transferred
    end

    def detained=(tax)
      if data.is_a? Array
        data.map do |c|
          c << Detained.new(c) unless c.is_a? Detained
          @detained << c
        end
      elsif data.is_a? Hash
        @detained << Detained.new(data)
      elsif data.is_a? Detained
        @detained << data
      end
      @detained
    end

    # return original string of all transferred taxes.
    def transferred_original_string
      os = []
      @transferred.each do |trans|
        os += trans.original_string
      end
      os
    end

    # return original string of all detained taxes.
    def detained_original_string
      os = []
      @taxes.detained.each do |detaind|
        os += detaind.original_string
      end
      os
    end
  end

  class Transferred
    attr_accessor :tax, :rate, :import

    def initialize(args = {})
      args.each { |key, value| send("#{key}=", value) }
    end

    def rate=(rate)
      @rate = format('%.2f', rate).to_f
    end

    def import=(import)
      @import = format('%.2f', import).to_f
    end

    def original_string
      [@tax, @rate, @import]
    end
  end

  class Detained
    attr_accessor :tax, :rate, :import

    def initialize(args = {})
      args.each { |key, value| send("#{key}=", value) }
    end

    def rate=(rate)
      @rate = format('%.2f', rate).to_f
    end

    def import=(import)
      @import = format('%.2f', import).to_f
    end

    def original_string
      [@tax, @rate, @import]
    end
  end
end
