module Starbound
  module BTreeDB
    module BTreeIoIndex
    end
  end

  module BinReader
    def rUInt8 data
      data.read(1).unpack('C').first
    end

    def rInt32 data
      data.read(4).unpack('l').first
    end
  end

  class PakFile
    def getBlock blockindex
      Block.new datasource.seek(blockindex), keysize
    end

    class Block
      include BinReader

      def initialize datasource, keysize
        @datasource = datasource
        @startpos = datasource.tell
        @keysize = keysize
        @level = rUInt8 @datasource
        @keyscount = rInt32 @datasource
        @datapos = @datasource.tell
      end

      def search_tree key
        keys.fetch(key.to_s) { :KeyNotFound }
      end

      def keys
        return @keys unless @keys.nil?
        
        @datasource.seek @datapos

        @keys = {}
        @keyscount.times do
          key = @datasource.read(@keysize)
          @keys[key.to_s] = rInt32 @datasource
        end

        @keys
      end
    end
  end
end
