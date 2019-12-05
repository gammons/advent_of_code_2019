require "byebug"

module INSTRUCTIONS
  ADD = "1"
  MULTIPLY = "2"
  INPUT = "3"
  OUTPUT = "4"
  O_END = "99"
end

module PARAMETER_MODES
  POSITION = 0
  IMMEDIATE = 1
end

class Instruction
  def initialize(opcode, params, data)
    @opcode = opcode
    @params = params
    @data = data
  end

  def process; end

  def value_for(param_num)
    case parameter_mode_for(param_num)
    when PARAMETER_MODES::IMMEDIATE
      @params[param_num].to_i
    else
      @data[@params[param_num].to_i].to_i
    end
  end

  # Get the parameter mode for param_num, zero based.
  def parameter_mode_for(param_num)
    return @opcode.chars.reverse[param_num + 2]
  end

end

class AddInstruction < Instruction
  def process
    @data[value_for(2)] = value_for(0) + value_for(1)
  end
end

class MultiplyInstruction < Instruction
  def process
    @data[value_for(2)] = value_for(0) * value_for(1)
  end
end

class InputInstruction < Instruction
  def process
    puts "Enter input: "
    input = gets
    @data[@params[0].to_i] = input
  end
end

class OutputInstruction < Instruction
  def process
    puts "Value for instruction: #{value_for(0)}"
  end
end

class Computer
  def initialize(data)
    @ip = 0
    @data = data
  end

  def process
    while @ip < @data.length
      process_opcode(@data[@ip], number_of_params(@data[@ip]))
      @ip += number_of_params(@data[@ip]) + 1
      puts "Step"
      gets
    end
  end

  private

  def process_opcode(raw_opcode, param_count)
    opcode = raw_opcode
    if raw_opcode.length > 1
      opcode = raw_opcode.chars[raw_opcode.chars.length - 2..raw_opcode.chars.length].join
    end
    params = @data[(@ip + 1)..(@ip + 1 + param_count)]
    puts "    opcode = '#{opcode}'"
    puts "    params = #{params}"
    case opcode
    when INSTRUCTIONS::ADD
      puts "Add instruction with params #{params}"
      AddInstruction.new(@data[@ip], params, @data).process
    when INSTRUCTIONS::MULTIPLY
      puts "Multiply instruction with params #{params}"
      MultiplyInstruction.new(@data[@ip], params, @data).process
    when INSTRUCTIONS::INPUT
      puts "input instruction with params #{params}"
      InputInstruction.new(@data[@ip], params, @data).process
    when INSTRUCTIONS::OUTPUT
      puts "output instruction with params #{params}"
      OutputInstruction.new(@data[@ip], params, @data).process
    when INSTRUCTIONS::O_END
      exit
    end
  end

  def number_of_params(raw_opcode)
    return 1 if %w(1 2 3 4).include?(raw_opcode)

    reversed = raw_opcode.reverse
    param_1_mode = reversed[2]
    param_2_mode = reversed[3]
    param_3_mode = reversed[4]

    return 0 if param_1_mode.nil?
    return 1 if param_2_mode.nil?
    return 2 if param_3_mode.nil?
    return 3
  end
end

data = File.read("input.txt").split(",")#.map {|n| nto_i }
puts Computer.new(data).process
