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
      body = (code == 200 ? SUCCESS_RESPONSE : ERROR_RESPONSE).merge(options[:body] || {})
      double(:code => code, :body => JSON.dump(body))
    end
  }
end
