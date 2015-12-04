module MCFDI
  require 'openssl'
  
  # openssl pkcs8 -inform DER -in file.key -passin pass:password >> file.pem
  class Key < OpenSSL::PKey::RSA
    def initialize(file, password=nil)
      if file.is_a? String
        file = File.read(file)
      end
      super file, password
    end

    def seal(invoice)
      original_string = invoice.original_string
      invoice.stamp = Base64::encode64(
        self.sign(OpenSSL::Digest::SHA1.new, original_string)).gsub(/\n/, '')
    end
  end
end
