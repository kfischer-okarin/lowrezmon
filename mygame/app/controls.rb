module Controls
  class << self
    def confirm?(inputs)
      inputs.keyboard.key_down.space
    end
  end
end
