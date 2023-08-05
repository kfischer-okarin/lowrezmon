module Type
  class << self
    EFFECTIVENESS = {
      sassy: {
        sexy: :super_effective,
        silly: :not_very_effective
      }.freeze,
      silly: {
        sassy: :super_effective,
        sexy: :not_very_effective
      }.freeze,
      sexy: {
        silly: :super_effective,
        sassy: :not_very_effective
      }.freeze,
      salty: {
        salty: :super_effective
      }.freeze
    }.freeze

    def all
      EFFECTIVENESS.keys
    end

    def effectiveness_of(attacking_type, against_type:)
      raise "Unknown type: #{attacking_type}" unless all.include? attacking_type
      raise "Unknown type: #{against_type}" unless all.include? against

      EFFECTIVENESS[attacking_type][against_type] || :normal
    end
  end
end
