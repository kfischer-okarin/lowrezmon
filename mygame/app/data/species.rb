EMOJI_BASE_SPRITE = {
  path: "sprites/emojis.png",
  tile_w: 16,
  tile_h: 16,
  w: 16,
  h: 16
}.freeze

EMOJI_BACK_BASE_SPRITE = {
  path: "sprites/emojis_backview.png",
  source_y: 4,
  source_w: 24,
  source_h: 24,
  w: 24,
  h: 20
}.freeze

YELLOW_BACK_SPRITE = EMOJI_BACK_BASE_SPRITE.merge(
  source_x: 0
).freeze

RED_BACK_SPRITE = EMOJI_BACK_BASE_SPRITE.merge(
  source_x: 24
).freeze

GREEN_BACK_SPRITE = EMOJI_BACK_BASE_SPRITE.merge(
  source_x: 48
).freeze

PURPLE_BACK_SPRITE = EMOJI_BACK_BASE_SPRITE.merge(
  source_x: 72
).freeze

BLUE_BACK_SPRITE = EMOJI_BACK_BASE_SPRITE.merge(
  source_x: 96
).freeze

# Additional possible species are listed in the RESERVE_SPECIES constant

SPECIES = {
  winking: {
    name: "Winking",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 48,
      tile_y: 0
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sassy,
    max_hp: 26,
    attacks: [:wink]
  },
  angry: {
    name: "Angry",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 0,
      tile_y: 112
    ),
    back_sprite: RED_BACK_SPRITE,
    type: :salty,
    max_hp: 26,
    attacks: [:glare]
  }
}

RESERVE_SPECIES = {
  slightly_smiling: {
    name: "Slightly Smiling",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 0,
      tile_y: 0
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :silly
  },
  grinning: {
    name: "Grinning",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 16,
      tile_y: 0
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :silly
  },
  relieved: {
    name: "Relieved",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 32,
      tile_y: 0
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sassy
  },
  upside_down: {
    name: "Upside Down",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 64,
      tile_y: 0
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :silly
  },
  smiling_eyes: {
    name: "Smiling Eyes",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 80,
      tile_y: 0
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :silly
  },
  smiling_tears: {
    name: "Smiling Tears",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 96,
      tile_y: 0
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :salty
  },
  grinning_relief: {
    name: "Grinning Relief",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 112,
      tile_y: 0
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :silly
  },
  slightly_frowning: {
    name: "Slightly Frowning",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 0,
      tile_y: 16
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :salty
  },
  loudly_crying: {
    name: "Loudly Crying",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 16,
      tile_y: 16
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :salty
  },
  crying: {
    name: "Crying",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 32,
      tile_y: 16
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :salty
  },
  frowning: {
    name: "Frowning",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 48,
      tile_y: 16
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :salty
  },
  unamused: {
    name: "Unamused",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 64,
      tile_y: 16
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :salty
  },
  neutral: {
    name: "Neutral",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 80,
      tile_y: 16
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sassy
  },
  expressionless: {
    name: "Expressionless",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 96,
      tile_y: 16
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sassy
  },
  neutral_upside_down: {
    name: "Neutral Upside Down",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 112,
      tile_y: 16
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :silly
  },
  smiling_hearty_eyes: {
    name: "Smiling Hearty Eyes",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 0,
      tile_y: 32
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sexy
  },
  grinning_hearty_eyes: {
    name: "Grinning Hearty Eyes",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 16,
      tile_y: 32
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sexy
  },
  kissing_hearty_eyes: {
    name: "Kissing Hearty Eyes",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 32,
      tile_y: 32
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sexy
  },
  kiss_blower: {
    name: "Kiss Blower",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 48,
      tile_y: 32
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sexy
  },
  kisser: {
    name: "Kisser",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 64,
      tile_y: 32
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sexy
  },
  closed_eyes_kisser: {
    name: "Closed-eyes Kisser",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 80,
      tile_y: 32
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sexy
  },
  closed_eyes_kiss_blower: {
    name: "closed-eyes Kiss Blower",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 96,
      tile_y: 32
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sexy
  },
  similing_hearts: {
    name: "Similing Hearts",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 112,
      tile_y: 32
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sexy
  },
  tongue_out: {
    name: "Tongue Out",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 0,
      tile_y: 48
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :silly
  },
  zany: {
    name: "|any",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 16,
      tile_y: 48
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :silly
  },
  closed_eyes_tongue_out: {
    name: "Closed-eyes Tongue Out",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 32,
      tile_y: 48
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :silly
  },
  squinting_tongue_out: {
    name: "Squinting Tongue Out",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 48,
      tile_y: 48
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :silly
  },
  winking_tongue_out: {
    name: "Winking Tongue Out",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 64,
      tile_y: 48
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :silly
  },
  neutral_tongue_out: {
    name: "Neutral Tongue Out",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 80,
      tile_y: 48
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :silly
  },
  zanier: {
    name: "Zanier",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 96,
      tile_y: 48
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sassy
  },
  zaniest: {
    name: "Zaniest",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 112,
      tile_y: 48
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sassy
  },
  hushed: {
    name: "Hushed",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 0,
      tile_y: 64
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sassy
  },
  dizzy: {
    name: "Dizzy",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 16,
      tile_y: 64
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sassy
  },
  astonished: {
    name: "Astonished",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 32,
      tile_y: 64
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sassy
  },
  anguished: {
    name: "Anguished",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 48,
      tile_y: 64
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sassy
  },
  sleepy: {
    name: "Sleepy",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 64,
      tile_y: 64
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :silly
  },
  smiling_sleepy: {
    name: "Smiling Sleepy",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 80,
      tile_y: 64
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :silly
  },
  open_mouth: {
    name: "Open Mouth",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 96,
      tile_y: 64
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sassy
  },
  astonished_open_mouth: {
    name: "Astonished Open Mouth",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 112,
      tile_y: 64
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sassy
  },
  sunglasses: {
    name: "sunglasses",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 0,
      tile_y: 80
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sexy
  },
  persevering: {
    name: "persevering",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 16,
      tile_y: 80
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :salty
  },
  red_eyed_dizzy: {
    name: "Red-eyed Dizzy",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 32,
      tile_y: 80
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :salty
  },
  smiling_flushed: {
    name: "Smiling Flushed",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 48,
      tile_y: 80
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sexy
  },
  closed_eyes_smiling_flushed: {
    name: "Closed-eyes Smiling Flushed",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 64,
      tile_y: 80
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sexy
  },
  flushed: {
    name: "Flushed",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 80,
      tile_y: 80
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sexy
  },
  flushed_kisser: {
    name: "Flushed Kisser",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 96,
      tile_y: 80
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sexy
  },
  drooling: {
    name: "Drooling",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 112,
      tile_y: 80
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sexy
  },
  rolling_eyes: {
    name: "Rolling Eyes",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 0,
      tile_y: 96
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sassy
  },
  zipper: {
    name: "Zipper",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 16,
      tile_y: 96
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sassy
  },
  grimacing: {
    name: "Grimacing",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 32,
      tile_y: 96
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :salty
  },
  neutral_astonished: {
    name: "Neutral Astonished",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 48,
      tile_y: 96
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sassy
  },
  mask: {
    name: "Mask",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 64,
      tile_y: 96
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :silly
  },
  angry_grimacing: {
    name: "Angry Grimacing",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 80,
      tile_y: 96
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :salty
  },
  smiling_halo: {
    name: "Smiling Halo",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 96,
      tile_y: 96
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sexy
  },
  rising_eyebrow: {
    name: "Rising Eyebrow",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 112,
      tile_y: 96
    ),
    back_sprite: YELLOW_BACK_SPRITE,
    type: :sassy
  },
  angrier: {
    name: "Angrier",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 16,
      tile_y: 112
    ),
    back_sprite: RED_BACK_SPRITE,
    type: :salty
  },
  angriest: {
    name: "Angriest",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 32,
      tile_y: 112
    ),
    back_sprite: RED_BACK_SPRITE,
    type: :salty
  },
  cold: {
    name: "Cold",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 48,
      tile_y: 112
    ),
    back_sprite: BLUE_BACK_SPRITE,
    type: :silly
  },
  evil_smiling: {
    name: "Evil Smiling",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 64,
      tile_y: 112
    ),
    back_sprite: PURPLE_BACK_SPRITE,
    type: :sexy
  },
  evil_angry: {
    name: "Evil Angry",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 80,
      tile_y: 112
    ),
    back_sprite: PURPLE_BACK_SPRITE,
    type: :salty
  },
  nauseated: {
    name: "Nauseated",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 96,
      tile_y: 112
    ),
    back_sprite: GREEN_BACK_SPRITE,
    type: :salty
  },
  vomiting: {
    name: "Vomiting",
    sprite: EMOJI_BASE_SPRITE.merge(
      tile_x: 112,
      tile_y: 112
    ),
    back_sprite: GREEN_BACK_SPRITE,
    type: :salty
  }
}

def validate_species
  font = build_pokemini_font
  SPECIES.each do |species, definition|
    problems = []
    if font.string_w(definition[:name]) > 31
      problems << { type: :name_too_long, length: font.string_w(definition[:name]) }
    end
    missing_keys = definition.keys - [:name, :sprite, :back_sprite, :type, :max_hp, :attacks]
    if missing_keys.any?
      problems << { type: :missing_keys, keys: missing_keys }
    end
    if definition[:attacks]
      if definition[:attacks].any? { |attack| !ATTACKS.key?(attack) }
        problems << { type: :unknown_attack, attack: attack }
      end
      if definition[:attacks].none? { |attack| ATTACKS[attack][:type] == definition[:type] }
        problems << { type: :no_attack_of_own_type }
      end
    end

    if problems.any?
      puts "Issues with species #{species.inspect}:"
      problems.each do |problem|
        case problem[:type]
        when :name_too_long
          puts "- name \"#{definition[:name]}\" is too long (#{problem[:length]}px > 31px)"
        when :unknown_attack
          puts "- unknown attack #{problem[:attack].inspect}"
        when :no_attack_of_own_type
          puts '- no attack of own type'
        when :missing_keys
          puts "- missing keys #{problem[:keys].inspect}"
        end
      end
    end
  end

  nil
end

validate_species
