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
  def initialize(ip, rb, memory)
    @ip = ip
    @rb = rb
    @memory = memory
    @opcode = @memory.get(@ip)
  end

  def process; end

  def output
    nil
  end

  def value_for(param_num)
    case parameter_mode_for(param_num)
    when PARAMETER_MODES::IMMEDIATE
      return params[param_num].to_i
    when PARAMETER_MODES::RELATIVE
      @memory.get(@rb + params[param_num].to_i)
    else
      @memory.get(params[param_num].to_i)
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
    @memory.get((@ip + 1)..(@ip + number_of_params))
  end

  def param_values
    ret = []
    number_of_params.times {|n| ret.push(value_for(n)) }
    ret
  end
end

class AddInstruction < Instruction
  def process
    puts "    Add: @data[#{params[2].to_i}] =  #{value_for(0)} + #{value_for(1)}"
    @memory.set(params[2].to_i, (value_for(0) + value_for(1)))
  end

  def number_of_params
    3
  end
end

class MultiplyInstruction < Instruction
  def process
    puts "    Multiply: @data[#{params[2].to_i}] =  #{value_for(0)} * #{value_for(1)}"
    @memory.set(params[2].to_i, (value_for(0) * value_for(1)))
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
    byebug
    # puts "    Input: @data[#{params[0]}] = #{@input}"
    # @data[params[0].to_i] = @input
    puts "    Input: @data[#{value_for(0)}] = #{@input}"
    @memory.set(value_for(0), @input)
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
    puts "    JumpIfTrue: if #{value_for(0)} != 0 then jump to #{value_for(1)}"
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
    puts "    JumpIfFalse: if #{value_for(0)} == 0 then jump to #{value_for(1)}"
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
    puts "    LessThan: @data[#{params[2].to_i}] = #{value_for(0)} < #{value_for(1)} ? 1 : 0"
    val = value_for(0) < value_for(1) ? 1 : 0
    @memory.set(params[2].to_i, val)
  end

  def number_of_params
    3
  end
end

class EqualsInstruction < Instruction
  def process
    puts "    LessThan: @data[#{params[2].to_i}] = #{value_for(0)} == #{value_for(1)} ? 1 : 0"
    val = value_for(0) == value_for(1) ? 1 : 0
    @memory.set(params[2].to_i, val)
  end

  def number_of_params
    3
  end
end

class AdjustRelativeBaseInstruction < Instruction
  def next_rb_position
    @rb + value_for(0).to_i
  end

  def number_of_params
    1
  end
end

class Memory
  def initialize(data)
    @data = data + Array.new(50_000_000, 0)
  end

  def set(addr, val)
    @data[addr.to_i] = val.to_i
  end

  def get(addr)
    if addr.is_a?(Range)
      @data[addr]
    else
      @data[addr.to_i]
    end
  end
end

class Computer
  attr_reader :output

  def load(data, inputs)
    @ip = 0
    @rb = 0
    @memory = Memory.new(data)
    @inputs = inputs
    @output = []
    @done = false
  end

  def process
    puts "inputs = #{@inputs}"
    while !@done
      instruction = get_instruction(@memory.get(@ip))

      puts "\n------------------------------"
      puts "ip = #{@ip}"
      puts "rb = #{@rb}"
      puts "#{@memory.get(@ip)}: #{instruction.class.name}"
      puts "    with params: #{instruction.params}"
      puts "    with param modes: #{(0..instruction.params.count - 1).map {|n| instruction.parameter_mode_for(n) } }"
      puts "    with param values: #{instruction.param_values}"

      # if instruction.class.name == "InputInstruction"
      #   #return if @inputs.length.zero?
      #   @inputs.shift
      # end

      instruction.process

      @output.push(instruction.output) unless instruction.output.nil?
      @ip = instruction.next_ip_position
      @rb = instruction.next_rb_position
      #byebug
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
      AddInstruction.new(@ip, @rb, @memory)
    when INSTRUCTIONS::MULTIPLY
      MultiplyInstruction.new(@ip, @rb, @memory)
    when INSTRUCTIONS::INPUT
      i = InputInstruction.new(@ip, @rb, @memory)
      i.set_input(@inputs.shift)
      i
    when INSTRUCTIONS::OUTPUT
      OutputInstruction.new(@ip, @rb, @memory)
    when INSTRUCTIONS::JUMP_IF_TRUE
      JumpIfTrueInstruction.new(@ip, @rb, @memory)
    when INSTRUCTIONS::JUMP_IF_FALSE
      JumpIfFalseInstruction.new(@ip, @rb, @memory)
    when INSTRUCTIONS::LESS_THAN
      LessThanInstruction.new(@ip, @rb, @memory)
    when INSTRUCTIONS::EQUALS
      EqualsInstruction.new(@ip, @rb, @memory)
    when INSTRUCTIONS::RELATIVE_BASE_OFFSET
      AdjustRelativeBaseInstruction.new(@ip, @rb, @memory)
    when INSTRUCTIONS::O_END
      @done = true
      EndInstruction.new(@ip, @rb, @memory)
    end
  end
end

data = File.read("input.txt").gsub(/\n/,"").split(",")
c = Computer.new
c.load(data,[1])
c.process
puts c.output
