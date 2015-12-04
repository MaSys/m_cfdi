module CFDI
  # Address Class
  class Addenda < Base
    attr_accessor :name, :namespace, :xsd, :data

    def initialize(args = {})
      args.each do |key, value|
        method = "#{key}="
        send(method, value) if self.respond_to? method
      end
    end
  end
end
