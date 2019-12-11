require "byebug"

require_relative "intcode_computer"

class Hull
  BLACK = 0
  WHITE = 1

  def initialize
    @hull = {}
  end

  def set_color(x,y,color)
    key = "#{x}_#{y}"
    @hull[key] = color
  end

  def get_color(x,y)
    key = "#{x}_#{y}"
    @hull[key] || BLACK
  end

  def painted_count
    @hull.keys.count
  end
end

class HullPaintingRobot
  attr_reader :hull

  module Orientations
    UP = 0
    RIGHT = 1
    DOWN = 2
    LEFT = 3
  end

  def initialize
    @x = 0
    @y = 0
    @orientation = Orientations::UP
    @hull = Hull.new
    @computer = IntcodeComputer::Computer.new

    data = File.read("input.txt").gsub(/\n/,"").split(",").map {|d| d.to_i }
    @computer.load(data, [@hull.get_color(@x,@y)])
  end

  def run
    count = 0

    @computer.process do |output|
      if count.even?
        @hull.set_color(@x,@y, output)
      else
        output == 0 ? rotate_left : rotate_right
        move_robot
        @computer.inputs = [@hull.get_color(@x,@y)]
      end

      count += 1
    end
  end

  def move_robot
    case @orientation
    when Orientations::UP
      @y += 1
    when Orientations::DOWN
      @y -= 1
    when Orientations::LEFT
      @x -= 1
    when Orientations::RIGHT
      @x += 1
    end
  end

  def rotate_right
    @orientation += 1
    @orientation = 0 if @orientation > 3
  end

  def rotate_left
    @orientation -= 1
    @orientation = 3 if @orientation < 0
  end
end

h = HullPaintingRobot.new
h.run
puts h.hull.painted_count
