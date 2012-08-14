require "nokogiri"
require 'httparty'

module PagSeguro
  class PagApi
    class << self

      def prepare_xml(billing, items)
        builder = Nokogiri::XML::Builder.new(:encoding => 'ISO-8859-1') do |xml|
          xml.checkout {
            xml.items
            xml.redirectURL { xml.text billing[:redirectURL]}
            xml.currency  { xml.text billing[:currency] }
            xml.reference { xml.text billing[:id] }
            xml.sender {
              xml.name { xml.text billing[:name] }
              xml.email { xml.text billing[:email] }
            }
            xml.shipping{
              xml.type_ billing[:shippingId]
              xml.address{
                xml.street { xml.text billing[:street] }
                xml.complement { xml.text billing[:complement] }
                xml.postalCode { xml.text billing[:zip_code] }
                xml.city { xml.text billing[:city] }
                xml.state { xml.text billing[:state] }
                xml.country { xml.text billing[:country] }
              }
            }
          }
        end
        items.each do |item|
          node =  builder.doc.xpath('//checkout/items').first
          Nokogiri::XML::Builder.with(node) do |xml|
            xml.item {
              xml.id { xml.text item[:id] }
              xml.description { xml.text item[:description] }
              xml.amount { xml.text item[:amount] }
              xml.quantity { xml.text item[:quantity] }
              xml.shippingCost { xml.text item[:shippingCost] }
            }
          end
        end
        builder.to_xml
      end

      def remote_rpc(xml = nil, options)
        include HTTParty
        base_uri 'https://ws.pagseguro.uol.com.br/v2'
        response = post("/checkout?email=#{options['client_id']}&token=#{options['token']}", :body => xml, :headers => {'Content-type' => 'application/xml; charset=ISO-8859-1'})
      end
    end
  end
end
