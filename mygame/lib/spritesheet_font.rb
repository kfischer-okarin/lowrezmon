class SpritesheetFont
  # Letter positions is a hash with the following structure:
  #   {
  #     'A' => { tile_x: 0, tile_y: 0, tile_w: 3, tile_h: 5 },
  #     # ...
  #   }
  def initialize(path:, letter_positions:, unknown_letter_sprite: nil)
    @path = path
    black_box = {
      w: letter_positions.values.first[:tile_w],
      h: letter_positions.values.first[:tile_h],
      path: :pixel
    }
    @letter_positions = Hash.new(unknown_letter_sprite || black_box)
    @letter_positions.merge!(letter_positions)
  end

  def char_sprite(char)
    letter_position = @letter_positions[char]
    {
      w: letter_position[:tile_w], h: letter_position[:tile_h],
      path: @path,
      r: 0, g: 0, b: 0
    }.sprite!(letter_position)
  end

  def build_label(text:, x:, y:, **values)
    result = []
    case values.delete :alignment_enum
    when 1
      x -= string_w(text).idiv 2
    when 2
      x -= string_w(text)
    end
    text.each_char do |char|
      letter_sprite = char_sprite(char).merge!(x: x, y: y)
                                       .merge!(values)
      result << letter_sprite
      x += letter_sprite[:w] + 1
    end
    result
  end

  def split_into_lines(text, line_w:)
    result = []
    current_line = ''
    current_w = 0
    space_w = @letter_positions[' '][:tile_w] + 2
    text.split(' ').each do |word|
      word_w = string_w(word)
      if current_line.empty?
        current_line = word
        current_w = word_w
      elsif current_w + space_w + word_w <= line_w
        current_line += ' ' + word
        current_w += space_w + word_w
      else
        result << current_line
        current_line = word
        current_w = word_w
      end
    end
    result << current_line unless current_line.empty?
    result
  end

  def string_w(string)
    string.chars.map { |char| @letter_positions[char][:tile_w] }.sum + string.length - 1
  end
end
