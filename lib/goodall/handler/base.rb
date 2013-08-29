module Goodall
  module Handler
    class Base
      def parse_payload(payload_string)
        raise NotImplementedError
      end
    end
  end
end