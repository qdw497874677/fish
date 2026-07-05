extends RefCounted


static func find_nearest_index(origin: Vector2, items: Array[Dictionary], max_distance := 999999.0) -> int:
	var nearest_index := -1
	var nearest_distance := max_distance
	for index in range(items.size()):
		var item_position: Vector2 = items[index]["pos"]
		var distance := origin.distance_to(item_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_index = index
	return nearest_index


static func fish_separation_vector(fish_index: int, fish_list: Array[Dictionary], separation_radius: float) -> Vector2:
	var fish := fish_list[fish_index]
	var origin: Vector2 = fish["pos"]
	var separation := Vector2.ZERO
	for other_index in range(fish_list.size()):
		if other_index == fish_index:
			continue
		var other_position: Vector2 = fish_list[other_index]["pos"]
		var offset := origin - other_position
		var distance := offset.length()
		if distance > 0.01 and distance < separation_radius:
			var strength := 1.0 - distance / separation_radius
			separation += offset.normalized() * strength
	return separation.limit_length(1.0)


static func random_play_position() -> Vector2:
	return Vector2(randf_range(80.0, 1200.0), randf_range(150.0, 650.0))


static func clamp_to_rect(value: Vector2, rect: Rect2, margin: float) -> Vector2:
	return Vector2(
		clamp(value.x, rect.position.x + margin, rect.end.x - margin),
		clamp(value.y, rect.position.y + margin, rect.end.y - margin)
	)
