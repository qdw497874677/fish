extends RefCounted


static func create_food(drop_position: Vector2, food_level: int) -> Dictionary:
	return {
		"pos": drop_position,
		"nutrition": float(food_level),
		"speed": 82.0,
		"life": 11.0,
	}


static func should_auto_feed_with_seahorse(fish_list: Array[Dictionary], food_count: int, max_food_count: int, hunger_threshold: float) -> bool:
	if fish_list.is_empty() or food_count >= max_food_count:
		return false
	for fish in fish_list:
		if float(fish.get("hunger", 0.0)) <= hunger_threshold:
			return true
	return false


static func bubble_seahorse_feed_position(fish_list: Array[Dictionary], fallback_position: Vector2) -> Vector2:
	var hungriest_position := fallback_position
	var lowest_hunger := 999999.0
	for fish in fish_list:
		var hunger := float(fish.get("hunger", 0.0))
		if hunger < lowest_hunger:
			lowest_hunger = hunger
			hungriest_position = fish.get("pos", fallback_position) as Vector2
	return hungriest_position + Vector2(randf_range(-34.0, 34.0), -58.0)


static func update_bubble_seahorse_position(current_position: Vector2, target_position: Vector2, speed: float, delta: float) -> Vector2:
	var to_target := target_position - current_position
	if to_target.length() > 2.0:
		return current_position + to_target.normalized() * min(speed * delta, to_target.length())
	return current_position


static func electric_jellyfish_target_index(origin: Vector2, enemy_list: Array[Dictionary], max_distance: float) -> int:
	var target_index := -1
	var nearest_distance := max_distance
	for index in range(enemy_list.size()):
		var enemy_position: Vector2 = enemy_list[index]["pos"]
		var distance := origin.distance_to(enemy_position)
		if distance <= nearest_distance:
			nearest_distance = distance
			target_index = index
	return target_index


static func update_food(food: Dictionary, delta: float) -> void:
	food["pos"] = food["pos"] + Vector2(0, food["speed"] * delta)
	food["life"] = food["life"] - delta


static func should_remove_food(food: Dictionary, play_rect: Rect2) -> bool:
	return food["pos"].y > play_rect.end.y - 10.0 or food["life"] <= 0.0


static func create_coin(spawn_position: Vector2, value: int, life_multiplier: float = 1.0) -> Dictionary:
	return {
		"pos": spawn_position,
		"value": value,
		"speed": 55.0,
		"life": 9.0 * life_multiplier,
		"magnet_active": false,
		"magnet_target": spawn_position,
		"magnet_time": 0.0,
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


static func can_start_player_magnet(coin: Dictionary, origin: Vector2, magnet_radius: float) -> bool:
	if bool(coin.get("magnet_active", false)):
		return false
	return (coin.get("pos", origin) as Vector2).distance_to(origin) <= magnet_radius


static func start_player_magnet(coin: Dictionary, target: Vector2, magnet_duration: float) -> void:
	coin["magnet_active"] = true
	coin["magnet_target"] = target
	coin["magnet_time"] = magnet_duration


static func update_magnetized_coin(coin: Dictionary, pull_speed: float, delta: float) -> void:
	var position: Vector2 = coin["pos"]
	var target: Vector2 = coin.get("magnet_target", position)
	var to_target := target - position
	if to_target.length() > 1.0:
		coin["pos"] = position + to_target.normalized() * min(pull_speed * delta, to_target.length())
	else:
		coin["pos"] = target
	coin["magnet_time"] = max(0.0, float(coin.get("magnet_time", 0.0)) - delta)
	coin["life"] = coin["life"] - delta


static func should_collect_magnetized_coin(coin: Dictionary, collect_radius: float) -> bool:
	if not bool(coin.get("magnet_active", false)):
		return false
	var target: Vector2 = coin.get("magnet_target", coin["pos"])
	return (coin["pos"] as Vector2).distance_to(target) <= collect_radius


static func should_cancel_magnet(coin: Dictionary) -> bool:
	return bool(coin.get("magnet_active", false)) and float(coin.get("magnet_time", 0.0)) <= 0.0


static func cancel_magnet(coin: Dictionary) -> void:
	coin["magnet_active"] = false


static func should_collect_with_snail(coin: Dictionary, cleaner_snail_position: Vector2, collect_radius: float) -> bool:
	return coin["pos"].distance_to(cleaner_snail_position) < collect_radius


static func should_collect_coin_at(coin: Dictionary, collect_position: Vector2, collect_radius: float) -> bool:
	return coin["pos"].distance_to(collect_position) <= collect_radius


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
