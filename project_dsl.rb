# project.dsl.rb
def build_project
  Project.new("SampleProject") do
    commonFiles "SampleIcons.png"
    
    pakName "SampleAddon" do
      pak "building.SampleAddon.pak"
      dat "SampleAddon.dat"
      png "SampleAddon.png", "Sample2.png"
    end
end
