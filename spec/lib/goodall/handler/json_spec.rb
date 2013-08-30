require 'spec_helper'
require 'goodall'
require 'goodall/handler/json'

describe Goodall::Handler::Json do
  describe '#parse_payload' do
    context 'payload is a string' do
      context 'string is valid json' do

        let(:valid_json_string) { '{"foo":"bar"}' }

        let(:formatted_output) do
          if Goodall::Handler::Json.pretty_print_supported?
            "{\n  \"foo\": \"bar\"\n}"
          else
            "{\"foo\":\"bar\"}"
          end
        end

        it 'should return it as pretty-printed json' do
          expect(
            subject.parse_payload(valid_json_string)
          ).to eq(formatted_output)
        end        
      end
      context 'the string not valid json' do

        let(:invalid_json_string) { 'BLAHBLAH' }

        it 'should return the string with CR added' do
          expect(
            subject.parse_payload(invalid_json_string)
          ).to eq("#{invalid_json_string}\n")
        end
      end
    end

    context 'payload is not a string' do

      let(:payload) { { :foo => :bar } }

      let(:formatted_output) do
        if Goodall::Handler::Json.pretty_print_supported?
          "{\n  \"foo\": \"bar\"\n}"
        else
          "{\"foo\":\"bar\"}"
        end
      end

      it 'should return it as pretty-printed json' do
        expect(
            subject.parse_payload(payload)
          ).to eq(formatted_output)
      end
    end
  end
end
