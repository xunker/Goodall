require 'spec_helper'
require 'goodall'

describe Goodall do
  let(:klass) { Goodall }

  let(:mock_writer) { double(:writer, :close => nil) }

  let(:mock_handler) { double(:mock_handler) }

  before(:each) do
    Goodall.stub(:writer).and_return(mock_writer)
  end

  after(:each) do
    Goodall.disable
  end

  describe ".output_path" do
    it "must return the current output file path" do
       # default
      expect(klass.output_path).to eq('./api_docs.txt')

      # setting
      klass.output_path = 'foo/bar.txt'
      expect(klass.output_path).to eq('foo/bar.txt')
    end
  end

  describe ".enabled" do
    it "must be true if goodall is enabled" do
      klass.enable

      expect(klass.enabled).to be_true
    end
    it "must be false if goodall is not enabled" do
      klass.disable

      expect(klass.enabled).to be_false
    end
  end

  describe ".write" do
    context "Goodall is enabled" do
      before(:each) { klass.enable; }
      it "must deleage to the writer" do
        expect(mock_writer).to receive(:write).with('string')
      
        Goodall.write('string')
      end
    end

    context "Goodall is not enabled" do
      before(:each) { klass.disable }
      it "must silently return and not touch the writer" do
        expect(mock_writer).not_to receive(:write)

        Goodall.write('string')
      end
    end
  end

  describe ".document_request" do
    context "Goodall is enabled" do

      context "post with payload" do

        let(:mock_payload) { '{ "foo" : "bar" }' }

        let(:formatted_payload) do
          "{\n  \"foo\" : \"bar\"\n}\n"
        end

        before(:each) do
          klass.enable

          mock_handler
            .stub(:parse_payload)
            .with(mock_payload)
            .and_return(formatted_payload)

          klass.stub(:current_handler).and_return(mock_handler)
          klass.stub(:writer).and_return(mock_writer)
        end

        let(:expected_write) do
          "POST: /foo/bar\n#{formatted_payload}\n"
        end

        it "must send a formatted response to the writer" do
          expect(mock_writer).to receive(:write).with(expected_write)

          klass.document_request(:post, '/foo/bar', mock_payload)
        end
      end

      context "get without payload" do
        before(:each) do
          klass.enable
        end

        let(:expected_write) do
          "GET: /foo/bar\n"
        end

        it "must send a formatted request to the writer" do
          expect(mock_writer).to receive(:write).with(expected_write)

          klass.document_request(:get, '/foo/bar')
        end
      end

    end

    context "Goodall is not enabled" do
      before(:each) { klass.disable }
      it "must silently return without writing" do
        mock_writer.should_not_receive(:write)

        klass.document_request(:foo, 'bar', { :baz => :baz })
      end
    end
  end

  describe ".document_response" do
    context "Goodall is enabled" do

      let(:mock_payload) { '{ "foo" : "bar" }' }

      let(:formatted_payload) do
        "{\n  \"foo\" : \"bar\"\n}\n"
      end

      before(:each) do
        klass.enable

        mock_handler
          .stub(:parse_payload)
          .with(mock_payload)
          .and_return(formatted_payload)

        klass.stub(:current_handler).and_return(mock_handler)
        klass.stub(:writer).and_return(mock_writer)
      end

      let(:expected_write) do
        "RESPONSE:\n#{formatted_payload}\n"
      end

      it "must send a formatted response to the writer" do
        expect(mock_writer).to receive(:write).with(expected_write)

        klass.document_response(mock_payload)
      end
    end

    context "Goodall is not enabled" do
      before(:each) { klass.disable }
      it "must silently return without writing" do
        mock_writer.should_not_receive(:write)

        klass.document_response({ :baz => :baz })
      end
    end
  end
end