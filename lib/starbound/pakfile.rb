require 'digest'

require 'starbound/pakfile/block'

BTreeDB = Struct.new(:datastream)

module Starbound
  module BinReader
    def rBoolean data
      !!(data.read(1).unpack('C').first)
    end
  end

  class PakFile
    class Metadata
      include BinReader

      METADATA_SIZE = 100
      BLOCK_FORMAT_SPECIFIER = 'SBBF02'
      FMAP = {
        formatspecifier: [0,   6],
        headersize:      [6,   4],
        blocksize:       [10,  4],
        format:          [32, 12],
        identifier:      [44, 12],
        keySize:         [56,  4],
        alternateRoot:   [60,  1],
        rootNode:        [-1,  4]
      }

      attr_reader :datasource

      def initialize datasource
        @datasource = datasource
        @datastring = datasource.datastream.read(METADATA_SIZE)
      end

      def formatspecifier
        return @formatspecifier if @formatspecifier
        position, length = FMAP.fetch(:formatspecifier) { :badFormatSpecifier }
        @formatspecifier ||= @datastring[position, length]
      end

      def headersize
        return @headersize if @headersize
        position, length = FMAP.fetch(:headersize) { :badHeadersize }
        @headersize ||= @datastring[position, length].unpack('l>').first
      end

      def blocksize
        return @blocksize if @blocksize
        position, length = FMAP.fetch(:blocksize) { :badBlocksize }
        @blocksize ||= @datastring[position, length].unpack('l>').first
      end

      def alternateRoot?
        return @alternateRoot if @alternateRoot
        position, length = FMAP.fetch(:alternateRoot) { :badAlternateRoot }
        @alternateRoot ||= !!(@datastring[position, length].unpack('C').first)
      end

      def rootNodeIndexPos
        arpos, _ = FMAP.fetch(:alternateRoot) { :badAlternateRoot }
        seekpos = arpos + (alternateRoot? ? 9 : 1)
      end

      def rootNodeIndex
        return @rootNodeIndex unless @rootNodeIndex.nil?
        seekpos = rootNodeIndexPos
        _, length = FMAP.fetch(:rootNode) { :badRootNode }
        @rootNodeIndex ||= @datastring[seekpos, length].unpack('l').first
      end

      def format
        return @format if @format
        position, length = FMAP.fetch(:format) { :badFormat }
        @format ||= @datastring[position, length]
      end

      def identifier
        return @identifier if @identifier
        position, length = FMAP.fetch(:identifier) { :badIdentifier }
        @identifier ||= @datastring[position, length]
      end

      def keysize
        return @keysize if @keysize
        position, length = FMAP.fetch(:keySize) { :badKeysize }
        @keysize ||= @datastring[position, length].unpack('l>').first
      end

      def rootIsLeaf?
        return @rootIsLeaf unless @rootIsLeaf.nil?
        seekpos = rootNodeIndexPos + 4
        @rootIsLeaf ||= !!(@datastring[seekpos, 1].unpack('C'))
      end

      def parse
        puts "formatspecifier:   #{formatspecifier}"
        puts "headersize:        #{headersize}"
        puts "blocksize:         #{blocksize}"
        puts "format:            #{format}"
        puts "identifier:        #{identifier}"
        puts "keysize:           #{keysize}"
        puts "alternateRoot?:    #{alternateRoot?}"
        puts "rootNodeIndex:     #{rootNodeIndex}"
        puts "rootIsLeaf?:       #{rootIsLeaf?}"
        self
      end

      def valid?
        (formatspecifier == BLOCK_FORMAT_SPECIFIER) &&
        (headersize > 0) &&
        (blocksize > 0)
      end

      def index_key
        Digest::SHA256.new.hexdigest '_index'
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

    def header
      return @header unless @header.nil?
      @header = @datastream.read(metadata.headersize)
    end

    attr_reader :filename

    def files
      hashkey = metadata.index_key

      root.search_tree(hashkey)
    end

    def root
      return @root unless @root.nil?
      root_pos = metadata.headersize + (metadata.blocksize * metadata.rootNodeIndex)
      puts "root_pos:          #{root_pos}"
      datastream.seek(root_pos)
      @root ||= Block.new(datastream, metadata.keysize)
    end
  end
end