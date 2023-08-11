module Controls
  class << self
    def confirm?(inputs)
      inputs.keyboard.key_down.space
    end

    def cancel?(inputs)
      inputs.keyboard.key_down.escape
    end
  end
end
