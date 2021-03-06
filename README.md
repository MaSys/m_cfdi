```
  __  __       ____               ____
 |  \/  | __ _/ ___| _   _ ___   / ___|___
 | |\/| |/ _` \___ \| | | / __| | |   / _ \
 | |  | | (_| |___) | |_| \__ \ | |__| (_) |
 |_|  |_|\__,_|____/ \__, |___/  \____\___(_)
                     |___/
```

# CFDI
### CFDI Mexico.

CFDI GEM, to generate XML file for invoice, all you have to do, is to send the xml string to your PAC and receive the final xml file then save it.

# Installation:

In your gem file:
```bash
gem 'm_cfdi', '~> 0.3.0'
```

or

```bash
gem 'm_cfdi', git: 'https://github.com/MaSys/m_cfdi.git'
```

or install it directly from your terminal:
```bash
gem install m_cfdi
```

# Usage:

Importante:
```
Dont't forgot to set TimeZone in your app.
```
You have to set timezone in your app to send the invoice date.
if not, it will return an error.

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
    @invoice_cfdi = MCFDI::Invoice.new(
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
      @invoice_cfdi.concepts << MCFDI::Concept.new(
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
    @invoice_cfdi.taxes.transferred << MCFDI::Transferred.new(
      tax: 'IVA', rate: 16, import: @invoice.iva)
  end

  def ieps
    @invoice_cfdi.taxes.transferred << MCFDI::Transferred.new(
      tax: 'IEPS', rate: 12, import: @invoice.ieps)
  end

  def detained_iva
    @invoice_cfdi.taxes.detained << MCFDI::Detained.new(
      tax: 'IVA', rate: 16, import: @invoice.detained_iva)
  end

  def isr
    @invoice_cfdi.taxes.detained << MCFDI::Detained.new(
      tax: 'ISR', rate: 16, import: @invoice.isr)
  end

  # create certificate and stamp for invoice.
  def certificate_invoice
    certificate = MCFDI::Certificate.new(@cer)
    key = MCFDI::Key.new(@pem, @pass)
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
@in.total_to_words # will return total in words.
@in.qr_code # will return 'data:image/png;base64,...'
```

to generate your `.pem` file:

```
openssl pkcs8 -inform DET -in aaa010101aaa.key -passin pass:12345678a -out key.pem
```

To parse your stamped xml to classes:
```ruby
MCFDI.from_xml(XML_STRING)
```
it will return new instance of `MCFDI::Invoice`.


You can also do:
```ruby
MCFDI.proof_types
MCFDI.payment_methods
MCFDI.payment_ways
```
it will return array of values.


# TODO:
* Create configuration class.


# Contributing

Fork it

1. Create your feature branch (git checkout -b my-new-feature)

2. Commit your changes (git commit -am 'Add some feature')

3. Push to the branch (git push origin my-new-feature)

4. Create new Pull Request

