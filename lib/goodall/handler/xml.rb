require "goodall/handler/base"

# This sucks.
# It needs love from someone who knows xml. That's not me.

class Goodall
  module Handler
    class Xml < Base
      Goodall.register_handler :xml, self

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