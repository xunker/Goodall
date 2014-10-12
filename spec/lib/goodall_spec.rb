require 'spec_helper'
require 'goodall'

describe Goodall do
  let(:klass) { Goodall }

  let(:mock_writer) { double(:writer, :close => nil) }

  let(:mock_handler) { double(:mock_handler) }

  let(:mock_new_handler) { double(:mock_new_handler) }

  before(:each) do
    Goodall.stub(:writer).and_return(mock_writer)
  end

  after(:each) do
    Goodall.disable
    Goodall.skipping_off!
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

      expect(klass.enabled).to be_truthy
    end
    it "must be false if goodall is not enabled" do
      klass.disable

      expect(klass.enabled).to be_falsey
    end
  end

  describe ".skipping?" do
    it "must be true if goodall is in skipping mode" do
      klass.skipping_on!

      expect(klass.skipping?).to be_truthy
    end
    it "must be false if goodall is in not skipping mode" do
      klass.skipping_off!

      expect(klass.skipping?).to be_falsey
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

          expect(mock_handler).to receive(:parse_payload).
            with(mock_payload).
            and_return(formatted_payload)

          expect(klass).to receive(:current_handler).and_return(mock_handler)
          expect(klass).to receive(:writer).and_return(mock_writer)
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

        expect(mock_handler).to receive(:parse_payload).
          with(mock_payload).
          and_return(formatted_payload)

        expect(klass).to receive(:current_handler).and_return(mock_handler)
        expect(klass).to receive(:writer).and_return(mock_writer)
      end

      let(:expected_write) do
        "RESPONSE:\n#{formatted_payload}\n"
      end

      let(:expected_write_with_status) do
        "RESPONSE: ok\n#{formatted_payload}\n"
      end


      it "must send a formatted response to the writer" do
        expect(mock_writer).to receive(:write).with(expected_write)

        klass.document_response(mock_payload)
      end

      it "must optionally accept a status code argument" do
        expect(mock_writer).to receive(:write).with(expected_write_with_status)

        klass.document_response(mock_payload, :ok)
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

  describe ".register_handler" do
    it "should add a handler class to the list of registered handlers" do
      klass.register_handler(:foo_register_test, mock_new_handler)

      expect(klass.registered_handlers).to include([:foo_register_test, mock_new_handler])
    end
  end

  describe ".set_handler" do
    context "handler is registered" do
      it "should set that handler as the current active handler" do
        foo_handler_instance = double(:foo_handler_instance)
        foo_handler_class = double(:foo_handler_class, :new => foo_handler_instance)
        bar_handler_instance = double(:bar_handler_instance)
        bar_handler_class = double(:bar_handler_class, :new => bar_handler_instance)
        
        klass.register_handler(:foo, foo_handler_class)
        klass.register_handler(:bar, bar_handler_class)

        klass.set_handler(:foo)
        expect(klass.send(:current_handler)).to eq(foo_handler_instance)

        klass.set_handler(:bar)
        expect(klass.send(:current_handler)).to eq(bar_handler_instance)
      end
    end
    context "handler is not registered" do
      it "should raise HandlerNotRegisteredError" do
        expect{
          klass.set_handler(:invalid)
        }.to raise_error(Goodall::HandlerNotRegisteredError)
      end
    end
  end

  describe ".should_document?" do

    context "enabled is true" do
      before(:each) { klass.enable }

      context "skipping is false" do
        before(:each) { klass.skipping=false }

        it "should be true" do
          expect(klass.should_document?).to be_truthy
        end
      end

      context "skipping is true" do
        before(:each) { klass.skipping=true }

        it "should be false" do
          expect(klass.should_document?).to be_falsey
        end
      end

    end

    context "enabled is false" do
      before(:each) { klass.disable }

      it "should be false" do
        expect(klass.should_document?).to be_falsey
      end
    end

  end
end