# CFDI
### CFDI Mexico.

CFDI GEM, to generate XML file for invoice, all you have to do, is to send the xml string to your PAC and receive the final xml file then save it.

# Usage:

```ruby

class Invoice
  def initialize(args = {})
    @invoice = args[:invoice] # assign invoice object from args.
    @cer = args[:cer] # path to .cer file.
    @pem = args[:pem] # path to .pem file.
    @pass = args[:password] # password of .pem file.
    invoice_cfdi
    @invoice_cfdi.transmitter = transmitter # assign transmitter to invoice.
    @invoice_cfdi.receptor = receptor # assign receptor to invoice.
    add_concepts # add concepts to invoice.
    add_taxes # add taxes to invoice.
    certificate_invoice # create certificate and stamp for invoice.
  end

  def invoice_cfdi
    @invoice_cfdi = CFDI::Invoice.new(
      folio: @invoice.folio, series: @invoice.series,
      created_at: @invoice.created_at,
      proof_type: I18n.t("invoice_proof_types.#{@invoice.proof_type}"),
      payment_way: @invoice.payment_way,
      payment_conditions: @invoice.payment_conditions,
      payment_method: @invoice.payment_method,
      expedition_place: @invoice.expedition_place,
      total: @invoice.total, subtotal: @invoice.subtotal
    )
  end

  def transmitter
    { rfc: @invoice.seller.rfc, business_name: @invoice.seller.business_name,
      address: address(@invoice.seller),
      fiscal_regime: @invoice.seller.fiscal_regime }
  end

  def receptor
    { rfc: @invoice.buyer.rfc, business_name: @invoice.buyer.business_name,
      address: address(@invoice.buyer) }
  end

  def address(entity)
    { street: entity.street, street_number: entity.street_number,
      interior_number: entity.interior_number,
      neighborhood: entity.neighborhood, location: entity.location,
      reference: entity.reference, city: entity.city, state: entity.state,
      country: entity.country, zip_code: entity.zip_code }
  end

  def add_concepts
    @invoice.invoice_items.each do |ii|
      @invoice_cfdi.concepts << CFDI::Concept.new(
        quantity: ii.quantity, measure_unit: ii.measure_unit,
        code: ii.code, name: ii.name, price: ii.price, import: ii.import
      )
    end
  end

  def add_taxes
    iva if @invoice.iva > 0
    ieps if @invoice.ieps > 0
    detained_iva if @invoice.detained_iva > 0
    isr if @invoice.isr > 0
  end

  def iva
    @invoice_cfdi.taxes.transferred << CFDI::Transferred.new(
      tax: 'IVA', rate: 16, import: @invoice.iva)
  end

  def ieps
    @invoice_cfdi.taxes.transferred << CFDI::Transferred.new(
      tax: 'IEPS', rate: 12, import: @invoice.ieps)
  end

  def detained_iva
    @invoice_cfdi.taxes.detained << CFDI::Detained.new(
      tax: 'IVA', rate: 16, import: @invoice.detained_iva)
  end

  def isr
    @invoice_cfdi.taxes.detained << CFDI::Detained.new(
      tax: 'ISR', rate: 16, import: @invoice.isr)
  end

  # create certificate and stamp for invoice.
  def certificate_invoice
    certificate = CFDI::Certificate.new(@cer)
    key = CFDI::Key.new(@pem, @pass)
    certificate.certificate(@invoice_cfdi)
    key.seal(@invoice_cfdi)
  end

  # return original string create by CFDI gem.
  def original_string
    @invoice_cfdi.original_string
  end

  # validate original string with schema.
  def validate_original_string
    @invoice_cfdi.validate_original_string
  end

  # return original string created by the schema.
  def original_string_from_xslt
    @invoice_cfdi.original_string
  end

  # return xml of the invoice and save it to file (before seal it with SAT).
  def xml
    file = File.new("#{@invoice.full_folio}-not-billed.xml", "wb")
    file.write(@invoice_cfdi.to_xml)
    file.close
    @invoice_cfdi.to_xml
  end

  # validate xml with schema and return errors.
  def validate_xml
    @invoice_cfdi.validate_xml
  end
end

```

and then, you can call this class by:

```ruby

@invoice = '{YOUR INVOICE OBJECT}'
@in = Invoice.new(
  invoice: @invoice, cer: 'CERTIFICATION_FILE_PATH',
  pem: 'PEM_FILE_PATH",
  password: 'PASSWORD'
)
@in.xml
@in.original_string

```
