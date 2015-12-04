# street -> Calle
# street_number -> Numero Exterior
# interior_number -> Numero Interior
# neighborhood -> Colonia
# location -> Localidad
# reference -> Referencia
# city -> Municipio
# state -> Estado
# country -> Pais
# zip_code -> Codigo Postal

#
module CFDI
  # Address Class for transmitter and receptor.
  class Address < Base
    attr_accessor :street, :street_number, :interior_number, :neighborhood,
                  :location, :reference, :city, :state, :country, :zip_code

    def initialize(args = {})
      args.each { |key, value| send("#{key}=", value) }
    end

    # return original string (cadena original) of the address.
    def original_string
      c = []
      self.attributes.each do |k|
        v = send(k)
        next unless v.present?
        c << v
      end
      c
    end

    # return hash with values in spanish for the xml.
    def to_x
      { calle: @street, noExterior: @street_number,
        noInterior: @interior_number, colonia: @neighborhood,
        localidad: @location, referencia: @reference, municipio: @city,
        estado: @state, pais: @country, codigoPostal: @zip_code }
    end
  end
end
