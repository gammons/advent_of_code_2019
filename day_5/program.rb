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
  def initialize(ip, data)
    @ip = ip
    @data = data
    @opcode = @data[@ip]
  end

  def process; end

  def value_for(param_num)
    case parameter_mode_for(param_num)
    when PARAMETER_MODES::IMMEDIATE
      params[param_num].to_i
    else
      @data[params[param_num].to_i].to_i
    end
  end

  # Get the parameter mode for param_num, zero based.
  def parameter_mode_for(param_num)
    return @opcode.chars.reverse[param_num + 2].to_i
  end

  def next_ip_position
    @ip + params.length + 1
  end

  def number_of_params
    0
  end

  def params
    @data[(@ip + 1)..(@ip + number_of_params)]
  end
end

class AddInstruction < Instruction
  def process
    @data[params[2].to_i] = (value_for(0) + value_for(1)).to_s
  end

  def number_of_params
    3
  end
end

class MultiplyInstruction < Instruction
  def process
    @data[params[2].to_i] = (value_for(0) * value_for(1)).to_s
  end

  def number_of_params
    3
  end
end

class InputInstruction < Instruction
  def process
    puts "Enter input: "
    input = gets
    @data[params[0].to_i] = input
  end

  def number_of_params
    1
  end
end

class OutputInstruction < Instruction
  def process
    puts "Value for instruction: #{value_for(0)}"
  end

  def number_of_params
    1
  end
end

class EndInstruction < Instruction
  def process
    exit
  end
end

class Computer
  def initialize(data)
    @ip = 0
    @data = data
  end

  def process
    while @ip < @data.length
      instruction = get_instruction(@data[@ip], number_of_params(@data[@ip]))
      instruction.process
      @ip = instruction.next_ip_position
      debug "Step at ip #{@ip}"
    end
  end

  private

  def get_instruction(raw_opcode, param_count)
    opcode = raw_opcode
    if raw_opcode.length > 1
      opcode = (raw_opcode.chars[raw_opcode.chars.length - 2..raw_opcode.chars.length].join).to_i.to_s
    end

    debug "    raw_opcode = '#{raw_opcode}'"
    debug "    opcode = '#{opcode}'"
    case opcode
    when INSTRUCTIONS::ADD
      AddInstruction.new(@ip, @data)
    when INSTRUCTIONS::MULTIPLY
      MultiplyInstruction.new(@ip, @data)
    when INSTRUCTIONS::INPUT
      InputInstruction.new(@ip, @data)
    when INSTRUCTIONS::OUTPUT
      OutputInstruction.new(@ip, @data)
    when INSTRUCTIONS::O_END
      EndInstruction.new(@ip, @data)
      exit
    end
  end

  def debug(msg)
    return
    puts msg
  end
end

data = File.read("input.txt").split(",")
puts Computer.new(data).process
