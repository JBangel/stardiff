require "stardiff/version"

module Stardiff
  class PakFile
    class Metadata
      METADATA_SIZE = 32
      BLOCK_FORMAT_SPECIFIER = 'SBBF02'

      attr_reader :datasource

      def initialize datasource
        @datasource = datasource
        @datastring = datasource.datastream.read(METADATA_SIZE)
      end

      def formatspecifier
        return @formatspecifier if @formatspecifier
        bfsLength = BLOCK_FORMAT_SPECIFIER.size
        @formatspecifier ||= @datastring[0, bfsLength]
      end

      def headersize
        return @headersize if @headersize
        position = BLOCK_FORMAT_SPECIFIER.size
        @headersize ||= @datastring[position, 4].unpack('L').first
      end

      def blocksize
        return @blocksize if @blocksize
        position = BLOCK_FORMAT_SPECIFIER.size + 4
        @blocksize ||= @datastring[position, 4].unpack('L').first
      end

      def parse
        formatspecifier
        headersize
        blocksize
        self
      end

      def valid?
        (formatspecifier == BLOCK_FORMAT_SPECIFIER) &&
        (headersize > 0) &&
        (blocksize > 0)
      end
    end

    attr_reader :datastream, :metadata

    def initialize buffer
      @datastream = buffer
      @metadata  = Metadata.new(self).parse
    end

    def valid?
      @metadata.valid?
    end
  end
end
