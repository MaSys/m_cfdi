module CFDI
  class Base
    def self.attr_accessor(*vars)
      @attributes ||= []
      @attributes.concat vars
      super(*vars)
    end

    def self.attributes
      @attributes
    end

    def attributes
      self.class.attributes
    end

    def to_h
      h = {}
      attributes.each { |k| h[k] = send(k) }
      h
    end
  end
end
