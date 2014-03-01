require 'starbound/pakfile/block'
require 'starbound/pakfile'
require 'stringio'

describe Starbound do
  def addBlockKey buffer, key, blockid
    buffer.write key
    buffer.write [blockid].pack('l')
  end

  it 'can search for keys' do
    buffer = StringIO.new
    buffer.write [1,3].pack('Cl')

    [[Digest::SHA256.hexdigest('1'), 2345],
     [Digest::SHA256.hexdigest('2'), 6789],
     [Digest::SHA256.hexdigest('3'), 0123],
     [Digest::SHA256.hexdigest('4'), 4556]].each do |key, value|
      addBlockKey buffer, key, value
    end

    buffer.rewind
    b = Starbound::PakFile::Block.new buffer, 64
    expect(b.search_tree(Digest::SHA256.hexdigest('2'))).to eq 6789
    expect(b.search_tree(Digest::SHA256.hexdigest('3'))).to eq 0123
    expect(b.search_tree(Digest::SHA256.hexdigest('15'))).to eq :KeyNotFound
  end
end
