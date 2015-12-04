# created_at -> Fecha
# proof_type -> Tipo Comprobante
# payment_way -> Forma de Pago
# payment_conditions -> Condiciones de Pago
# exchange_rate -> Tipo de Cambio
# currency -> Moneda
# payment_method -> Metodo de Pago
# expedition_place -> Lugar de Expedicion
# transmitter -> Emisor
# receptor -> Receptor
# concepts -> Conceptos
# series -> Serie
# stamp -> Sello
# taxes -> Impuestos
# canceled -> Cancelada
# certificate_number -> noCertificado
# certificate -> Certificado
# complement -> Complemento
# payment_account_num -> numCtaPago
# addenda -> Addenda

#
module MCFDI
  # Invoice Class the most important class.
  class Invoice < Base
    attr_accessor :version, :created_at, :proof_type, :payment_way,
                  :payment_conditions, :subtotal, :exchange_rate, :currency,
                  :total, :payment_method, :expedition_place, :transmitter,
                  :receptor, :concepts, :series, :folio, :stamp,
                  :taxes, :canceled, :certificate_number, :certificate,
                  :complement, :payment_account_num, :addenda

    # default values.
    @@defaults = {
      tax_rate: 0.16, currency: 'pesos', version: '3.2', subtotal: 0.0,
      exchange_rate: 1, concepts: [], taxes: Taxes.new, proof_type: 'ingreso',
      total: 0.0
    }

    # to change default values.
    def self.configure(options)
      @@defaults = Invoice.rmerge(@@defaults, options)
      @@defaults
    end

    def initialize(args = {})
      args = @@defaults.merge(args)
      args.each do |key, value|
        method = "#{key}="
        next unless self.respond_to? method
        send(method, value)
      end
    end

    def transmitter=(data)
      data = Entity.new(data) unless data.is_a? Entity
      @transmitter = data
    end

    def receptor=(data)
      data = Entity.new(data) unless data.is_a? Entity
      @receptor = data
    end

    def concepts=(data)
      @concepts = []
      if data.is_a? Array
        data.map do |c|
          c = Concept.new(c) unless c.is_a? Concept
          @concepts << c
        end
      elsif data.is_a? Hash
        @concepts << Concept.new(data)
      elsif data.is_a? Concept
        @concepts << data
      end
      @concepts
    end

    def created_at=(date)
      date = date.strftime('%FT%R:%S') unless date.is_a? String
      @created_at = date
    end

    def addenda=(addenda)
      addenda = Addenda.new addenda unless addenda.is_a? Addenda
      @addenda = addenda
    end

    # save xml to file and generate original string from schema.
    def original_string_from_xslt
      # fail 'You have to specify schema!' unless # TODO: create configuration.
      save_xml
      xml = "#{Rails.root}/#{@transmitter.rfc}-#{@series}-#{@folio}.xml"
      sch = "#{Rails.root}/public/sat/schemas/cadenaoriginal_3_2.xslt"
      @original_string_from_xslt ||= `xsltproc #{sch} #{xml}`
    end

    # Save invoice xml to file
    def save_xml
      file = File.new("#{@transmitter.rfc}-#{@series}-#{@folio}.xml", 'w+')
      file.write(to_xml)
      file.close
    end

    # Validate original string with the original string from schema
    def validate_original_string
      original_string == original_string_from_xslt
    end

    # return array of presented attributes.
    # if any attribute does not have a value, will not be pushed to the array.
    def attributes
      a = [
        @version, @created_at, @proof_type, @payment_way, @payment_conditions,
        @subtotal.to_f, @exchange_rate, @currency, @total.to_f, @payment_method,
        @expedition_place, @payment_account_num]
      c = []
      a.each do |v|
        next unless v.present?
        c << v
      end
      c
    end

    # Cadena Original
    def original_string
      params = []

      attributes.each { |key| params << key }
      params += @transmitter.original_string
      params << @transmitter.fiscal_regime
      params += @receptor.original_string

      @concepts.each do |concept|
        params += concept.original_string
      end

      if @taxes.transferred.any?
        params += @taxes.transferred_original_string
        params += [@taxes.total_transferred]
      end

      if @taxes.detained.any?
        params += @taxes.detained_original_string
        params += [@taxes.total_detained]
      end

      params.select(&:present?)
      params.map! do |elem|
        if elem.is_a? Float
          elem = format('%.2f', elem)
        else
          elem = elem.to_s
        end
        elem
      end

      "||#{params.join('|')}||"
    end # / Original_string

    # return xml of the invoice.
    def to_xml
      ns = {
        'xmlns:cfdi' => 'http://www.sat.gob.mx/cfd/3',
        'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        'xsi:schemaLocation' => 'http://www.sat.gob.mx/cfd/3 http://www.sat.gob.mx/sitio_internet/cfd/3/cfdv32.xsd',
        version: @version,
        folio: @folio,
        fecha: @created_at,
        formaDePago: @payment_way,
        subTotal: format('%.2f', @subtotal),
        Moneda: @currency,
        total: format('%.2f', @total),
        metodoDePago: @payment_method,
        tipoDeComprobante: @proof_type,
        LugarExpedicion: @expedition_place
      }
      ns[:condicionesDePago] = @payment_conditions if
        @payment_conditions.present?
      ns[:serie] = @series if @series
      ns[:TipoCambio] = @exchange_rate if @exchange_rate
      ns[:NumCtaPago] = @payment_account_num if @NumCtaPago.present?

      if @addenda
        ns["xmlns:#{@addenda.name}"] = @addenda.namespace
        ns['xsi:schemaLocation'] += (
          ' ' + [@addenda.namespace, @addenda.xsd].join(' '))
      end

      if @certificate_number
        ns[:noCertificado] = @certificate_number
        ns[:certificado] = @certificate
      end

      ns[:sello] = @stamp if @stamp

      @builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.Comprobante(ns) do
          ins = xml.doc.root.add_namespace_definition('cfdi', 'http://www.sat.gob.mx/cfd/3')
          xml.doc.root.namespace = ins

          xml.Emisor(@transmitter.to_x) do
            xml.DomicilioFiscal(
              @transmitter.address.to_x.reject { |_, v| !v.present? })
            xml.ExpedidoEn(
              @transmitter.issued_in.to_x.reject { |_, v| !v.present? }
            ) if @transmitter.issued_in
            xml.RegimenFiscal(Regimen: @transmitter.fiscal_regime)
          end

          xml.Receptor(@receptor.to_x) do
            xml.Domicilio(@receptor.address.to_x.reject { |_, v| !v.present? })
          end

          xml.Conceptos do
            @concepts.each do |concept|
              concept_complement = nil

              cc = concept.to_x.select { |_, v| v.present? }

              cc = cc.map do |k, v|
                v = format('%.2f', v) if v.is_a? Float
                [k, v]
              end.to_h

              xml.Concepto(cc) { xml.ComplementoConcepto if concept_complement }
            end
          end

          if @taxes.count > 0
            tax_options = {}
            total_trans = format('%.2f', @taxes.total_transferred)
            total_detained = format('%.2f', @taxes.total_detained)
            tax_options[:totalImpuestosTrasladados] = total_trans if
              total_trans.to_i > 0
            tax_options[:totalImpuestosRetenidos] = total_detained if
              total_detained.to_i > 0
            xml.Impuestos(tax_options) do
              if @taxes.transferred.count > 0
                xml.Traslados do
                  @taxes.transferred.each do |trans|
                    xml.Traslado(impuesto: trans.tax, tasa: format('%.2f', trans.rate),
                                 importe: format('%.2f', trans.import))
                  end
                end
              end
              if @taxes.detained.count > 0
                xml.Retenciones do
                  @taxes.detained.each do |det|
                    xml.Retencion(impuesto: det.tax, tasa: format('%.2f', det.rate),
                                  importe: format('%.2f', det.import))
                  end
                end
              end
            end
          end

          xml.Complemento do
            if @complemento
              schema = 'http://www.sat.gob.mx/TimbreFiscalDigital '\
                       'http://www.sat.gob.mx/TimbreFiscalDigital/'\
                       'TimbreFiscalDigital.xsd'
              ns_tfd = {
                'xsi:schemaLocation' => schema,
                'xmlns:tfd' => 'http://www.sat.gob.mx/TimbreFiscalDigital',
                'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance'
              }
              xml['tfd'].TimbreFiscalDigital(@complemento.to_h.merge ns_tfd)
            end
          end

          if @addenda
            xml.Addenda do
              @addenda.data.each do |k, v|
                if v.is_a? Hash
                  xml[@addenda.nombre].send(k, v)
                elsif v.is_a? Array
                  xml[@addenda.nombre].send(k, v)
                else
                  xml[@addenda.nombre].send(k, v)
                end
              end
            end
          end
        end
      end
      @builder.to_xml
    end # to_xml

    # validate generated xml with the schema
    def validate_xml
      errors = []
      schema_file = "#{Rails.root}/public/sat/schemas/cfdv32.xsd"
      xsd = Nokogiri::XML::Schema(File.read(schema_file))
      doc = Nokogiri::XML(to_xml)

      xsd.validate(doc).each do |error|
        errors << error.message
      end
      errors
    end # Validate_xml
  end
end
