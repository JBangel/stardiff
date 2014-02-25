require "stardiff/version"

module Stardiff
  class PakFile
    class Metadata
      METADATA_SIZE = 32
      BLOCK_FORMAT_SPECIFIER = 'SBBF02'

      attr_reader :datasource

      def initialize datasource
        @datasource = datasource
        @datastring = datasource.datastream.read METADATA_SIZE
      end

      def formatspecifier
        return @formatspecifier unless @formatspecifier.nil?
        bfsLength = BLOCK_FORMAT_SPECIFIER.size
        @formatspecifier ||= @datastring[0, bfsLength]
      end

      def valid?
        formatspecifier == BLOCK_FORMAT_SPECIFIER
      end
    end

    attr_reader :datastream

    def initialize buffer
      @datastream = buffer
      @metadata  = Metadata.new(self)
    end

    def valid?
      @metadata.valid?
    end
  end
end
