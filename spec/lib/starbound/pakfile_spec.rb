require 'starbound/pakfile'
require 'stringio'
require 'bindata'

class TestMetadata < BinData::Record
  endian :little

  string :bfs, :length => 6
  uint32 :headersize
  uint32 :blocksize
end

describe Starbound::PakFile do
  context 'when checking blockfile validity' do
    let(:pakfile) do
      buffer = StringIO.new
      @formatspec ||= "SBBF02"
      buffer.write "#{@formatspec}0000000000"
      buffer.seek 0
      pakfile = Starbound::PakFile.new buffer
    end

    it 'verifies a correct pakfile blockfile format' do
      expect(pakfile.valid?).to be true
    end

    it 'fails an incorrect pakfile blockfile format' do
      @formatspec = "SBBBBB"
      expect(pakfile.valid?).to be false
    end
  end

  context 'when checking data sizes' do
    before(:each) do
      mdrec = TestMetadata.new
      mdrec.bfs        = "SBBF02"
      mdrec.headersize = 27
      mdrec.blocksize  = 34
      buffer = StringIO.new
      buffer.write mdrec.to_binary_s
      buffer.seek 0
      @pakfile = Starbound::PakFile.new buffer
    end

    it 'pulls the correct header size' do
      expect(@pakfile.metadata.headersize).to eq 27
    end

    it 'pulls the correct header size' do
      expect(@pakfile.metadata.blocksize).to eq 34
    end
  end
end