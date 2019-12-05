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
    return @opcode.chars.reverse[param_num + 2].to_i
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
      process_opcode(@data[@ip], number_of_params(@data[@ip]))
      @ip += number_of_params(@data[@ip]) + 1
      debug "Step at ip #{@ip}"
    end
  end

  private

  def process_opcode(raw_opcode, param_count)
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
      debug "Add instruction with params #{params}"
      AddInstruction.new(@data[@ip], params, @data).process
    when INSTRUCTIONS::MULTIPLY
      debug "Multiply instruction with params #{params}"
      MultiplyInstruction.new(@data[@ip], params, @data).process
    when INSTRUCTIONS::INPUT
      debug "input instruction with params #{params}"
      InputInstruction.new(@data[@ip], params, @data).process
    when INSTRUCTIONS::OUTPUT
      debug "output instruction with params #{params}"
      OutputInstruction.new(@data[@ip], params, @data).process
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

data = File.read("input.txt").split(",")#.map {|n| nto_i }
puts Computer.new(data).process
