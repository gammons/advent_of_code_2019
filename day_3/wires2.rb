require "byebug"

class WireIntersector
  def initialize
    @wire_grid = Array.new(10000) { Array.new(10000) }
    @intersections = []
  end

  def nearest_intersection(wire_locations1, wire_locations2)
    populate_grid(wire_locations1, 1)
    populate_grid(wire_locations2, 2)

    steps_intersections_wire1 = calculate_steps(wire_locations1)
    steps_intersections_wire2 = calculate_steps(wire_locations2)

    min_steps = @intersections.map do |i|
      steps1 = steps_intersections_wire1.find {|s| s[0] == i }
      steps2 = steps_intersections_wire2.find {|s| s[0] == i }
      steps1.nil? ? nil : steps1[1] + steps2[1]
    end
    min_steps.compact.min
  end

  private

  def populate_grid(wire, wire_num)
    x = 0
    y = 0

    wire.each do |instruction|
      direction = instruction[0]
      moves = instruction[1..(instruction.length)].to_i

      case direction
      when "R"
        moves.times do
          x += 1
          populate_grid_point(x,y, wire_num)
        end
      when "L"
        moves.times do
          x -= 1
          populate_grid_point(x,y, wire_num)
        end
      when "U"
        moves.times do
          y += 1
          populate_grid_point(x,y, wire_num)
        end
      when "D"
        moves.times do
          y -= 1
          populate_grid_point(x,y, wire_num)
        end
      end
    end
  end

  def calculate_steps(wire)
    x = 0
    y = 0
    steps = 0
    steps_intersections = []

    wire.each do |instruction|
      direction = instruction[0]
      moves = instruction[1..(instruction.length)].to_i

      case direction
      when "R"
        moves.times do
          x += 1
          steps += 1
          if @intersections.any? {|i| i[0] == x && i[1] == y }
            steps_intersections.push([[x,y],steps])
          end
        end
      when "L"
        moves.times do
          x -= 1
          steps += 1
          if @intersections.any? {|i| i[0] == x && i[1] == y }
            steps_intersections.push([[x,y],steps])
          end
        end
      when "U"
        moves.times do
          y += 1
          steps += 1
          if @intersections.any? {|i| i[0] == x && i[1] == y }
            steps_intersections.push([[x,y],steps])
          end
        end
      when "D"
        moves.times do
          y -= 1
          steps += 1
          if @intersections.any? {|i| i[0] == x && i[1] == y }
            steps_intersections.push([[x,y],steps])
          end
        end
      end
    end
    steps_intersections
  end

  def manhatten
    min_location[0].abs + min_location[1].abs
  end

  def min_location
    @min_location ||= @intersections.min {|l1,l2| (l1[0].abs + l1[1].abs) <=> (l2[0].abs + l2[1].abs) }
  end

  def populate_grid_point(x,y, wire_num)
    if !@wire_grid[x][y].nil? && @wire_grid[x][y] != wire_num
      @intersections.push([x,y])
    end
    @wire_grid[x][y] = wire_num
  end
end

lines = File.read("input.txt").split("\n")
wire1 = lines[0].split(",")
wire2 = lines[1].split(",")

puts WireIntersector.new.nearest_intersection(wire1, wire2)
