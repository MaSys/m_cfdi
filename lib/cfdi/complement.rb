# UUID
# stamp_date = Fecha Timbrado
# cfd_stamp = sello CFD
# sat_certificate_num = noCertificadoSAT
# sat_stamp = selloSAT
# version

#
module CFDI
  # Complement Class
  class Complement < Base

    attr_accessor :uuid, :stamp_date, :cfd_stamp, :sat_certificate_num,
                  :sat_stamp, :version

    # Regresa la cadena Original del Timbre Fiscal Digital del SAT
    #
    # @return [String] la cadena formada
    def string
      a = [@version, @uuid, @stamp_date, @cfd_stamp, @sat_certificate_num]
      "||#{a.join('|')}||"
    end
  end
end
