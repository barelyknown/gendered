require "gendered"

RSpec.configure do |config|
  config.after :each do
    Gendered.config.members.each do |name|
      Gendered.config[name] = nil
    end
  end

  config.include Module.new {
    SUCCESS_RESPONSE = {
      :count => 100,
      :gender => "male",
      :name => "Sean",
      :probability => 1.0
    }

    FAILURE_RESPONSE = {
      :error => "Some thang went wrong"
    }

    def fake_response(options = {})
      code = options[:code] || 200
      body = (code == 200 ? SUCCESS_RESPONSE : FAILURE_RESPONSE).merge(options[:body] || {})

      headers = {}
      usage = options[:usage] || {}

      Gendered::Guesser::USAGE_HEADERS.each do |header, key|
        headers[header] = usage.include?(key) ? usage[key] : header.object_id
      end

      # Must use "content-type" as that's what code checks :( But HTTP lib is case insensitive.
      if options.include?(:content_type)
        headers["content-type"] =  options[:content_type]
        response = double(:code => code, :body => body.to_s)
      else
        headers["content-type"] = "application/json; charset=utf-8"
        response = double(:code => code, :body => JSON.dump(body))
      end

      allow(response).to receive(:[]) { |name| headers[name] }

      response
    end
  }
end
