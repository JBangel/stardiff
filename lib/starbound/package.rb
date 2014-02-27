module Starbound
  class Package
    attr_reader :loadstate,
                :datasource

    def initialize(args = {})
      @asset_list = args[:assets]
      @pakfile    = args[:pakfile]

      @datasource = @pakfile

      if @asset_list.nil?
        @loadstate = :ghost
      else
        @loadstate = :loaded
      end
    end

    def self.with_assets(asset_list)
      package = Package.new(:assets => asset_list)
    end

    def assets
      each_asset.to_a
    end

    def each_asset
      return to_enum(__callee__) unless block_given?

      load
      @asset_list.each { |a| yield a }
    end

    private

    def load
      return if @loadstate == :loaded
      @asset_list = @datasource.assets
      
      @loadstate = :loaded
    end
  end
end
