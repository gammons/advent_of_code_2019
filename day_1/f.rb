data = File.read("input.txt").split("\n").map {|i| i.to_i }
puts data.inject(0) {|sum, n| sum + ((n / 3).floor - 2) }
