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
      data.read(4).unpack('l>').first
    end
  end

  class PakFile
    def getBlock blockindex
      Block.new datasource.seek(blockindex), keysize
    end

    class Block
      include BinReader

      attr_reader :type

      def initialize datasource, keysize
        @datasource = datasource
        @startpos = datasource.tell
        @keysize = keysize

        @type = @datasource.read(2)
        @level = rUInt8 @datasource
        @keyscount = rInt32 @datasource
        @default = rInt32 @datasource
        @datapos = @datasource.tell

        puts ""
        puts "type:              #{@type}"
        puts "level:             #{@level}"
        puts "keyscount:         #{@keyscount}"
        puts "default:           #{@default}"
        puts "datapos:           #{@datapos}"


      end

      def search_tree key
        puts "Looking for:       #{key}"
        keys.fetch(key.to_s) { :KeyNotFound }
      end

      def keys
        return @keys unless @keys.nil?
        
        @datasource.seek @datapos

        @keys = {}
        # @keyscount.times do
        5.times do
          key = @datasource.read(@keysize)
          @keys[key.to_s] = rInt32 @datasource
          puts "Checking:         #{key} (#{@keys[key.to_s]})"
        end

        @keys
      end
    end
  end
end
