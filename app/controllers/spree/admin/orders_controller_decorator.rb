module Spree
  module Admin
    OrdersController.class_eval do
      require 'zip'

      respond_to :pdf, only: :show

      def show
        load_order

        respond_with(@order) do |format|
          format.pdf do
            @order.update_invoice_number!

            send_data @order.pdf_file(pdf_template_name),
              type: 'application/pdf', disposition: 'inline'
          end
        end
      end

      def batch_invoices

        @search = Order.accessible_by(current_ability, :index).ransack(params[:q])
        ordersToExport = @search.result(distinct: true)
        t = Tempfile.new("invoices-#{Time.now}")
        Zip::OutputStream.open(t.path) do |stream|
          ordersToExport.each do |order|
            puts order.number
            # rename the pdf
            stream.put_next_entry("#{order.number}.pdf")
            # add pdf to zip
            stream.write order.pdf_file('invoice')
          end
        end
        send_file t.path, :type => 'application/zip',
                          :disposition => 'attachment',
                          :filename => "invoices-#{Time.now}.zip"

                  t.close

      end

      private

      def pdf_template_name
        pdf_template_name = params[:template] || 'invoice'
        if !Spree::PrintInvoice::Config.print_templates.include?(pdf_template_name)
          raise Spree::PrintInvoice::UnsupportedTemplateError.new(pdf_template_name)
        end
        pdf_template_name
      end
    end
  end
end
