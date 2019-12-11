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

  # loop through each asteroid
  #   draw line to each other asteroid in map
  #   determine if there's a clear LOS to that asteroid
  #   if so, add that to the count
  def process
    coord_seeing_most = nil
    max_count = 0

    @map.asteroids.each do |c1|
      count = 0
      @map.asteroids.reject {|a| a == c1}.each do |c2|
        count += 1 if can_see?(c1,c2)
      end

      if count > max_count
        coord_seeing_most = c1
        max_count = count
      end
    end
    puts max_count
  end

  def can_see?(c1, c2)
    slope = (c2.y - c1.y) / (c2.x - c1.x).to_f
    even = slope.infinite? || slope - slope.floor == 0
    bresenham(c1.x, c2.x, c1.y, c2.y).each do |coord|
      return false if coord != c1 && coord != c2 && even && @map.has_asteroid_at?(coord)
    end
    true
  end

  private

  def bresenham(x0,x1,y0,y1)
    points = []
    steep = ((y1-y0).abs) > ((x1-x0).abs)

    if steep
      x0,y0 = y0,x0
      x1,y1 = y1,x1
    end

    if x0 > x1
      x0,x1 = x1,x0
      y0,y1 = y1,y0
    end

    deltax = x1-x0
    deltay = (y1-y0).abs
    error = (deltax / 2).to_i
    y = y0
    ystep = nil

    if y0 < y1
      ystep = 1
    else
      ystep = -1
    end

    for x in x0..x1
      if steep
        points << Coordinate.new(y,x)
      else
        points << Coordinate.new(x,y)
      end
      error -= deltay
      if error < 0
        y += ystep
        error += deltax
      end
    end

    points
  end
end

data = File.read("map.txt").split("\n")
map = Map.new(data)
p = Processor.new(map)
p.process
