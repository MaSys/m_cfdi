module CFDI
  # Address Class
  class Address < Base
    attr_accessor :street, :street_number, :interior_number, :neighborhood,
                  :location, :reference, :city, :state, :country, :zip_code

    def initialize(args = {})
      args.each { |key, value| send("#{key}=", value) }
    end

    def original_string
      c = []
      self.attributes.each do |k|
        v = send(k)
        next unless v.present?
        c << v
      end
      c
      # [@street, @street_number, @interior_number, @neighborhood, @location,
      #  @reference, @city, @state, @country, @zip_code]
    end

    def to_x
      { calle: @street, noExterior: @street_number,
        noInterior: @interior_number, colonia: @neighborhood,
        localidad: @location, referencia: @reference, municipio: @city,
        estado: @state, pais: @country, codigoPostal: @zip_code }
    end
  end
end
