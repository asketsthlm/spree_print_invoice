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
        params[:q] ||= {}
        params[:q][:completed_at_not_null] ||= '1' if Spree::Config[:show_only_complete_orders_by_default]
        @show_only_completed = params[:q][:completed_at_not_null] == '1'
        params[:q][:s] ||= @show_only_completed ? 'completed_at desc' : 'created_at desc'
        params[:q][:completed_at_not_null] = '' unless @show_only_completed

        # As date params are deleted if @show_only_completed, store
        # the original date so we can restore them into the params
        # after the search
        created_at_gt = params[:q][:created_at_gt]
        created_at_lt = params[:q][:created_at_lt]

        params[:q].delete(:inventory_units_shipment_id_null) if params[:q][:inventory_units_shipment_id_null] == "0"

        if params[:q][:created_at_gt].present?
          params[:q][:created_at_gt] = Time.zone.parse(params[:q][:created_at_gt]).beginning_of_day rescue ""
        end

        if params[:q][:created_at_lt].present?
          params[:q][:created_at_lt] = Time.zone.parse(params[:q][:created_at_lt]).end_of_day rescue ""
        end

        if @show_only_completed
          params[:q][:completed_at_gt] = params[:q].delete(:created_at_gt)
          params[:q][:completed_at_lt] = params[:q].delete(:created_at_lt)
        end

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
