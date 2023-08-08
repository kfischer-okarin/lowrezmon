class MenuNavigation
  attr_reader :children, :selected_child, :selected_index

  def initialize(children, selected_index: 0, loop: true, horizontal: false)
    @children = children
    @horizontal = horizontal
    @loop = loop
    self.selected_index = selected_index
  end

  def selected_index=(value)
    @selected_index = @loop ? (value % @children.size) : value.clamp(0, @children.size - 1)
    @children.each_with_index do |child, index|
      child.selected = index == @selected_index
      @selected_child = child if child.selected
    end
    @selected_index
  end

  def tick(args)
    key_down = args.inputs.keyboard.key_down
    if @horizontal
      if key_down.left
        self.selected_index -= 1
      elsif key_down.right
        self.selected_index += 1
      end
    else
      if key_down.up
        self.selected_index -= 1
      elsif key_down.down
        self.selected_index += 1
      end
    end
  end
end
