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

  def build_label(text:, x:, y:, **values)
    result = []
    text.each_char do |char|
      letter_position = @letter_positions[char]
      letter_sprite = {
        x: x, y: y, w: letter_position[:tile_w],  h: letter_position[:tile_h],
        path: @path,
        r: 0, g: 0, b: 0
      }.sprite!(letter_position).merge!(values)
      result << letter_sprite
      x += letter_sprite[:w] + 1
    end
    result
  end
end
