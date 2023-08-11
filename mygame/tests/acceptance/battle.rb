require_relative 'dr_simulator.rb'

def test_battle_start(args, assert)
  BattleTest.new(args, assert) do
    start_battle(
      player_trainer: {
        name: 'GREEN',
        emojimons: [
          { species: :winking, hp: 26 }
        ]
      },
      opponent_trainer: {
        name: 'VIOLA',
        emojimons: [
          { species: :angry, hp: 26 }
        ]
      }
    )

    expect_message 'VIOLA wants to battle!'
    expect_message 'VIOLA sends Angry!'
    expect_opponent_emojimon :angry
    expect_message 'Go, Winking!'
    expect_player_emojimon :winking
    expect_action_menu

    choose_action :wink

    expect_message 'Winking uses Wink!'
    expect_message 'Angry uses Glare!'
  end
end

def test_battle_win(args, assert)
  BattleTest.new(args, assert) do
    start_battle(
      player_trainer: {
        name: 'GREEN',
        emojimons: [
          { species: :winking, hp: 26 }
        ]
      },
      opponent_trainer: {
        name: 'VIOLA',
        emojimons: [
          { species: :angry, hp: 1 }
        ]
      }
    )

    advance_until_action_menu

    choose_action :wink

    expect_message 'Winking uses Wink!'
    expect_message 'Angry disintegrates!'
    expect_message 'VIOLA is defeated!'
  end
end

def test_battle_next_opponent_emojimon(args, assert)
  BattleTest.new(args, assert) do
    start_battle(
      player_trainer: {
        name: 'GREEN',
        emojimons: [
          { species: :winking, hp: 26 }
        ]
      },
      opponent_trainer: {
        name: 'VIOLA',
        emojimons: [
          { species: :angry, hp: 1 },
          { species: :winking, hp: 26 }
        ]
      }
    )

    advance_until_action_menu

    choose_action :wink

    expect_message 'Winking uses Wink!'
    expect_message 'Angry disintegrates!'
    expect_message 'VIOLA sends Winking!'
    expect_opponent_emojimon :winking
    expect_action_menu
  end
end

def test_battle_lose(args, assert)
  BattleTest.new(args, assert) do
    start_battle(
      player_trainer: {
        name: 'GREEN',
        emojimons: [
          { species: :winking, hp: 1 }
        ]
      },
      opponent_trainer: {
        name: 'VIOLA',
        emojimons: [
          { species: :angry, hp: 26 }
        ]
      }
    )

    advance_until_action_menu

    choose_action :wink

    expect_message 'Winking uses Wink!'
    expect_message 'Angry uses Glare!'
    expect_message 'Winking disintegrates!'
    expect_message 'You were defeated!'
  end
end

class BattleTest
  def initialize(args, assert, &block)
    @args = args
    @assert = assert
    $scene = nil
    instance_eval(&block)
  end

  def start_battle(player_trainer:, opponent_trainer:)
    $scene = Scenes::Battle.new(
      @args,
      player_trainer: player_trainer,
      opponent_trainer: opponent_trainer
    )
    @simulator = DRSimulator.new(
      @args,
      tick: lambda { |args|
        $scene.update(args)
        $scene.render(args.outputs, args.state)
        if $next_scene
          $scene = $next_scene
          $next_scene = nil
        end
      }
    )
  end

  def expect_message(expected_message)
    wait_for_message

    @assert.equal! letters_in_rect(x: 0, y: 0, w: 64, h: 18).join, expected_message

    advance_message
  end

  def expect_opponent_emojimon(expected_species)
    @simulator.wait_a_bit

    opponent_sprite = @simulator.rendered_sprites.find { |sprite|
      sprite.y > 32 && sprite.path == 'sprites/emojis.png'
    }
    species = SPECIES.keys.find { |species|
      opponent_sprite.slice(:tile_x, :tile_y) == SPECIES[species][:sprite].slice(:tile_x, :tile_y)
    }

    @assert.equal! species, expected_species
  end

  def expect_player_emojimon(expected_species)
    @simulator.wait_a_bit

    player_emojimon_name = letters_in_rect(x: 0, y: 30, w: 64, h: 10).join
    species = SPECIES.keys.find { |species|
      SPECIES[species][:name] == player_emojimon_name
    }

    @assert.equal! species, expected_species
  end

  def expect_action_menu
    @assert.true! actions.any?, 'Action is not displayed'
  end

  def wait_for_message
    safe_loop error_message_on_timeout: 'No finished message' do
      @simulator.tick
      break if @simulator.rendered_sprites.find { |sprite| sprite.path == 'sprites/message_wait_triangle.png' }
    end

    @simulator.wait_a_bit
  end

  def advance_message
    @simulator.press_key :space
  end

  def advance_until_action_menu
    safe_loop error_message_on_timeout: 'No action menu' do
      wait_for_message
      advance_message
      break if actions.any?
    end

    @simulator.wait_a_bit
  end

  def choose_action(action)
    loop do
      break if selected_action[:action] == action

      @simulator.press_key :right
    end

    @simulator.press_key :space
  end

  private

  def letters_in_rect(rect)
    letter_sprites = @simulator.rendered_sprites.select { |sprite|
      sprite.path.include?('pokemini.png') && sprite.inside_rect?(rect)
    }
    letter_sprites.sort! { |sprite1, sprite2|
      if sprite1.y == sprite2.y
        sprite1.x <=> sprite2.x
      else
        -sprite1.y <=> -sprite2.y
      end
    }
    @letter_by_tile_coords ||= calc_letter_by_tile_coords
    letters = []
    y = letter_sprites.first.y
    letter_sprites.each do |sprite|
      if sprite.y != y # new line
        letters << ' '
        y = sprite.y
      end
      letters << @letter_by_tile_coords[{ tile_x: sprite.tile_x, tile_y: sprite.tile_y }]
    end

    letters
  end

  def calc_letter_by_tile_coords
    result = {}
    build_pokemini_font.instance_variable_get('@letter_positions').each do |letter, sprite|
      result[sprite.slice(:tile_x, :tile_y)] = letter
    end
    result
  end

  def selected_action
    actions.find { |action| action[:selected] }
  end

  def actions
    action_icons = @simulator.rendered_sprites.select { |sprite|
      sprite.path.include?('sprites/icons/') && !sprite.path.include?('background.png')
    }
    return [] if action_icons.empty?

    selected_background_icon_rect = @simulator.rendered_sprites.find { |sprite|
      next unless sprite.path == 'sprites/icons/background.png'

      color = { r: sprite.r, g: sprite.g, b: sprite.b }
      color == Palette::BATTLE_SELECTED_ACTION_COLOR
    }.slice(:x, :y, :w, :h)

    action_icons.map { |sprite|
      {
        action: action_of_icon(sprite),
        icon: sprite,
        selected: sprite.slice(:x, :y, :w, :h) == selected_background_icon_rect
      }
    }
  end

  def action_of_icon(action_icon)
    return :exchange if action_icon.path == 'sprites/icons/exchange.png'

    ATTACKS.keys.find { |attack|
      ATTACKS[attack][:sprite][:path] == action_icon[:path]
    }
  end

  def safe_loop(error_message_on_timeout:, max_ticks: 1000)
    ticks = 0
    loop do
      yield

      ticks += 1
      if ticks >= max_ticks
        raise "State: #{@args.state}.\n\n#{error_message_on_timeout} after 1000 ticks."
      end
    end
  end
end
