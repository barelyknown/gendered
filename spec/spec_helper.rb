require "gendered"

RSpec.configure do |config|
  config.after :each do
    Gendered.config.members.each do |name|
      Gendered.config[name] = nil
    end
  end
end
