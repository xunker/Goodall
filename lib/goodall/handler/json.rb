require 'multi_json'
require "goodall/handler/base"

class Goodall
  module Handler
    class Json < Base
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
          pretty_print(json)
          # json
        end
      end
    

    private

      # We're doing this outselves because it's too unreliable detecting which parsers support pretty-print and whoch one don't. If this method is broken, at least it will be *consitently* broken.
      def pretty_print(json)
        return json if json.to_s.size < 1

        str = json.to_s.gsub("},", "},\n").gsub("],", "],\n").gsub("{[", "{\n[").gsub("}]", "}\n]").gsub("[{", "[\n{").gsub("]}", "]\n}").gsub("{\"", "{\n\"").gsub("\"}", "\"\n}").gsub("\",\"", "\",\n\"")

        if str.match(/[^\n]\}$/)
          str.gsub!(/\}$/, "\n}")
        end

        output = []

        indent_level = 0
        str.split("\n").each do |s|
          indent_level -= 1 if ["]", "}"].include?(s[0]) && indent_level > 0
          output << ("  "*indent_level) + s
          if ["{", "["].include?(s[-1])
            indent_level += 1 
            next
          end

          if ["{", "["].include?(s[0])
            indent_level += 1 
            next
          end
        end
        output.join("\n")
      end
    end
  end
end