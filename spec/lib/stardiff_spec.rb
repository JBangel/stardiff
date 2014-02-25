require 'spec_helper'
require 'stringio'

describe Stardiff do
  it 'should have a version number' do
    Stardiff::VERSION.should_not be_nil
  end

  context Stardiff::PakFile do
    context 'when checking blockfile validity' do
      let(:buffer) { StringIO.new }

      it 'verifies a correct pakfile blockfile format' do
        buffer.write "SBBF0200000"
        buffer.seek 0
        pakfile = Stardiff::PakFile.new buffer
        expect(pakfile.valid?).to be true
      end

      it 'fails an incorrect pakfile blockfile format' do
        buffer.write "SFBF0200000"
        buffer.seek 0
        pakfile = Stardiff::PakFile.new buffer
        expect(pakfile.valid?).to be false
      end
    end
  end
end
