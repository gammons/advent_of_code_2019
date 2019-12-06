require "byebug"

class Planet
  attr_accessor :name, :parent

  def initialize(name)
    @name = name
  end

  def parent=(planet)
    @parent = planet
  end

  def parent_count
    p ||= @parent

    count = 0
    while p != nil do
      p  = p.parent
      count += 1
    end

    count
  end
end

planets = []

data = File.readlines("input.txt").map {|d| d.gsub(/\n/, "") }
data.each do |orbit|
  p1_name = orbit.split(")")[0]
  p2_name = orbit.split(")")[1]

  planet1 = planets.find {|p| p.name == p1_name }
  if planet1.nil?
    planet1 = Planet.new(p1_name)
    planets << planet1
  end

  planet2 = planets.find {|p| p.name == p2_name }
  if planet2.nil?
    planet2 = Planet.new(p2_name)
    planets << planet2
  end

  planet2.parent = planet1
end

puts planets.sum(&:parent_count)
