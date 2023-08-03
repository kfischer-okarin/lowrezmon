def build_pokemini_font
  SpritesheetFont.new(
    path: 'sprites/pokemini.png',
    letter_positions: build_pokemini_letter_positions
  )
end

def build_pokemini_fatnumbers_font
  SpritesheetFont.new(
    path: 'sprites/pokemini.png',
    letter_positions: build_pokemini_fatnumbers_letter_positions
  )
end

def build_pokemini_letter_positions
  result = {}
  ('A'..'Z').each_with_index do |letter, index|
    result[letter] = {
      tile_x: index * 6,
      tile_y: 0,
      tile_w: 5,
      tile_h: 6
    }
  end

  x = 0
  special_widths = {
    'g' => 4,
    'i' => 1,
    'j' => 2,
    'l' => 1,
    'm' => 5,
    'w' => 5,
    'x' => 5
  }
  ('a'..'z').each do |letter|
    w = special_widths[letter] || 4
    result[letter] = {
      tile_x: x,
      tile_y: 7,
      tile_w: w,
      tile_h: 6
    }
    x += w + 1
  end

  x = 0
  special_widths = {
    '1' => 3,
    '2' => 4,
    '7' => 4
  }
  ('0'..'9').each do |number|
    w = special_widths[number] || 5
    result[number] = {
      tile_x: x,
      tile_y: 15,
      tile_w: w,
      tile_h: 6
    }
    x += w + 1
  end

  x = 0
  special_widths = {
    '!' => 3,
    '^' => 3,
    '*' => 3,
    '(' => 2,
    ')' => 2,
    '[' => 2,
    ']' => 2,
    '{' => 3,
    '}' => 3,
    '<' => 3,
    '>' => 3,
    '`' => 2,
    "'" => 2,
    ':' => 2,
    ';' => 2,
    ',' => 2,
    '.' => 2,
    '-' => 3,
    '+' => 3,
    '=' => 3,
    '|' => 1,
    '/' => 3,
    '\\' => 3,
    '~' => 7, # Special smile symbol
    ' ' => 1
  }
  "!@#$%^&*()[]{}<>`':;,.?-+=|/\\~ ".each_char do |symbol|
    w = special_widths[symbol] || 5
    result[symbol] = {
      tile_x: x,
      tile_y: 22,
      tile_w: w,
      tile_h: 6
    }
    x += w + 1
  end
  result
end

def build_pokemini_fatnumbers_letter_positions
  result = build_pokemini_letter_positions
  x = 56
  special_widths = {
    '1' => 4
  }
  ('0'..'9').each do |number|
    w = special_widths[number] || 5
    result[number] = {
      tile_x: x,
      tile_y: 15,
      tile_w: w,
      tile_h: 6
    }
    x += w + 1
  end
  result
end
