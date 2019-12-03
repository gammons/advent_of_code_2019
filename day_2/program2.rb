original_data = File.read("input.txt").split(",").map {|n| n.to_i }

ADD = 1
MULTIPLY = 2
O_END = 99

def compute(data, noun, verb)
  n = 0
  data[1] = noun
  data[2] = verb

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

  return data[0]
end

x = 0
y = 0
VALUE = 19690720

for x in 0..100 do
  putc "."
  for y in 0..100 do
    if compute(original_data.clone, x, y) == VALUE
      puts "Found value #{x}, #{y}"
    end
  end
end
