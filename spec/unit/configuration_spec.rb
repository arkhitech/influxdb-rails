require "spec_helper"

RSpec.describe InfluxDB::Rails::Configuration do
  before do
    @configuration = InfluxDB::Rails::Configuration.new
  end

  describe "client configuration" do
    subject { InfluxDB::Rails.configuration.client }

    describe "#retries" do
      it "defaults to 0" do
        expect(subject.retries).to eq(0)
      end

      it "can be updated" do
        InfluxDB::Rails.configure do |config|
          config.client.retries = 5
        end
        expect(subject.retries).to eql(5)
        expect(subject.write_options.max_retries).to eql(5)
      end
    end

    describe "#open_timeout" do
      it "defaults to 5 seconds" do
        expect(subject.open_timeout).to eql(5.seconds)
      end

      it "can be updated" do
        InfluxDB::Rails.configure do |config|
          config.client.open_timeout = 5
        end
        expect(subject.open_timeout).to eql(5)
      end
    end

    describe "#write_timeout" do
      it "defaults to 5 seconds" do
        expect(subject.write_timeout).to eql(5.seconds)
      end

      it "can be updated" do
        InfluxDB::Rails.configure do |config|
          config.client.write_timeout = 5
        end
        expect(subject.write_timeout).to eql(5)
      end
    end

    describe "#read_timeout" do
      it "defaults to 60 seconds" do
        expect(subject.read_timeout).to eql(60.seconds)
      end

      it "can be updated" do
        InfluxDB::Rails.configure do |config|
          config.client.read_timeout = 5
        end
        expect(subject.read_timeout).to eql(5)
      end
    end

    describe "#max_retry_delay_ms" do
      it "defaults to 10 seconds in milliseconds" do
        expect(subject.max_retry_delay_ms).to eql(10_000)
      end

      it "can be updated" do
        InfluxDB::Rails.configure do |config|
          config.client.max_retry_delay_ms = 5
        end
        expect(subject.max_retry_delay_ms).to eql(5)
      end
    end

    describe "#precision" do
      it "defaults to milli seconds" do
        expect(subject.precision).to eql(::InfluxDB2::WritePrecision::MILLISECOND)
      end

      it "can be updated" do
        InfluxDB::Rails.configure do |config|
          config.client.precision = ::InfluxDB2::WritePrecision::NANOSECOND
        end
        expect(subject.precision).to eql(::InfluxDB2::WritePrecision::NANOSECOND)
      end
    end

    describe "#async" do
      it "set write_type to batching by default" do
        expect(subject.write_options.write_type).to eql(::InfluxDB2::WriteType::BATCHING)
      end

      it "can be updated" do
        InfluxDB::Rails.configure do |config|
          config.client.async = false
        end
        expect(subject.write_options.write_type).to eql(::InfluxDB2::WriteType::SYNCHRONOUS)
      end
    end
  end

  describe "#rails_app_name" do
    it "defaults to nil" do
      expect(InfluxDB::Rails.configuration.rails_app_name).to be(nil)
    end

    it "can be set to own name" do
      InfluxDB::Rails.configure do |config|
        config.rails_app_name = "my-app"
      end

      expect(InfluxDB::Rails.configuration.rails_app_name).to eq("my-app")
    end
  end

  describe "#tags_middleware" do
    let(:middleware) { InfluxDB::Rails.configuration.tags_middleware }
    let(:tags_example) { { a: 1, b: 2 } }

    it "by default returns unmodified tags" do
      expect(middleware.call(tags_example)).to eq tags_example
    end

    it "can be updated" do
      InfluxDB::Rails.configure do |config|
        config.tags_middleware = ->(tags) { tags.merge(c: 3) }
      end

      expect(middleware.call(tags_example)).to eq(tags_example.merge(c: 3))
    end
  end
end
