require 'singleton'
require "goodall/version"
require "goodall/errors"
require "goodall/writer"

module Goodall
  class Logger
    include Singleton

    @@enabled = false
    @@output_path = './api_docs.txt'
    @@registered_handlers = {}
    
    def self.output_path
      @@output_path
    end

    def self.output_path=(val)
      @@output_path = val
    end

    def self.enabled
      @@enabled
    end

    # alias unreliable on class methods, use this instead.
    def self.enabled?
      enabled
    end

    def self.enabled=(val)
      @@enabled=!!val
    end

    def self.enable
      self.enabled=true
    end

    def self.disable
      self.enabled = false
    end

    def self.write(str)
      writer.write(str) if enabled?
    end

    def self.document_request(method, path, payload)
      return unless enabled?

      if payload
        payload = current_handler.parse_payload(payload)
      end

      str = "#{method.to_s.upcase}: #{path}\n"
    
      str << payload if payload

      writer.write(str)
    end

    def self.document_response(payload)
      return unless enabled?

      if payload
        payload = current_handler.parse_payload(payload)
      end

      str = "RESPONSE:\n#{payload}"

      writer.output(str)
    end

    at_exit do
      if enabled? && writer
        writer.close
      end
    end

    def self.register_handler(payload_type, handler_class)
      @@registered_handlers[payload_type.to_sym] = handler_class
    end

    def self.set_handler(handler_name)
      handler_name = handler_name.to_sym
      if handler_class = @@registered_handlers[handler_name]
        @current_handler = handler_class.new
      else
        raise HandlerNotRegisteredError, "No handler registered for for #{handler_name}"
      end
    end

  private

    def self.current_handler
      @current_handler ||= if default_handler = @@registered_handlers.first
        default_handler[1].new
      else
        raise(
          Goodall::NoHandlersRegisteredError,
          "There are no handlers registered, please require at least one."
        )
      end
    end
    
    def self.writer
      @writer ||= Goodall::Writer.new(@@output_path)
    end

  end
end