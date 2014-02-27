require "stardiff/version"

module Stardiff
  def self.asset_list_diff package1, package2
    removed = (package1.assets - package2.assets)
    added = (package2.assets - package1.assets)

    {:added => added, :removed => removed}
  end
end
