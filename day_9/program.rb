require "byebug"

module INSTRUCTIONS
  ADD = "1"
  MULTIPLY = "2"
  INPUT = "3"
  OUTPUT = "4"
  JUMP_IF_TRUE = "5"
  JUMP_IF_FALSE = "6"
  LESS_THAN = "7"
  EQUALS = "8"
  RELATIVE_BASE_OFFSET = "9"
  O_END = "99"
end

module PARAMETER_MODES
  POSITION = 0
  IMMEDIATE = 1
  RELATIVE = 2
end

class Instruction
  def initialize(ip, rb, data)
    @ip = ip
    @rb = rb
    @data = data
    @opcode = @data[@ip]
  end

  def process; end

  def output
    nil
  end

  def value_for(param_num)
    case parameter_mode_for(param_num)
    when PARAMETER_MODES::IMMEDIATE
      params[param_num].to_i
    when PARAMETER_MODES::RELATIVE
      @data[@rb + params[param_num].to_i].to_i
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

  def next_rb_position
    @rb
  end

  def number_of_params
    0
  end

  def params
    @data[(@ip + 1)..(@ip + number_of_params)]
  end

  def param_values
    ret = []
    number_of_params.times {|n| ret.push(value_for(n)) }
    ret
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
  def set_input(input)
    @input = input
  end

  def process
    @data[params[0].to_i] = @input
  end

  def number_of_params
    1
  end
end

class OutputInstruction < Instruction
  def process
    @output = value_for(0)
  end

  def output
    @output
  end

  def number_of_params
    1
  end
end

class EndInstruction < Instruction
  def process
  end
end

class JumpIfTrueInstruction < Instruction
  def next_ip_position
    if value_for(0) != 0
      value_for(1)
    else
      @ip + params.length + 1
    end
  end

  def number_of_params
    2
  end
end

class JumpIfFalseInstruction < Instruction
  def next_ip_position
    if value_for(0) == 0
      value_for(1)
    else
      @ip + params.length + 1
    end
  end

  def number_of_params
    2
  end
end

class LessThanInstruction < Instruction
  def process
    @data[params[2].to_i] = (value_for(0) < value_for(1)) ? 1 : 0
  end

  def number_of_params
    3
  end
end

class EqualsInstruction < Instruction
  def process
    @data[params[2].to_i] = (value_for(0) == value_for(1)) ? 1 : 0
  end

  def number_of_params
    3
  end
end

class AdjustRelativeBaseInstruction < Instruction
  def next_rb_position
    @rb += value_for(0).to_i
  end

  def number_of_params
    1
  end
end

class Computer
  attr_reader :output

  def load(data, inputs)
    @ip = 0
    @rb = 0
    @data = data + Array.new(50_000_000, 0)
    @inputs = inputs
    @output = []
    @done = false
  end

  def process
    puts "inputs = #{@inputs}"
    while !@done
      instruction = get_instruction(@data[@ip])

      puts "\n------------------------------"
      puts "ip = #{@ip}"
      puts "rb = #{@rb}"
      puts "#{@data[@ip]}: #{instruction.class.name}"
      puts "    with params: #{instruction.params}"
      puts "    with param values: #{instruction.param_values}"

      if instruction.class.name == "InputInstruction"
        return if @inputs.length.zero?
        @inputs.shift
      end

      instruction.process

      @output.push(instruction.output) unless instruction.output.nil?
      @ip = instruction.next_ip_position
      @rb = instruction.next_rb_position
    end
  end

  private

  def get_instruction(raw_opcode)
    opcode = raw_opcode
    if raw_opcode.length > 1
      opcode = (raw_opcode.chars[raw_opcode.chars.length - 2..raw_opcode.chars.length].join).to_i.to_s
    end

    case opcode
    when INSTRUCTIONS::ADD
      AddInstruction.new(@ip, @rb, @data)
    when INSTRUCTIONS::MULTIPLY
      MultiplyInstruction.new(@ip, @rb, @data)
    when INSTRUCTIONS::INPUT
      i =InputInstruction.new(@ip, @rb, @data)
      i.set_input(@inputs[0])
      i
    when INSTRUCTIONS::OUTPUT
      OutputInstruction.new(@ip, @rb, @data)
    when INSTRUCTIONS::JUMP_IF_TRUE
      JumpIfTrueInstruction.new(@ip, @rb, @data)
    when INSTRUCTIONS::JUMP_IF_FALSE
      JumpIfFalseInstruction.new(@ip, @rb, @data)
    when INSTRUCTIONS::LESS_THAN
      LessThanInstruction.new(@ip, @rb, @data)
    when INSTRUCTIONS::EQUALS
      EqualsInstruction.new(@ip, @rb, @data)
    when INSTRUCTIONS::RELATIVE_BASE_OFFSET
      AdjustRelativeBaseInstruction.new(@ip, @rb, @data)
    when INSTRUCTIONS::O_END
      @done = true
      EndInstruction.new(@ip, @rb, @data)
    end
  end
end

data = File.read("input.txt").split(",")
c = Computer.new
c.load(data,[1])
c.process
puts c.output
