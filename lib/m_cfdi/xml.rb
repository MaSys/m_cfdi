module MCFDI
  def self.from_xml(data)
    xml = Nokogiri::XML(data)
    xml.remove_namespaces!
    invoice = Invoice.new
    invoice.taxes = Taxes.new

    proof = xml.at_xpath('//Comprobante')
    transmitter = xml.at_xpath('//Emisor')
    trans_address = transmitter.at_xpath('//DomicilioFiscal')
    issued_in = transmitter.at_xpath('//ExpedidoEn')
    receptor = xml.at_xpath('//Receptor')
    rec_address = receptor.at_xpath('//Domicilio')

    invoice.version = proof.attr('version')
    invoice.series = proof.attr('serie')
    invoice.folio = proof.attr('folio')
    invoice.created_at = Time.parse(proof.attr('fecha'))
    invoice.certificate_number = proof.attr('noCertificado')
    invoice.certificate = proof.attr('certificado')
    invoice.stamp = proof.attr('sello')
    invoice.payment_way = proof.attr('formaDePago')
    invoice.payment_conditions = proof.attr('condicionesDePago')
    invoice.proof_type = proof.attr('tipoDeComprobante')
    invoice.expedition_place = proof.attr('LugarExpedicion')
    invoice.payment_method = proof.attr('metodoDePago')
    invoice.currency = proof.attr('Moneda')
    invoice.payment_account_num = proof.attr('NumCtaPago')
    invoice.total = proof.attr('total').to_f
    invoice.subtotal = proof.attr('subTotal').to_f


    fiscal_regime = transmitter.at_xpath('//RegimenFiscal')

    transmitter = {
      rfc: transmitter.attr('rfc'),
      business_name: transmitter.attr('nombre'),
      fiscal_regime: fiscal_regime  && fiscal_regime.attr('Regimen'),
      address: {
        street: trans_address.attr('calle'),
        street_number: trans_address.attr('noExterior'),
        interior_number: trans_address.attr('noInterior'),
        neighborhood: trans_address.attr('colonia'),
        location: trans_address.attr('localidad'),
        reference: trans_address.attr('referencia'),
        city: trans_address.attr('municipio'),
        state: trans_address.attr('estado'),
        country: trans_address.attr('pais'),
        zip_code: trans_address.attr('codigoPostal')
      }
    }

    if issued_in
      transmitter[:issued_in] = {
        street: issued_in.attr('calle'),
        street_number: issued_in.attr('noExterior'),
        interior_number: issued_in.attr('noInterior'),
        neighborhood: issued_in.attr('colonia'),
        location: issued_in.attr('localidad'),
        reference: issued_in.attr('referencia'),
        city: issued_in.attr('municipio'),
        state: issued_in.attr('estado'),
        country: issued_in.attr('pais'),
        zip_code: issued_in.attr('codigoPostal')
      }
    end

    invoice.transmitter = transmitter

    invoice.receptor = {
      rfc: receptor.attr('rfc'),
      business_name: receptor.attr('nombre')
    }

    if rec_address
      invoice.receptor.address = {
        street: rec_address.attr('calle'),
        street_number: rec_address.attr('noExterior'),
        interior_number: rec_address.attr('noInterior'),
        neighborhood: rec_address.attr('colonia'),
        location: rec_address.attr('localidad'),
        reference: rec_address.attr('referencia'),
        city: rec_address.attr('municipio'),
        state: rec_address.attr('estado'),
        country: rec_address.attr('pais'),
        zip_code: rec_address.attr('codigoPostal')
      }
    end

    invoice.concepts = []
    xml.xpath('//Concepto').each do |concept|
      invoice.concepts << Concept.new(
        quantity: concept.attr('cantidad').to_f,
        measure_unit: concept.attr('unidad'),
        code: concept.attr('noIdentificacion'),
        name: concept.attr('descripcion'),
        price: concept.attr('valorUnitario').to_f,
        import: concept.attr('importe').to_f
      )
    end

    complement = xml.at_xpath('//TimbreFiscalDigital')
    if complement
      invoice.complement = Complement.new(
        version: complement.attr('version'),
        uuid: complement.attr('UUID'),
        stamp_date: complement.attr('FechaTimbrado'),
        cfd_stamp: complement.attr('selloCFD'),
        sat_certificate_num: complement.attr('noCertificadoSAT'),
        sat_stamp: complement.attr('selloSAT')
      )
    end

    xml.xpath('//Traslado').each do |node|
      invoice.taxes.transferred << Transferred.new(
        tax: node.attr('impuesto'),
        rate: node.attr('tasa').to_f,
        import: node.attr('importe').to_f
      )
    end

    xml.xpath('//Retencion').each do |node|
      invoice.taxes.detained << Detained.new(
        tax: node.attr('impuesto'),
        rate: node.attr('tasa').to_f,
        import: node.attr('importe').to_f
      )
    end

    invoice
  end # from_xml
end
