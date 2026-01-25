# project.dsl.rb
module Gungnir_DSL
  def self.build_project
    Project.new("SampleProject") do
      commonFiles "SampleIcons.png"
      exportPath "./pak/"
      #single addon making case
      pakName "SampleAddon" do
        pak "building.SampleAddon.pak"
        dat "SampleAddon.dat"
        png "SampleAddon.png", "Sample2.png"
      end

      # multiple addon making case
      pos = ["FB", "FR", "LB", "LR", "RB", "FL"]

      pakEach pos, prefix:"Angle-Fence" do | pos | # 派生系はprefix + posを付与して管理
        pak "building.SampleAddon(#{pos}).pak"
        dat "SampleAddon_#{pos}.dat"
        png "SampleAddon#{pos}.png", "Sample2.png"
      end
    end
  end
end
