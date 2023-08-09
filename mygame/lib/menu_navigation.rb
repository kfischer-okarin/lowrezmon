class MenuNavigation
  attr_reader :children, :selected_child, :selected_index

  def initialize(children, selected_index: 0, loop: true, horizontal: false)
    @children = children
    @horizontal = horizontal
    @loop = loop

    children.each do |child|
      child.selected = false
    end
    @selected_index = 0

    self.selected_index = selected_index
  end

  def selected_index=(value)
    old_index = @selected_index
    @selection_changed = old_index != value
    @selected_index = @loop ? (value % @children.size) : value.clamp(0, @children.size - 1)
    @children[old_index].selected = false
    @children[@selected_index].selected = true
    @selected_child = @children[@selected_index]
    @selected_index
  end

  def selection_changed?
    @selection_changed
  end

  def tick(args)
    @selection_changed = false
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
