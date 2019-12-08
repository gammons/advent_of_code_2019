require "byebug"


class Image
  LAYER_SIZE_X = 25
  LAYER_SIZE_Y = 6

  BLACK = 0
  WHITE = 1
  TRANSPARENT = 2

  attr_reader :layers

  def initialize
    @layers = []
    @rendered = []
  end

  def load(raw_data)
    raw_data.chars.each_with_index do |char, i|
      @layers.push([]) if i % (LAYER_SIZE_X * LAYER_SIZE_Y) == 0
      @layers.last.push(char)
    end
  end

  def render
    @layers.reverse.each do |layer|

    end
    @layers.reverse.each 
  end
end

data = File.read("input").gsub(/\n/,"")

image = Image.new
image.load(data)

fewest_zeros = 9999
fewest_zeros_layer = 9999
image.layers.each_with_index do |layer,i|
  num_zeros = layer.select {|l| l == "0" }.length

  if num_zeros < fewest_zeros
    fewest_zeros_layer = i
    fewest_zeros = num_zeros
  end
end

ones = image.layers[fewest_zeros_layer].select {|i| i == "1" }.length
twos = image.layers[fewest_zeros_layer].select {|i| i == "2" }.length

puts ones * twos
