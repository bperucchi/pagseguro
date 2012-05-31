# encoding : utf-8

require "net/https"
require "uri"
require "time"
require "bigdecimal"
require "httparty"


module PagSeguro
  GATEWAY_URL = "https://ws.pagseguro.uol.com.br/v2/checkout"
  GATEWAY_PAYMENT_URL = "https://pagseguro.uol.com.br/v2/checkout/payment.html"
  GATEWAY_NOTIFICATION_URL = "https://ws.pagseguro.uol.com.br/v2/transactions/notifications"

  STATUS = {
    :pending => 'Aguardando pagamento',
    :verifying => 'Em análise',
    :paid => 'Paga',
    :available => 'Disponível',
    :dispute => 'Em disputa',
    :refunded => 'Devolvida',
    :canceled => 'Cancelada'
  }

  TRANSACTION_TYPE = {
    :payment => 'Pagamento',
    :transfer => 'Transferência',
    :adding_funds => 'Adição de fundos',
    :charging => 'Cobrança',
    :bonus => 'Bônus'
  }

  PAYMENT_METHOD = {
    :credit_card => 'Cartão de crédito',
    :invoice => 'Boleto',
    :online_debit => 'Débito online',
    :pagseguro => 'Saldo PagSeguro',
    :oi_paggo => 'Oi Paggo'
  }

  PAYMENT_METHOD_EXTRA_INFO = {
    :visa => 'Visa',
    :martercard => 'MasterCard',
    :american_express => 'American Express',
    :diners => 'Diners',
    :hipercard => 'Hipercard',
    :aura => 'Aura',
    :elo => 'Elo',
    :bradesco => 'Bradesco',
    :santander => 'Santander',
    :bradesco => 'Bradesco',
    :itau => 'Itaú',
    :unibanco => 'Unibanco',
    :banco_do_brasil => 'Banco do Brasil',
    :banco_real => 'Banco Real',
    :banrisul => 'Banrisul',
    :pagseguro => 'Saldo PagSeguro',
    :oi_paggo => 'Oi Paggo'
  }

  SHIPPING_TYPE = {
    :normal => 'Encomenda normal',
    :sedex => 'SEDEX',
    :unspecified => 'Não especificado'
  }

  class MissingEnvironmentError < StandardError; end
  class MissingConfigurationError < StandardError; end

  # Hold the config/pagseguro.yml contents
  @@config = nil

  class << self
    # The path to the configuration file
    def config_file
      Rails.root.join('config/pagseguro.yml')
    end

    # Check if configuration file exists.
    def config?
      File.exist?(config_file)
    end

    # Load configuration file.
    def config
      raise MissingConfigurationError, "file not found on #{config_file.inspect}" unless config?

      # load file if is not loaded yet
      @@config ||= YAML.load_file(config_file)

      # raise an exception if the environment hasn't been set
      # or if file is empty
      if @@config == false || !@@config[Rails.env]
        raise MissingEnvironmentError, ":#{Rails.env} environment not set on #{config_file.inspect}"
      end

      # retrieve the environment settings
      @@config[Rails.env]
    end

    # The gateway URL will point to a local URL is
    # app is running in developer mode
    def gateway_url
      if developer?
        PagSeguro.config['base'] + '/pagseguro_developer'
      else
        PagSeguro.config['gateway_url'] || GATEWAY_URL
      end
    end

    # The gateway URL will point to a local URL is
    # app is running in developer mode
    def gateway_payment_url
      if developer?
        PagSeguro.config['base'] + '/pagseguro_developer/payment'
      else
        PagSeguro.config['gateway_payment_url'] || GATEWAY_PAYMENT_URL
      end
    end

    # The gateway URL will point to a local URL is
    # app is running in developer mode
    def gateway_notification_url
      if developer?
        PagSeguro.config['base'] + '/pagseguro_developer/notification'
      else
        PagSeguro.config['gateway_notification_url'] || GATEWAY_NOTIFICATION_URL
      end
    end

    # Reader for the `developer` configuration
    def developer?
      config? && config["developer"] == true
    end

    def prepare(billing, items, options)
      xml = PagApi.prepare_xml(billing, items)
      PagApi.remote_rpc(xml, options)
    end

  end
end
require 'pag_seguro/pag_api'
require 'pag_seguro/engine'
require "pag_seguro/faker"
require "pag_seguro/rake"
require "pag_seguro/railtie"
require "pag_seguro/notification"
require "pag_seguro/order"
require "pag_seguro/action_controller"
require "pag_seguro/helper"
require "pag_seguro/utils"

