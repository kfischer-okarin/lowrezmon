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
            @state = :tournament_won
          end
        else
          @state = :game_over
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
