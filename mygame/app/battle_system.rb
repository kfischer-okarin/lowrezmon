module BattleSystem
  class << self
    def choose_opponent_action(opponent, _player)
      {
        type: :attack,
        attack: opponent.emojimon[:attacks].sample[:id]
      }
    end

    def choose_next_opponent_emojimon(opponent, _player)
      alive_emojimon = opponent.trainer[:emojimons].select { |emojimon| emojimon[:hp].positive? }
      alive_emojimon.sample
    end

    def determine_turn_order(player, opponent)
      if player.selected_action[:type] == :exchange && opponent.selected_action[:type] != :exchange
        return [:player, :opponent]
      end

      player_emojimon_speed = player.emojimon[:speed]
      opponent_emojimon_speed = opponent.emojimon[:speed]
      if player_emojimon_speed > opponent_emojimon_speed
        return [:player, :opponent]
      elsif player_emojimon_speed < opponent_emojimon_speed
        return [:opponent, :player]
      else
        [:player, :opponent].shuffle
      end
    end

    def calc_damage(attacker, defender, attack)
      base_damage = [3 + rand(3) + (attacker[:attack] - defender[:defense]), 1].max
      multiplier = Type.calc_damage_multiplier_of(attack[:type], against_type: defender[:type])
      total_amount = [(base_damage * multiplier).to_i, 1].max
      {
        total_amount: total_amount,
        multiplier: multiplier
      }
    end
  end
end
