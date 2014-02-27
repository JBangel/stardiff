require 'starbound'

module Starbound
  class PackageMapper
    attr_reader :loader

    def initialize loader
      @loader = loader
    end

    def assets
      each_asset.to_a
    end

    def each_asset
      return to_enum(__callee__) unless block_given?
      loader.files.each do |file|
        asset = Asset.new(:name => file[:name])
        yield asset
      end
    end
  end
end
