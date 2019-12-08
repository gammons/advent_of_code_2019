require "byebug"

class Image
  LAYER_SIZE_X = 25
  LAYER_SIZE_Y = 6

  BLACK = 0
  WHITE = 1
  TRANSPARENT = 2

  def initialize
    @layers = []
    @rendered = []
  end

  def load(raw_data)
    raw_data.chars.each_with_index do |char, i|
      @layers.push([]) if i % (LAYER_SIZE_X * LAYER_SIZE_Y) == 0
      @layers.last.push(char.to_i)
    end
  end

  def render
    (LAYER_SIZE_X * LAYER_SIZE_Y).times { @rendered.push(TRANSPARENT) }
    @layers.reverse.each_with_index do |layer, layer_num|
      layer.each_with_index do |pixel,i|
        @rendered[i] = pixel if pixel != TRANSPARENT
      end
    end
  end

  def print
    @rendered.each_with_index do |char,i|
      putc "\n" if i % LAYER_SIZE_X == 0
      putc "X" if char == WHITE
      putc " " if char == BLACK
    end
  end
end

data = File.read("input").gsub(/\n/,"")

image = Image.new
image.load(data)
image.render
image.print
