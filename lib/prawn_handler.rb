require 'prawn'

module ActionView
  class Template
    module Handlers
      class Prawn
        class << self
          def register
            Template.register_template_handler :prawn, self
          end
          alias_method :register!, :register

          def call(template)
            <<-PDF
              extend #{DocumentProxy}
              pdf.font_families.update(
                "ChronicleDisp" => {
                  :normal => "/var/www/asket-backend/app/assets/fonts/ChronicleDisp-Light.ttf",
                  :bold => "/var/www/asket-backend/app/assets/fonts/ChronicleDisp-Light.ttf",
                  :bold_italic => "/var/www/asket-backend/app/assets/fonts/ChronicleDisp-Light.ttf",
                  :italic => "/var/www/asket-backend/app/assets/fonts/ChronicleDisp-Light.ttf"
                },
                "FoundersGrotesk" => {
                  :normal => "/var/www/asket-backend/app/assets/fonts/FoundersGrotesk-Light.ttf",
                  :bold => "/var/www/asket-backend/app/assets/fonts/FoundersGrotesk-Medium.ttf",
                  :bold_italic => "/var/www/asket-backend/app/assets/fonts/FoundersGrotesk-Medium.ttf",
                  :italic => "/var/www/asket-backend/app/assets/fonts/FoundersGrotesk-Light.ttf"
                }
                )
              #{template.source}
              pdf.render
            PDF
          end
        end

        module DocumentProxy
          def pdf
            @pdf ||= ::Prawn::Document.new(:page_size => "A4", :page_layout => :portrait, :margin => [10, 50])
          end

          private

          def method_missing(method, *args, &block)
            pdf.respond_to?(method) ? pdf.send(method, *args, &block) : super
          end
        end
      end
    end
  end
end

ActionView::Template::Handlers::Prawn.register!
