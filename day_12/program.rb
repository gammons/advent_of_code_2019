require "byebug"

class Moon
  attr_accessor :x,:y,:z,:vx,:vy,:vz
  attr_reader :name

  def initialize(name, x,y,z)
    @name = name
    @x = x
    @y = y
    @z = z
    @vx = 0
    @vy = 0
    @vz = 0
  end

  def potential
    @x.abs + @y.abs + @z.abs
  end

  def kinetic
    @vx.abs + @vy.abs + @vz.abs
  end

  def to_s
    "pos=<x=#{@x}, y=#{@y}, z=#{@z}, vel=<x=#{@vx}, y=#{@vy}, z=#{@vz}>"
  end
end

class System
  def initialize
    @moons = []
    @moons.push Moon.new("Io",-8, -18, 6)
    @moons.push Moon.new("Europa",-11, -14, 4)
    @moons.push Moon.new("Ganymede", 8, -3, -10)
    @moons.push Moon.new("Callisto",-2, -16, 1)
  end

  def run
    1000.times do |n|
      apply_gravity
      apply_velocity
    end
    puts "Total energy: #{total_energy}"
  end

  def total_energy
    @moons.inject(0) {|sum, m| sum + (m.potential * m.kinetic) }
  end

  def apply_gravity
    @moons.each do |m1|
      @moons.each do |m2|
        next if m1 == m2
        if m1.x != m2.x
          m1.vx += (m1.x < m2.x) ? 1 : -1
        end

        if m1.y != m2.y
          m1.vy += (m1.y < m2.y) ? 1 : -1
        end

        if m1.z != m2.z
          m1.vz += (m1.z < m2.z) ? 1 : -1
        end
      end
    end
  end

  def apply_velocity
    @moons.each do |moon|
      moon.x += moon.vx
      moon.y += moon.vy
      moon.z += moon.vz
    end
  end

  private

  def debug(n)
    puts "After #{n} steps:"
    @moons.each {|moon| p moon }
  end
end

s = System.new
s.run
