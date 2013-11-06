require 'singleton'
require "goodall/version"
require "goodall/errors"
require "goodall/writer"

require 'goodall/rake_task' if defined?(Rails)

class Goodall
  include Singleton

  @@enabled = false                #:nodoc:
  @@skipping = false                #:nodoc:
  @@output_path = './api_docs.txt' #:nodoc:
  @@registered_handlers = {}       #:nodoc:
  
  # Get the current documentation output path
  def self.output_path
    @@output_path
  end

  # Set the current documentation output path
  def self.output_path=(val)
    @@output_path = val
  end

  # Is Goodall logging enabled?
  def self.enabled
    @@enabled
  end

  # alias unreliable on class methods, use this instead.
  def self.enabled?
    enabled
  end

  # Explicity set the enabled state, true or false
  def self.enabled=(val)
    @@enabled=!!val
  end

  # Enable Goodall, which is disabled by default.
  def self.enable
    self.enabled=true
  end

  # Enable Goodall, which is the default by default.
  def self.disable
    self.enabled = false
  end

  # Flag to denote that documenting temporarily disabled?
  def self.skipping?
    @@skipping
  end

  # Enable the temporarily disable documenting flag
  def self.skipping_on!
    self.skipping = true
  end

  # Disable the temporarily disable documenting flag
  def self.skipping_off!
    self.skipping = false
  end

  # set the skipping value explicity
  def self.skipping=(val)
    @@skipping=!!val
  end

  # write to the currently open output file
  def self.write(str)
    writer.write(str) if enabled?
  end

  # Document a request.
  #
  # * +:method+ - a symbol of the verb: :get, :post, :put, :delete, :patch
  # * +:path+   - a string of the path (URL/URI) of the request
  # * +:payload+ - the parameters sent, e.g. post body. Usually a hash.
  def self.document_request(method, path, payload=nil)
    return unless should_document?

    str = "#{method.to_s.upcase}: #{path}"

    if payload && payload.to_s.size > 0
      str << "\n" + current_handler.parse_payload(payload)
    end

    str << "\n"
  
    writer.write(str)
  end

  # Document a response.
  #
  # * +:payload - the data returned from the request, e.g. response.body. `payload` will be run through the current handler and be pretty-printed to the output file.
  def self.document_response(payload, status=nil)
    return unless should_document?

    if payload
      payload = current_handler.parse_payload(payload)
    end

    str = if status
      "RESPONSE: #{status}"
    else
      "RESPONSE:"
    end
    str << "\n#{payload}\n"

    writer.write(str)
  end

  at_exit do
    if enabled? && writer
      writer.close
    end
  end

  # When writing a custom hander, it must register itself with Goodall using
  # this method.
  #
  # * +:payload_type+ - The name of the kind of content that this handler will be processing, e.g. JSON, XML, HTML etc.
  # * +:handler_class+ - The class of the handler itself (not the class name).
  def self.register_handler(payload_type, handler_class)
    @@registered_handlers[payload_type.to_sym] = handler_class
  end

  # Set the currently active handler. By default, if only one handler is
  # registered then it will be made active by default. If you hanve multiple
  # handlers registered and wish to switch between them, use this.
  #
  # * +:handler_name+ - Handler name as a symbol, e.g. :json, :xml.
  def self.set_handler(handler_name)
    handler_name = handler_name.to_sym
    if handler_class = @@registered_handlers[handler_name]
      @current_handler = handler_class.new
    else
      raise HandlerNotRegisteredError, "No handler registered for for #{handler_name}"
    end
  end

  # returns an array of arrays of the currently registered handlers.
  #
  # [ [ :identifier, class ], [ :identifier, class ] ]
  def self.registered_handlers
    @@registered_handlers.map{|k,v| [k,v]}
  end

  # Is goodall enabled and are NOT in skipping mode?
  def self.should_document?
    enabled? && !skipping?
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
