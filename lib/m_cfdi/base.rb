module MCFDI
  class Base
    def self.attr_accessor(*vars)
      @attributes ||= []
      @attributes.concat vars
      super(*vars)
    end

    def self.attributes
      @attributes
    end

    # return list of attr_accessors.
    def attributes
      self.class.attributes
    end

    # return hash of attributes with values.
    def to_h
      h = {}
      attributes.each { |k| h[k] = send(k) }
      h
    end
  end
end
