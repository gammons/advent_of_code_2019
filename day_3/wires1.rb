require "byebug"

lines = File.read("input.txt").split("\n")

wire1 = lines[0].split(",")
wire2 = lines[1].split(",")

wire_grid1 = Array.new(10000) { Array.new(10000) }
wire_grid2 = Array.new(10000) { Array.new(10000) }

class Location
  attr_accessor :x,:y

  def initialize(x,y)
    @x = x
    @y = y
  end

  def to_s
    "(#{@x},#{@y})"
  end
end

def get_wire_locations(wire, wire_grid)
  current = Location.new(0,0)

  wire_locations = []
  wire.each do |instruction|
    chars = instruction.chars
    direction = chars.shift
    moves = chars.join.to_i

    case direction
    when "R"
      (current.x..(current.x + moves)).each do |x|
        wire_locations.push(Location.new(x, current.y))
        wire_grid[x][current.y] = true
      end
      current = Location.new(current.x + moves,current.y)
    when "L"
      (current.x.downto(current.x - moves)).each do |x|
        wire_locations.push(Location.new(x, current.y))
        wire_grid[x][current.y] = true
      end
      current = Location.new(current.x - moves,current.y)
    when "U"
      (current.y..(current.y + moves)).each do |y|
        wire_locations.push(Location.new(current.x, y))
        wire_grid[current.x][y] = true
      end
      current = Location.new(current.x,current.y + moves)
    when "D"
      (current.y.downto(current.y - moves)).each do |y|
        wire_locations.push(Location.new(current.x, y))
        wire_grid[current.x][y] = true
      end
      current = Location.new(current.x,current.y - moves)
    end
  end
  wire_locations
end

wire1_locations = get_wire_locations(wire1, wire_grid1)
wire2_locations = get_wire_locations(wire2, wire_grid2)

intersections = []
wire2_locations.each do |loc|
  if wire_grid1[loc.x][loc.y] == true
    intersections.push(loc) unless loc.x == 0 && loc.y == 0
  end
end

min_location = intersections.min {|l1,l2| (l1.x.abs + l1.y.abs) <=> (l2.x.abs + l2.y.abs) }

puts min_location.x.abs + min_location.y.abs
