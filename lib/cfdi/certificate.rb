# certificate_number -> noCertificado

#
module CFDI
  require 'openssl'

  # Certificate class to generate invoice certification from .cer.
  class Certificate < OpenSSL::X509::Certificate
    
    # Certificate Number
    attr_reader :certificate_number
    # Certificate in Base64
    attr_reader :data

        # Importar un certificado de sellado
        # @param  file [IO, String] El `path` del certificado o un objeto #IO
        # 
        # @return [CFDI::Certificado] Un certificado
    def initialize (file)
      if file.is_a? String
        file = File.read(file)
      end
      super file
      
      @certificate_number = '';
      self.serial.to_s(16).scan(/.{2}/).each { |v| @certificate_number += v[1]; }
      @data = self.to_s.gsub(/^-.+/, '').gsub(/\n/, '')
      
    end

    def certificate(invoice)
      invoice.certificate_number = @certificate_number
      invoice.certificate = @data
    end
  end
end
