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

  def distance(other)
    (@x - other.x).abs + (@y - other.y).abs
  end

  def to_s
    "(#{@x},#{@y})"
  end
end

class Map
  attr_reader :data

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
    home = Coordinate.new(19,14)

    h = {}
    angles = @map.asteroids.reject {|a| a == home}.each do |c2|
      angle = Math.atan2((c2.y - home.y), (c2.x - home.x)) * (180 / Math::PI)
      h[angle] ||= []
      h[angle].push(c2)
    end

    h.each do |key, coords|
      coords.sort! {|c1, c2| c1.distance(home) <=> c2.distance(home) }
    end

    # get the keys in correct order, starting with -90.0 (pointing up)
    keys = h.keys.sort
    idx = keys.index(-90.0)
    k1 = keys.shift(idx)
    (keys + k1).each_with_index do |key, idx|
      to_kill = h[key].shift

      if idx == 199
        puts "200th kill is asteroid at #{to_kill.to_s}"
      end
    end
  end
end

data = File.read("map.txt").split("\n")
map = Map.new(data)
p = Processor.new(map)
p.process
