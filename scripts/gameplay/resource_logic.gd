extends RefCounted


static func create_food(drop_position: Vector2, food_level: int) -> Dictionary:
	return {
		"pos": drop_position,
		"nutrition": float(food_level),
		"speed": 82.0,
		"life": 11.0,
	}


static func update_food(food: Dictionary, delta: float) -> void:
	food["pos"] = food["pos"] + Vector2(0, food["speed"] * delta)
	food["life"] = food["life"] - delta


static func should_remove_food(food: Dictionary, play_rect: Rect2) -> bool:
	return food["pos"].y > play_rect.end.y - 10.0 or food["life"] <= 0.0


static func create_coin(spawn_position: Vector2, value: int) -> Dictionary:
	return {
		"pos": spawn_position,
		"value": value,
		"speed": 55.0,
		"life": 9.0,
	}


static func coin_spawn_position_for_fish(fish: Dictionary) -> Vector2:
	var velocity: Vector2 = fish["velocity"]
	var direction := Vector2.RIGHT
	if velocity.length() > 1.0:
		direction = velocity.normalized()
	var side_offset := Vector2(-direction.y, direction.x) * randf_range(-18.0, 18.0)
	return fish["pos"] + direction * 44.0 + side_offset + Vector2(0, -8.0)


static func update_coin(coin: Dictionary, delta: float) -> void:
	coin["pos"] = coin["pos"] + Vector2(0, coin["speed"] * delta)
	coin["life"] = coin["life"] - delta


static func should_collect_with_snail(coin: Dictionary, cleaner_snail_position: Vector2, collect_radius: float) -> bool:
	return coin["pos"].distance_to(cleaner_snail_position) < collect_radius


static func should_remove_coin(coin: Dictionary, play_rect: Rect2) -> bool:
	return coin["pos"].y > play_rect.end.y - 8.0 or coin["life"] <= 0.0


static func cleaner_snail_target(coin_list: Array[Dictionary], home_position: Vector2, cleaner_snail_position: Vector2) -> Vector2:
	var target := home_position
	var nearest_distance := 999999.0
	for coin in coin_list:
		var coin_position: Vector2 = coin["pos"]
		var distance := cleaner_snail_position.distance_to(coin_position)
		if distance < nearest_distance:
			nearest_distance = distance
			target = coin_position
	return target


static func update_cleaner_snail_position(cleaner_snail_position: Vector2, target: Vector2, speed: float, delta: float) -> Vector2:
	var to_target := target - cleaner_snail_position
	if to_target.length() > 2.0:
		return cleaner_snail_position + to_target.normalized() * speed * delta
	return cleaner_snail_position
