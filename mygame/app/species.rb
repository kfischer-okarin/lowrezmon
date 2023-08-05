EMOJI_BASE_SPRITE = {
  path: 'sprites/emojis.png',
  tile_w: 16,
  tile_h: 16,
  w: 16,
  h: 16
}.freeze

EMOJI_BACK_BASE_SPRITE = {
  path: 'sprites/blank_emojis.png',
  source_w: 16,
  source_h: 12,
  w: 23,
  h: 18
}.freeze

YELLOW_BACK_SPRITE = EMOJI_BACK_BASE_SPRITE.merge(
  source_x: 0,
  source_y: 4
).freeze

RED_BACK_SPRITE = EMOJI_BACK_BASE_SPRITE.merge(
  source_x: 16,
  source_y: 4
).freeze

SPECIES = {
  wink: {
    name: 'WINK',
    types: [:sassy, :sexy],
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 48,
      tile_y: 0
    ),
    back_sprite: YELLOW_BACK_SPRITE
  },
  angry: {
    name: 'ANGRY',
    types: [:salty],
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 16,
      tile_y: 112
    ),
    back_sprite: RED_BACK_SPRITE
  }
}
