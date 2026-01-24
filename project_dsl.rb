# project.dsl.rb
def build_project
  Project.new("YIC-Platform") do
    commonFiles "icons.png"
    
    pakName "DiagonalPlatform" do
      pak "building.YIC-railstop-platform-1_Diagonal.pak"
      dat "a.dat", "b.dat"
      png "c.png", "d.png"
    end

    pakName "DiagonalPlatform2" do
      pak "building.YIC-railstop-platform-1_Diagonal.pak"
      dat "a.dat", "b.dat"
      png "c.png", "d.png"
    end
  end
end
