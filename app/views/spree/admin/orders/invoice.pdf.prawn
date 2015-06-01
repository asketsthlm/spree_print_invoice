define_grid(columns: 10, rows: 16, gutter: 10)

@font_face = Spree::PrintInvoice::Config[:font_face]
@font_size = Spree::PrintInvoice::Config[:font_size]

line_width 0.001
line -90,265.63,-70,265.63
line -90,546.26,-70,546.26

line_width 3
line 197.6,150,217.64,150
# HEADER
repeat(:all) do
  im = Rails.application.assets.find_asset(Spree::PrintInvoice::Config[:logo_path])
  if im && File.exist?(im.pathname)
    image im.pathname, vposition: :top, position: :center, height: 110
  end

  font "ChronicleDisp"
  move_down 27
  text "Your Delivery", align: :center, style: :bold, size: 40
#  move_down 4
#  text Spree.t(:order_number, number: @order.number), align: :right
#  move_down 2
#  text I18n.l(@order.completed_at.to_date), align: :right
end

# CONTENT
grid([5,0], [12,9]).bounding_box do

  font "FoundersGrotesk", size: @font_size
  bill_address = @order.bill_address
  ship_address = @order.ship_address
  move_down 20
  text "#{bill_address.firstname.upcase} #{bill_address.lastname.upcase}", style: :bold, character_spacing: 0.3
  #, character_spacing: 0.5

  move_down 20

  

  order_number_h  = make_cell(content: "Order Number".upcase, font_style: :bold, borders: [], padding: 0)
  order_date_h = make_cell(content: "Order Date".upcase, font_style: :bold, borders: [], padding: 0)
  payment_method_h = make_cell(content: "Payment Method".upcase, font_style: :bold, borders: [], padding: 0)
  delivery_h = make_cell(content: "Delivery".upcase, font_style: :bold, borders: [], padding: 0)

  order_number = make_cell(content: @order.number.to_s, borders: [], padding: 0)
  order_date = make_cell(content: I18n.l(@order.completed_at.to_date), borders: [], padding: 0)
  payment_method = make_cell(content: "Credit Card (Paid)", borders: [], padding: 0)
  delivery = make_cell(content: @order.shipments[0].shipping_method.name, borders: [], padding: 0)

  data = [[order_number_h, order_date_h, payment_method_h, delivery_h], [order_number, order_date, payment_method, delivery]]
  table(data, position: :left, column_widths: [103, 104,103,104])

  move_down 20
  address_cell_billing  = make_cell(content: Spree.t(:billing_address).upcase, font_style: :bold, borders: [], padding: 0)
  address_cell_shipping = make_cell(content: Spree.t(:shipping_address).upcase, font_style: :bold, borders: [], padding: 0)

  #billing =  "#{bill_address.firstname} #{bill_address.lastname}"
  billingt = "#{bill_address.address1}"
  billingt << ", #{bill_address.address2}" unless bill_address.address2.blank?
  billingt << "\n#{bill_address.city}, #{bill_address.state_text} #{bill_address.zipcode}"
  billingt << ", #{bill_address.country.name}"
  #billing << "\n#{bill_address.phone}"
  billing = make_cell(content: billingt, borders: [], padding: 0)

  #shipping =  "#{ship_address.firstname} #{ship_address.lastname}"
  shippingt = "#{ship_address.address1}"
  shippingt << ", #{ship_address.address2}" unless ship_address.address2.blank?
  shippingt << "\n#{ship_address.city}, #{ship_address.state_text} #{ship_address.zipcode}"
  shippingt << ", #{ship_address.country.name}"
  #shipping << "\n#{ship_address.phone}"
  #shipping << "\n\n#{Spree.t(:via, scope: :print_invoice)} #{@order.shipments.first.shipping_method.name}"
  shipping = make_cell(content: shippingt, borders: [], padding: 0)

  data = [[address_cell_shipping], [shipping]]
  table(data, position: :left, column_widths: [207])


  move_down 40

  header = [
    make_cell(content: Spree.t(:sku).upcase),
    make_cell(content: Spree.t(:item).upcase),
    make_cell(content: "Color".upcase),
    make_cell(content: "Size".upcase),
    make_cell(content: Spree.t(:qty).upcase),
    make_cell(content: Spree.t(:price).upcase),
    make_cell(content: Spree.t(:total).upcase)
  ]
  data = [header]

  @order.line_items.each do |item|
    row = [
      item.variant.sku,
      item.variant.name,
      item.variant.option_values[0].presentation,
      item.variant.option_values[1].presentation + " - " + item.variant.option_values[2].presentation,
      item.quantity,
      item.single_display_amount.to_s,
      item.display_total.to_s
    ]
    data += [row]
  end

  table(data, header: true, position: :right, column_widths: [60, 80, 67, 73, 44, 40, 50]) do
    row(0).style align: :center, font_style: :bold, borders: [], padding: 0
    column(0..4).style align: :left, borders: [], padding: 0
    column(5..6).style align: :right, borders: [], padding: 0
    row(-1).style borders: [:bottom], border_widths: [0,0,0.1,0], padding_bottom: 5
  end

  # TOTALS
  move_down 5
  totals = []

  # Subtotal
  totals << [make_cell(content: Spree.t(:subtotal)), @order.display_item_total.to_s]

  # Adjustments
  @order.all_adjustments.eligible.each do |adjustment|
    totals << [make_cell(content: adjustment.label), adjustment.display_amount.to_s]
  end

  # Shipments
  @order.shipments.each do |shipment|
    totals << [make_cell(content: "Shipping"), shipment.display_cost.to_s]
  end

  # Totals
  totals << [make_cell(content: Spree.t(:order_total)), @order.display_total.to_s]

  # Payments
  #total_payments = 0.0
  #@order.payments.each do |payment|
  #  totals << [
  #    make_cell(
  #      content: Spree.t(:payment_via,
  #      gateway: (payment.source_type || Spree.t(:unprocessed, scope: :print_invoice)),
  #      number: payment.number,
  #      date: I18n.l(payment.updated_at.to_date, format: :long),
  #      scope: :print_invoice)
  #    ),
  #    payment.display_amount.to_s
  #  ]
  #  total_payments += payment.amount
  #end

  table(totals, position: :right, column_widths: [100, 50]) do
    row(0..5).style align: :right, borders: [], padding: 0
    column(0).style borders: [], padding: 0
    row(-1).style align: :right, font_style: :bold
  end

  move_down 30
  text Spree::PrintInvoice::Config[:return_message], align: :right, size: @font_size
end

# FOOTER
if Spree::PrintInvoice::Config[:use_footer]
  repeat(:all) do
    grid([14,0], [14,9]).bounding_box do

      data  = []
      #data << [make_cell(content: Spree.t(:vat, scope: :print_invoice), colspan: 2, align: :center)]
      #data << [make_cell(content: '', colspan: 2)]
      data << [make_cell(content: Spree::PrintInvoice::Config[:footer_left],  align: :center),
      make_cell(content: Spree::PrintInvoice::Config[:footer_right], align: :center)]

      table(data, position: :center, column_widths: [207, 207]) do
        row(0..2).style borders: [], padding: 0
      end
    end
  end
end

# PAGE NUMBER
if Spree::PrintInvoice::Config[:use_page_numbers]
  string  = "#{Spree.t(:page, scope: :print_invoice)} <page> #{Spree.t(:of, scope: :print_invoice)} <total>"
  options = {
    at: [bounds.right - 155, 0],
    width: 150,
    align: :right,
    start_count_at: 1,
    color: '000000'
  }
  number_pages string, options
end
