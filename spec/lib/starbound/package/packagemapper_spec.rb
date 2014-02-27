require 'starbound/package/packagemapper'
require 'starbound'

describe Starbound::PackageMapper do
  let(:loader) { double() }
  let(:files) { [{:name => 'tf1'}, {:name => 'tf2'}] }

  it 'provides a list of assets' do
    results = [Starbound::Asset.new(:name => 'tf1'),
               Starbound::Asset.new(:name => 'tf2')]

    expect(loader).to receive(:files).and_return files
    assets = Starbound::PackageMapper.new(loader).assets
    expect(assets).to eq results
  end
end
