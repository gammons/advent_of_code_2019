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

  def output
    nil
  end

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
  def initialize(ip, data, input)
    @ip = ip
    @data = data
    @opcode = @data[@ip]
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
  def initialize(ip, data)
    @ip = ip
    @data = data
    @opcode = @data[@ip]
  end

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

class Computer
  attr_reader :output

  def load(data, inputs)
    @ip = 0
    @data = data
    @inputs = inputs
    @output = []
    @done = false
  end

  def process
    while !@done
      instruction = get_instruction(@data[@ip])
      instruction.process
      @output.push(instruction.output) unless instruction.output.nil?
      @ip = instruction.next_ip_position
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
      AddInstruction.new(@ip, @data)
    when INSTRUCTIONS::MULTIPLY
      MultiplyInstruction.new(@ip, @data)
    when INSTRUCTIONS::INPUT
      InputInstruction.new(@ip, @data, @inputs.shift)
    when INSTRUCTIONS::OUTPUT
      OutputInstruction.new(@ip, @data)
    when INSTRUCTIONS::JUMP_IF_TRUE
      JumpIfTrueInstruction.new(@ip, @data)
    when INSTRUCTIONS::JUMP_IF_FALSE
      JumpIfFalseInstruction.new(@ip, @data)
    when INSTRUCTIONS::LESS_THAN
      LessThanInstruction.new(@ip, @data)
    when INSTRUCTIONS::EQUALS
      EqualsInstruction.new(@ip, @data)
    when INSTRUCTIONS::O_END
      @done = true
      EndInstruction.new(@ip, @data)
    end
  end
end

class AmpCircuit
  def initialize(data)
    @data = data.freeze
    @ampA = Computer.new
    @ampB = Computer.new
    @ampC = Computer.new
    @ampD = Computer.new
    @ampE = Computer.new
    @max_output = 0
    @max_thruster_signal = 0
  end

  def process_all
    [0,1,2,3,4].permutation.to_a.each do |p|
      process_signal(p)
    end
  end

  def process_signal(signal)
    @ampA.load(@data.dup, [signal[0],0])
    @ampA.process
    @ampB.load(@data.dup, [(signal[1] || "0"), @ampA.output.first])
    @ampB.process
    @ampC.load(@data.dup, [(signal[2] || "0"), @ampB.output.first])
    @ampC.process
    @ampD.load(@data.dup, [(signal[3] || "0"), @ampC.output.first])
    @ampD.process
    @ampE.load(@data.dup, [(signal[4] || "0"), @ampD.output.first])
    @ampE.process

    if @ampE.output.first > @max_output
      @max_output = @ampE.output.first
      @max_thruster_signal = signal
    end
  end

  def output
    @max_output
  end
end

data = File.read("input.txt").split(",")
a = AmpCircuit.new(data)
a.process_all
puts a.output
