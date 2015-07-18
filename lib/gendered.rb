require "bigdecimal"

require "http"

require "gendered/version"
require "gendered/name"
require "gendered/name_list"
require "gendered/guesser"

module Gendered
  GenderedError = Class.new(StandardError)

  class Config < Struct.new(:apikey, :country_id, :language_id, :connection)
    def merge(other)
      hash = respond_to?(:to_h) ? to_h : Hash[each_pair.to_a]
      hash.merge!(other)
      hash.reject! { |k,v| v.nil? }
    end
  end

  def self.configure
    raise ArgumentError, "configuration block required" unless block_given?
    yield config
  end

  def self.config
    @config ||= Config.new
  end
end
