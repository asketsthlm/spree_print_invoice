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
                },
                "chinese" => {
                  :normal => "/var/www/asket-backend/app/assets/fonts/chinese.ttf",
                  :bold => "/var/www/asket-backend/app/assets/fonts/chinese.ttf",
                  :bold_italic => "/var/www/asket-backend/app/assets/fonts/chinese.ttf",
                  :italic => "/var/www/asket-backend/app/assets/fonts/chinese.ttf"
                },
                "japanese" => {
                  :normal => "/var/www/asket-backend/app/assets/fonts/japanese.ttf",
                  :bold => "/var/www/asket-backend/app/assets/fonts/japanese.ttf",
                  :bold_italic => "/var/www/asket-backend/app/assets/fonts/japanese.ttf",
                  :italic => "/var/www/asket-backend/app/assets/fonts/japanese.ttf"
                },
                "OpenSans" => {
                  :normal => "/var/www/asket-backend/app/assets/fonts/OpenSans-Light.ttf",
                  :bold => "/var/www/asket-backend/app/assets/fonts/OpenSans-Semibold.ttf",
                  :bold_italic => "/var/www/asket-backend/app/assets/fonts/OpenSans-Semibold.ttf",
                  :italic => "/var/www/asket-backend/app/assets/fonts/OpenSans-Light.ttf"
                })
              #{template.source}
              pdf.render
            PDF
          end
        end

        module DocumentProxy
          def pdf
            @pdf ||= ::Prawn::Document.new(:page_size => "A4", :page_layout => :portrait, :margin => [15, 90])
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
