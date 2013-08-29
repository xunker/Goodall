require 'multi_json'
require "goodall/handler/base"

module Goodall
  module Handler
    class Json < Base
      Goodall::Logger.register_handler :json, self

      def parse_payload(payload)
        payload = if payload.class == String
          # assue it's a string of json
          MultiJson.load(payload)
        else
          payload
        end
  
        MultiJson.dump(payload, :pretty => true)
      
      end
    end
  end
end