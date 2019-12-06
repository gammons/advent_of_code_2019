require "byebug"

class Planet
  attr_accessor :name, :parent

  def initialize(name)
    @name = name
  end

  def parent=(planet)
    @parent = planet
  end

  def parent_list
    list = [parent]
    cur = parent
    while cur.parent != nil do
      list << cur.parent
      cur = cur.parent
    end

    list
  end

  def steps_from(planet_name)
    parent_list.index {|p| p.name == planet_name }
  end
end

def find_common_parent(p1, p2)
  p1_parent_list = p1.parent_list.map(&:name)
  p2_parent_list = p2.parent_list.map(&:name)

  p1_parent_list.find do |planet|
    p2_parent_list.any? {|p2p| p2p ==  planet }
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

you = planets.find {|p| p.name == "YOU" }
san = planets.find {|p| p.name == "SAN" }

parent_name = find_common_parent(you,san)

puts "Common parent: #{parent_name}"
puts "Steps: #{you.steps_from(parent_name) + san.steps_from(parent_name)}"
