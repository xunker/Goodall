require 'multi_json'
require "goodall/handler/base"

module Goodall
  module Handler
    class Json < Base
      Goodall::Logger.register_handler :json, self

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
  
        # remove prefix CR and return data
        MultiJson.dump(payload, :pretty => true).sub(/^\n/, '')
      
      end
    end
  end
end