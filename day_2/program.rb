data = File.read("input.txt").split(",").map {|n| n.to_i }

ADD = 1
MULTIPLY = 2
O_END = 99

n = 0
while (intcode = data.slice((n * 4), 4); intcode != nil) do
  opcode = intcode[0]
  num1 = data[intcode[1]]
  num2 = data[intcode[2]]
  result_position = intcode[3]

  case opcode
  when ADD
    data[result_position] = num1 + num2
  when MULTIPLY
    data[result_position] = num1 * num2
  when O_END
    break;
  end

  n += 1
end

puts "Output Data = #{data.join(",")}"
