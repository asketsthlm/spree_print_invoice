Deface::Override.new(
  :virtual_path => 'spree/admin/orders/index',
  :name => 'batch_export_invoice_button',
  :insert_after => "erb[loud]:contains(':simple => true')",
  :text => "
    <div class='form-group pull-right'>
    <%= button_link_to 'Invoices',{ controller: 'orders', action: 'batch_invoices', params: request.query_parameters },method: :post,  :class => 'btn-success' %>
    </div>
  "
)
