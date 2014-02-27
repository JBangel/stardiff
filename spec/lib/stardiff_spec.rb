require 'spec_helper'
require 'starbound/package'

describe Stardiff do
  it 'should have a version number' do
    expect(Stardiff::VERSION).to_not be_nil
  end

  it 'should identify the differences between two different asset lists' do
    asset_list_1 = Starbound::Package.with_assets([
        Starbound::Asset.new(:name => "Teleporter"),
        Starbound::Asset.new(:name => "Crafting Table"),
        Starbound::Asset.new(:name => "Diamond Block")
    ])

    asset_list_2 = Starbound::Package.with_assets([
        Starbound::Asset.new(:name => "Chicken"),
        Starbound::Asset.new(:name => "Crafting Table"),
        Starbound::Asset.new(:name => "Diamond Block")
    ])

    complete_diff = Stardiff::asset_list_diff(asset_list_1, asset_list_2)
    added_list = complete_diff[:added].map(&:name)
    removed_list = complete_diff[:removed].map(&:name)

    expect(added_list).to eq ["Chicken"]
    expect(removed_list).to eq ["Teleporter"]
  end
end
