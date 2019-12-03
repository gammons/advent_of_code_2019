def fuel_for(n)
  fuel = (n / 3).floor - 2
  return 0 if fuel <= 0

  fuel + fuel_for(fuel)
end

def run
  data = File.readlines("input.txt").map {|n| n.to_i}
  puts data.inject(0) { |sum, n| sum + fuel_for(n) }
end

run
