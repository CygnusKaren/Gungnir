# project.dsl.rb
def build_project
  Project.new("YIC-Platform") do
    commonFiles "icons.png"
    
    pakName "YIC-railstop-platform-1_Diagonal(Side)" do
      pak "building.YIC-railstop-platform-1_Diagonal.pak"
      dat "YIC_platform-1_Diagonal-Side.dat"
      png "YIC_platform-1_Diagonal-Side.png", "platform-1.png"
    end

    pakName "YIC-railstop-platform-1_Diagonal(Side-D)" do
      pak "building.YIC-railstop-platform-1_Diagonal(Side-D).pak"
      dat "YIC_platform-1_Diagonal-Side_D.dat"
      png "YIC_platform-1_Diagonal-Side.png", "platform-1.png"
    end
    pakName "YIC-railstop-platform-1_Diagonal(Angle)" do
      pak "building.YIC-railstop-platform-1_Diagonal(Angle).pak"
      dat "YIC_platform-1_Diagonal-Angle.dat"
      png "YIC_platform-1_Diagonal-Angle.png", "platform-1.png"
    end

    pakName "YIC-railstop-platform-1_Diagonal(Angle-D)" do
      pak "building.YIC-railstop-platform-1_Diagonal\(Angle-D\).pak"
      dat "YIC_platform-1_Diagonal-Angle_D.dat"
      png "YIC_platform-1_Diagonal-Angle.png", "platform-1.png"
  end

    pakName "YIC-railstop-platform-1_Diagonal(Angle-Cross_L-RB)" do
      pak "building.YIC-railstop-platform-1_Diagonal\(Angle-Cross_L-RB\).pak"
      dat "YIC_platform-1_Diagonal-Angle_Cross_L-RB.dat"
      png "YIC_platform-1_Diagonal-Angle_Cross.png", "platform-1u.png"
    end

    pakName "YIC-railstop-platform-1_Diagonal(Side-Fence)" do
      pak "building.YIC-railstop-platform-1_Diagonal\(Side-Fence\).pak"
      dat "YIC_platform-1_Diagonal-SideFence.dat"
      png " YIC_platform-1_Diagonal-SideFence.png","platform-1s.png"
    end

    pakName "YIC-railstop-platform-1_Diagonal(Side-Fence).pak" do
      dat "YIC_platform-1_Diagonal-SideFence.dat"
      png "YIC_platform-1_Diagonal-SideFence.png", "platform-1s.png"
      pak "building.YIC-railstop-platform-1_Diagonal\(Side-Fence\).pak"
  end
    
    pakName "building.YIC-railstop-platform-1_Diagonal(Side-Fence-D)" do
      dat "YIC_platform-1_Diagonal-SideFence-D.dat"
      png "YIC_platform-1_Diagonal-SideFence.png", "platform-1s.png"
      pak "building.YIC-railstop-platform-1_Diagonal\(Side-Fence-D\).pak"
    end
  end
end
