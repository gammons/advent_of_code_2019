require "byebug"

class WireIntersector
  def initialize
    @wire_grid = Array.new(10000) { Array.new(10000) }
    @intersections = []
  end

  def nearest_intersection(wire_locations1, wire_locations2)
    populate_grid(wire_locations1)
    populate_grid(wire_locations2)
    manhatten
  end

  private

  def populate_grid(wire)
    x = 0
    y = 0

    wire.each do |instruction|
      direction = instruction[0]
      moves = instruction[1..(instruction.length)].to_i

      case direction
      when "R"
        moves.times do
          x += 1
          populate_grid_point(x,y)
        end
      when "L"
        moves.times do
          x -= 1
          populate_grid_point(x,y)
        end
      when "U"
        moves.times do
          y += 1
          populate_grid_point(x,y)
        end
      when "D"
        moves.times do
          y -= 1
          populate_grid_point(x,y)
        end
      end
    end
  end

  def manhatten
    min_location[0].abs + min_location[1].abs
  end

  def min_location
    @min_location ||= @intersections.min {|l1,l2| (l1[0].abs + l1[1].abs) <=> (l2[0].abs + l2[1].abs) }
  end

  def populate_grid_point(x,y)
    if @wire_grid[x][y] == 1
      @intersections.push([x,y])
    end
    @wire_grid[x][y] = 1
  end
end

lines = File.read("input.txt").split("\n")
wire1 = lines[0].split(",")
wire2 = lines[1].split(",")

puts WireIntersector.new.nearest_intersection(wire1, wire2)
