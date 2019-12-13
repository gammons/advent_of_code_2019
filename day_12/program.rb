require "byebug"

class Moon
  attr_accessor :x,:y,:z,:vx,:vy,:vz
  attr_reader :name

  def initialize(name, x,y,z)
    @name = name
    @initial_x = x
    @initial_y = y
    @initial_z = z
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

  def at_initial_position?(coord)
    case coord
    when :x
      return @x == @initial_x
    when :y
      return @y == @initial_y
    when :z
      return @z == @initial_z
    end
  end

  def to_s
    "pos=<x=#{@x}, y=#{@y}, z=#{@z}, vel=<x=#{@vx}, y=#{@vy}, z=#{@vz}>"
  end
end

class System
  def initialize
    @moons = []
    # @moons.push Moon.new("Io",-8, -18, 6)
    # @moons.push Moon.new("Europa",-11, -14, 4)
    # @moons.push Moon.new("Ganymede", 8, -3, -10)
    # @moons.push Moon.new("Callisto",-2, -16, 1)

    @moons.push Moon.new("Io",-8, -10, 0)
    @moons.push Moon.new("Europa",5, 5, 10)
    @moons.push Moon.new("Ganymede", 2, -7, 3)
    @moons.push Moon.new("Callisto",9,-8,-3)
  end

  def run
    lcms = []
    @moons.each do |moon|
      x_count, y_count, z_count = nil, nil, nil
      count = 0

      loop do
        count += 1
        apply_gravity
        apply_velocity

        x_count = count if moon.at_initial_position?(:x) && moon.vx == 0 && count != 0 && x_count.nil?
        y_count = count if moon.at_initial_position?(:y) && moon.vy == 0 && count != 0 && y_count.nil?
        z_count = count if moon.at_initial_position?(:z) && moon.vz == 0 && count != 0 && z_count.nil?

        break if x_count && y_count && z_count
      end

      lcms.push [x_count,y_count,z_count].reduce(:lcm)

      puts "\nfor moon #{moon.name}"
      puts "x_count = #{x_count}"
      puts "y_count = #{y_count}"
      puts "z_count = #{z_count}"
      puts "lcm: #{lcms.last}"
    end

    puts "Total total: #{lcms.reduce(:lcm)}"
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
end

s = System.new
s.run
