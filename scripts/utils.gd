class_name Utils

static func ws_rect(c: CanvasItem) -> Rect2:
    return c.get_canvas_transform().affine_inverse() * c.get_viewport_rect()
