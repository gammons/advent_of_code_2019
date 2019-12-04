require "byebug"

RANGE = (235741..706948)

def is_increasing?(n)
  string_n = n.to_s
  string_n.chars.each_with_index do |char,i|
    next if i == 0
    return false if char.to_i < string_n[i - 1].to_i
  end
  true
end

def has_two_adjcent_numbers?(n)
  string_n = n.to_s
  (0..9).each do |n|
    idx = string_n.index(n.to_s * 2)
    if idx
      string_n.slice!(idx, 2)
      return true if string_n.index(n.to_s).nil?
    end
  end
  false
end

meets_criteria = 0
RANGE.each do |n|
  meets_criteria += 1 if is_increasing?(n) && has_two_adjcent_numbers?(n)
end
puts "Combos: #{meets_criteria}"
