module Scenes
  class Tournament
    def initialize(args, tournament:)
      @font = build_pokemini_font
      @state = :build_team
      @tournament = tournament
      @team_builder = Scenes::TeamBuilder.new(args, previous_scene: self)
      @battle_index = 0
    end

    def update(args)
      case @state
      when :build_team
        $next_scene = @team_builder
        @state = :prepare_player
      when :prepare_player
        @player = {
          name: 'GREEN',
          emojimons: @team_builder.chosen_emojimons
        }
        @state = :next_opponent
      when :next_opponent
        if Controls.confirm?(args.inputs)
          SFX.play(args, :hit)

          @state = :start_battle
        end
      when :start_battle
        @battle = Scenes::Battle.new(
          args,
          previous_scene: self,
          player_trainer: @player,
          opponent_trainer: @tournament[:opponents][@battle_index]
        )
        $next_scene = @battle
        @state = :battle_result
      when :battle_result
        if @battle.result == :won
          if @battle_index < @tournament[:opponents].size - 1
            @battle_index += 1
            restore_player_emojimons_health
            @state = :next_opponent
          else
            Music.play args, :main_menu
            won_tournaments = SaveData.retrieve(args, :won_tournaments)
            won_tournaments << @tournament[:name]
            won_tournaments.uniq!
            SaveData.store(args, :won_tournaments, won_tournaments)
            @state = :tournament_won
          end
        else
          @state = :game_over
        end
      when :tournament_won, :game_over
        if Controls.confirm?(args.inputs)
          SFX.play(args, :hit)
          Music.play args, :main_menu
          $next_scene = Scenes::MainMenu.new args
        end
      end
    end

    def render(screen, state)
      case @state
      when :next_opponent
        screen.primitives << {
          x: 0, y: 0, w: 64, h: 64, path: :pixel,
        }.sprite!(@tournament[:color])
        total_opponents = @tournament[:opponents].size
        screen.primitives << @font.build_label(text: @tournament[:name], x: 32, y: 54, alignment_enum: 1)
        screen.primitives << @font.build_label(text: "Opponent #{@battle_index + 1}/#{total_opponents}", x: 32, y: 40, alignment_enum: 1)
        opponent = @tournament[:opponents][@battle_index]
        screen.primitives << @font.build_label(text: opponent[:name], x: 32, y: 32, alignment_enum: 1)

        if state.tick_count % 60 < 30
          screen.primitives << @font.build_label(text: 'Press SPACE', x: 32, y: 18, alignment_enum: 1)
          screen.primitives << @font.build_label(text: 'to start', x: 32, y: 10, alignment_enum: 1)
        end
      when :tournament_won
        screen.primitives << {
          x: 0, y: 0, w: 64, h: 64, path: :pixel
        }.sprite!(Palette::BLACK)

        screen.primitives << {
          x: 16, y: 30, w: 32, h: 32,
          path: 'sprites/trophy_big.png'
        }.sprite!(@tournament[:color])

        screen.primitives << @font.build_label(text: 'You won the', x: 32, y: 20, alignment_enum: 1, **Palette::WHITE)
        screen.primitives << @font.build_label(text: @tournament[:name].upcase, x: 32, y: 13, alignment_enum: 1, **Palette::WHITE)
        screen.primitives << @font.build_label(text: 'Press SPACE', x: 32, y: 1, alignment_enum: 1, **Palette::WHITE)
      when :game_over
        screen.primitives << {
          x: 0, y: 0, w: 64, h: 64, path: :pixel
        }.sprite!(Palette::BLACK)

        screen.primitives << {
          x: 16, y: 30, w: 32, h: 32,
          tile_x: 128, tile_y: 16, tile_w: 16, tile_h: 16,
          path: 'sprites/emojis.png'
        }

        offset = (state.tick_count % 48).idiv(3)
        screen.primitives << {
          x: 25, y: 45 - offset, w: 1, h: 3, path: :pixel
        }.sprite!(Palette::TEAR_HIGHLIGHT_COLOR)

        offset = ((state.tick_count + 16) % 48).idiv(3)
        screen.primitives << {
          x: 27, y: 45 - offset, w: 1, h: 3, path: :pixel
        }.sprite!(Palette::TEAR_HIGHLIGHT_COLOR)

        offset = ((state.tick_count + 12) % 48).idiv(3)
        screen.primitives << {
          x: 38, y: 45 - offset, w: 1, h: 3, path: :pixel
        }.sprite!(Palette::TEAR_HIGHLIGHT_COLOR)

        offset = ((state.tick_count + 30) % 48).idiv(3)
        screen.primitives << {
          x: 36, y: 45 - offset, w: 1, h: 3, path: :pixel
        }.sprite!(Palette::TEAR_HIGHLIGHT_COLOR)

        screen.primitives << @font.build_label(text: 'GAME OVER', x: 32, y: 20, alignment_enum: 1, **Palette::WHITE)
        screen.primitives << @font.build_label(text: 'Press SPACE', x: 32, y: 1, alignment_enum: 1, **Palette::WHITE)
      end
    end

    private

    def restore_player_emojimons_health
      @player[:emojimons].each do |emojimon|
        emojimon[:hp] = SPECIES[emojimon[:species]][:max_hp]
      end
    end
  end
end
