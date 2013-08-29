require "goodall/handler/base"

module Goodall
  module Handler
    class Xml < Base
      Goodall::Logger.register_handler :xml, self

      def parse_payload(payload)
        if payload.class == String
          # assue it's a string of xml
          return payload
        else
          begin
            return payload.to_xml
          rescue Exception => e
            puts "!!! Just tried to call to_xml on your response, but an error was returned. Your object may not support this."
            raise e
          end
        end
      end
    end
  end
end