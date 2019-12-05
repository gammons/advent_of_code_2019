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
  def initialize(opcode, ip, params, data)
    @ip = ip
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
    return @opcode.chars.reverse[param_num + 2].to_i
  end

  def next_ip_position
    @ip + @params.length + 1
  end
end

class AddInstruction < Instruction
  def process
    @data[@params[2].to_i] = (value_for(0) + value_for(1)).to_s
  end
end

class MultiplyInstruction < Instruction
  def process
    @data[@params[2].to_i] = (value_for(0) * value_for(1)).to_s
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

    params = []
    params = @data[(@ip + 1)..(@ip + param_count)] if opcode != INSTRUCTIONS::O_END

    debug "    raw_opcode = '#{raw_opcode}'"
    debug "    opcode = '#{opcode}'"
    debug "    params = #{params}"
    case opcode
    when INSTRUCTIONS::ADD
      AddInstruction.new(@data[@ip], @ip, params, @data)
    when INSTRUCTIONS::MULTIPLY
      MultiplyInstruction.new(@data[@ip], @ip, params, @data)
    when INSTRUCTIONS::INPUT
      InputInstruction.new(@data[@ip], @ip, params, @data)
    when INSTRUCTIONS::OUTPUT
      OutputInstruction.new(@data[@ip], @ip, params, @data)
    when INSTRUCTIONS::O_END
      exit
    end
  end

  def number_of_params(raw_opcode)
    raw_opcode.reverse[0]
    return 3 if raw_opcode.reverse[0] == "1"
    return 3 if raw_opcode.reverse[0] == "2"
    return 1 if raw_opcode.reverse[0] == "3"
    return 1 if raw_opcode.reverse[0] == "4"
  end

  def debug(msg)
    return
    puts msg
  end
end

data = File.read("input.txt").split(",")
puts Computer.new(data).process
