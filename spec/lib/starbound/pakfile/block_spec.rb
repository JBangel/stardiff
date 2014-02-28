require 'starbound/pakfile/block'
require 'starbound/pakfile'
require 'stringio'

describe Starbound do
  it 'can search for keys' do
    buffer = StringIO.new
    buffer.write [1,3].pack('Cl')
    buffer.write "1"
    buffer.write [2345].pack('l')
    buffer.write "2"
    buffer.write [6789].pack('l')
    buffer.write "3"
    buffer.write [0123].pack('l')
    buffer.rewind
    b = Starbound::PakFile::Block.new buffer, 1
    expect(b.search_tree('2')).to eq 6789
    expect(b.search_tree('15')).to eq :KeyNotFound
  end
end