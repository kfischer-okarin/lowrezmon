def test_battle_system_determine_turn_order_faster_emojimon_goes_first(_args, assert)
  player = {
    emojimon: { speed: 1 },
    selected_action: { type: :attack }
  }
  opponent = {
    emojimon: { speed: 5 },
    selected_action: { type: :attack }
  }

  assert.equal! BattleSystem.determine_turn_order(player, opponent), [:opponent, :player]

  player[:emojimon][:speed] = 5
  opponent[:emojimon][:speed] = 1

  assert.equal! BattleSystem.determine_turn_order(player, opponent), [:player, :opponent]
end

def test_battle_system_determine_turn_order_same_speed_means_random_order(_args, assert)
  player = {
    emojimon: { speed: 3 },
    selected_action: { type: :attack }
  }
  opponent = {
    emojimon: { speed: 3 },
    selected_action: { type: :attack }
  }

  player_went_first = false
  opponent_went_first = false

  100.times do
    turn_order = BattleSystem.determine_turn_order(player, opponent)
    case turn_order
    when [:player, :opponent]
      player_went_first = true
    when [:opponent, :player]
      opponent_went_first = true
    end

    break if player_went_first && opponent_went_first
  end

  assert.true! player_went_first && opponent_went_first,
               'Expected both player and opponent to have gone first at least once in 100 tries'
end

def test_battle_system_determine_turn_order_exchange_player_goes_first(_args, assert)
  player = {
    emojimon: { speed: 1 },
    selected_action: { type: :exchange }
  }
  opponent = {
    emojimon: { speed: 5 },
    selected_action: { type: :attack }
  }

  assert.equal! BattleSystem.determine_turn_order(player, opponent), [:player, :opponent]
end

def test_battle_system_calc_damage_attack_increases_damage(_args, assert)
  attacker = { attack: 1 }
  defender = { defense: 1, type: :sassy }
  attack = { type: :sassy }

  srand 1000 # Reset random seed to get consistent results
  damage_with_attack1 = BattleSystem.calc_damage(attacker, defender, attack)

  attacker[:attack] = 2
  srand 1000 # Reset random seed to get consistent results
  damage_with_attack2 = BattleSystem.calc_damage(attacker, defender, attack)

  assert.true! damage_with_attack2[:total_amount] > damage_with_attack1[:total_amount],
               "Expected damage with attack 2 (#{damage_with_attack2[:total_amount]}) to be greater than damage with attack 1 (#{damage_with_attack1[:total_amount]})"
end

def test_battle_system_calc_damage_defense_reduces_damage(_args, assert)
  attacker = { attack: 1 }
  defender = { defense: 1, type: :sassy }
  attack = { type: :sassy }

  srand 1000 # Reset random seed to get consistent results
  damage_with_defense1 = BattleSystem.calc_damage(attacker, defender, attack)

  defender[:defense] = 2
  srand 1000 # Reset random seed to get consistent results
  damage_with_defense2 = BattleSystem.calc_damage(attacker, defender, attack)

  assert.true! damage_with_defense2[:total_amount] < damage_with_defense1[:total_amount],
               "Expected damage with defense 2 (#{damage_with_defense2[:total_amount]}) to be less than damage with defense 1 (#{damage_with_defense1[:total_amount]})"
end

def test_battle_system_calc_damage_effective_attack(_args, assert)
  attacker = { attack: 5 }
  defender = { defense: 1, type: :sassy }
  attack = { type: :sassy }

  srand 1000 # Reset random seed to get consistent results
  normal_attack_damage = BattleSystem.calc_damage(attacker, defender, attack)

  defender[:type] = :sexy
  srand 1000 # Reset random seed to get consistent results
  effective_attack_damage = BattleSystem.calc_damage(attacker, defender, attack)

  assert.equal! effective_attack_damage[:total_amount], normal_attack_damage[:total_amount] * 2
end

def test_battle_system_calc_damage_ineffective_attack(_args, assert)
  attacker = { attack: 5 }
  defender = { defense: 1, type: :sassy }
  attack = { type: :sassy }

  srand 1000 # Reset random seed to get consistent results
  normal_attack_damage = BattleSystem.calc_damage(attacker, defender, attack)

  defender[:type] = :silly
  srand 1000 # Reset random seed to get consistent results
  ineffective_attack_damage = BattleSystem.calc_damage(attacker, defender, attack)

  assert.equal! ineffective_attack_damage[:total_amount], normal_attack_damage[:total_amount] / 2
end

def test_battle_system_calc_damage_will_always_do_at_least_1_damage(_args, assert)
  attacker = { attack: 1 }
  defender = { defense: 20, type: :silly }
  attack = { type: :sassy }

  100.times do
    damage = BattleSystem.calc_damage(attacker, defender, attack)

    assert.true! damage[:total_amount].positive?,
                  "Expected damage to be positive, but was #{damage[:total_amount]}"
  end
end
