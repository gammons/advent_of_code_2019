require "byebug"

class Coordinate
  attr_accessor :x,:y

  def initialize(x,y)
    @x = x
    @y = y
  end

  def ==(other)
    return @x == other.x && @y == other.y
  end
end

class Map
  def initialize(data)
    @data = data.map {|d| d.split("") }
  end

  def has_asteroid_at?(coord)
    @data[coord.y][coord.x] == "#"
  end

  def asteroids
    ret = []
    @data.each_with_index do |row,y|
      row.each_with_index do |spot,x|
        ret.push(Coordinate.new(x,y))if spot == "#"
      end
    end
    ret
  end
end

class Processor
  def initialize(map)
    @map = map
  end

  def process
    coord_seeing_most = nil
    max_count = 0

    @map.asteroids.each do |c1|
      count = 0
      angles = @map.asteroids.reject {|a| a == c1}.map do |c2|
        Math.atan2((c2.y - c1.y), (c2.x - c1.x))
      end.uniq

      if angles.count > max_count
        coord_seeing_most = c1
        max_count = angles.count
      end
    end
    puts "best is (#{coord_seeing_most.x},#{coord_seeing_most.y}) with #{max_count} in sight"
  end
end

data = File.read("map.txt").split("\n")
map = Map.new(data)
p = Processor.new(map)
p.process
