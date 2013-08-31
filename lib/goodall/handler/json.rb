require 'multi_json'
require "goodall/handler/base"
require 'tolerate_json'

class Goodall
  module Handler
    class Json < Base
      include TolerateJson
      Goodall.register_handler :json, self

      def parse_payload(payload)
        payload = if payload.class == String
          # assue it's a string of json
          begin
            MultiJson.load(payload)
          rescue MultiJson::LoadError
            # probably not JSON, return as-is
            return payload+"\n"
          end
        else
          payload
        end

        # detect "pretty" json by seeing if there are CRs in here
        if (json = MultiJson.dump(payload)) =~ /\n/
          json
        else
          pretty_print_json(json)
          # json
        end
      end
    end
  end
end