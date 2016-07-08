module MCFDI
  def self.payment_methods
    [
      ['Efectivo', '01'],
      ['Cheque', '02'],
      ['Transferencia electrónica de fondos', '03'],
      ['Tarjetas de crédito', '04'],
      ['Monederos electrónicos', '05'],
      ['Dinero electrónico', '06'],
      ['Vales de despensa', '08'],
      ['Tarjeta de Débito', '28'],
      ['Tarjeta de Servicio', '29'],
      ['Otros', '99']
    ]
  end
end
