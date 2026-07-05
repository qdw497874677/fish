extends RefCounted


static func enemy_hit_index(click_position: Vector2, enemy_list: Array[Dictionary], hit_radius: float) -> int:
	for index in range(enemy_list.size() - 1, -1, -1):
		var enemy_position: Vector2 = enemy_list[index]["pos"]
		if click_position.distance_to(enemy_position) <= hit_radius:
			return index
	return -1


static func apply_enemy_damage(enemy: Dictionary, damage: int) -> bool:
	enemy["hp"] = enemy["hp"] - damage
	return is_enemy_defeated(enemy)


static func is_enemy_defeated(enemy: Dictionary) -> bool:
	return int(enemy["hp"]) <= 0


static func enemy_coin_reward(enemy: Dictionary) -> int:
	var enemy_type := str(enemy.get("type", "tank" if enemy.get("tank", false) else "normal"))
	if enemy_type == "thief":
		return 30
	return 35 if bool(enemy.get("tank", false)) else 22
