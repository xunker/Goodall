require 'multi_json'
require "goodall/handler/base"

class Goodall
  module Handler
    class Json < Base
      Goodall.register_handler :json, self

      @@json_adapter ||= MultiJson.default_adapter      

      def self.pretty_print_supported?
        [
          :json_gem,
          :nsjsonserialization,
          :oj
        ].include?(@@json_adapter)
      end

      unless pretty_print_supported?
        Kernel.warn "[Warning] MultiJson is using a json gem that is not known to support pretty printing (#{@@json_adapter}). Your JSON output may not be nicely formatted."
      end
      
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