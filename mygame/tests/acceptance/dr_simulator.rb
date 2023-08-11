class DRSimulator
  def initialize(args, tick: nil)
    @args = args
    @tick = tick || Object.method(:tick)
  end

  def tick
    @args.outputs.clear
    @tick.call(@args)
    @args.tick_count += 1
    @args.inputs.clear
  end

  def click_on(primitive)
    primitive_rect = calc_primitive_rect(primitive)
    click_on_point(
      x: primitive_rect[:x] + (primitive_rect[:w] / 2),
      y: primitive_rect[:y] + (primitive_rect[:h] / 2)
    )

    tick
  end

  def press_key(key)
    @args.inputs.keyboard.key_down.send(:"#{key}=", true)

    wait_a_bit
  end

  def rendered_labels
    label_primitives = @args.outputs.primitives.select { |primitive|
      primitive.primitive_marker == :label || primitive.respond_to?(:draw_override)
    }
    (label_primitives + @args.outputs.labels)
      .flatten
      .map { |primitive| evaluate_draw_override(primitive) }
      .flatten # Need to flatten again because draw_override might render multiple primitives
      .select { |primitive| primitive.primitive_marker == :label } # draw_override might return other primitives
      .reverse # Reverse to get the top-most primitives first
  end

  def rendered_sprites
    sprite_primitives = @args.outputs.primitives.select { |primitive|
      primitive.respond_to?(:path) || primitive.respond_to?(:draw_override)
    }
    (sprite_primitives + @args.outputs.sprites)
      .flatten
      .map { |primitive| evaluate_draw_override(primitive) }
      .flatten # Need to flatten again because draw_override might render multiple primitives
      .select { |primitive| primitive.respond_to?(:path) } # draw_override might return other primitives
      .reverse # Reverse to get the top-most primitives first
  end

  private

  def evaluate_draw_override(primitive)
    return primitive unless primitive.respond_to?(:draw_override)

    primitive_collector = PrimitiveCollector.new
    primitive.draw_override(primitive_collector)
    primitive_collector.primitives
  end

  def calc_primitive_rect(primitive)
    case primitive.primitive_marker
    when :label
      calc_label_rect(primitive)
    else
      { x: primitive.x, y: primitive.y, w: primitive.w, h: primitive.h }
    end
  end

  def calc_label_rect(label)
    label_w, label_h = $gtk.calcstringbox label.text, label.size_enum || 0, label.font || 'font.ttf'
    rect = { x: label.x, y: label.y, w: label_w, h: label_h }

    case label.alignment_enum
    when 1 # center
      rect[:x] -= label_w / 2
    when 2 # right
      rect[:x] -= label_w
    end

    case label.vertical_alignment_enum
    when 1 # middle
      rect[:y] -= label_h / 2
    when 2 # top
      rect[:y] -= label_h
    end

    rect
  end

  def click_on_point(point)
    mouse = @args.inputs.mouse
    mouse.x = point[:x]
    mouse.y = point[:y]
    mouse.click = GTK::MousePoint.new mouse.x, mouse.y

    wait_a_bit
  end

  def wait_a_bit
    15.times { tick } # 0.25 s pause... something like human reaction time
  end

  class PrimitiveCollector
    attr_reader :primitives

    def initialize
      @primitives = []
    end

    def draw_label_5(x, y, text, size_enum, alignment_enum, r, g, b, a, font, vertical_alignment_enum, blendmode_enum, size_px, anchor_x, anchor_y)
      @primitives << {
        x: x, y: y, text: text, size_enum: size_enum, alignment_enum: alignment_enum,
        r: r, g: g, b: b, a: a, font: font, vertical_alignment_enum: vertical_alignment_enum,
        blendmode_enum: blendmode_enum, size_px: size_px, anchor_x: anchor_x, anchor_y: anchor_y
      }.label!
    end

    def draw_sprite_5(x, y, w, h, path, angle, a, r, g, b, tile_x, tile_y, tile_w, tile_h, flip_h, flip_v, angle_anchor_x, angle_anchor_y, source_x, source_y, source_w, source_h, blendmode_enum, anchor_x, anchor_y)
      @primitives << {
        x: x, y: y, w: w, h: h, path: path, angle: angle, a: a, r: r, g: g, b: b,
        tile_x: tile_x, tile_y: tile_y, tile_w: tile_w, tile_h: tile_h,
        flip_horizontally: flip_h, flip_vertically: flip_v,
        angle_anchor_x: angle_anchor_x, angle_anchor_y: angle_anchor_y,
        source_x: source_x, source_y: source_y, source_w: source_w, source_h: source_h,
        blendmode_enum: blendmode_enum, anchor_x: anchor_x, anchor_y: anchor_y
      }.sprite!
    end
  end
end
