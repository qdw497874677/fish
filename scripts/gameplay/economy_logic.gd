extends RefCounted

const GameplayTuning := preload("res://scripts/data/gameplay_tuning.gd")


static func food_drop_cost(food_level: int) -> int:
	return GameplayTuning.FOOD_DROP_BASE_COST + food_level * GameplayTuning.FOOD_DROP_LEVEL_COST


static func food_upgrade_cost(food_level: int) -> int:
	return GameplayTuning.FOOD_UPGRADE_BASE_COST + food_level * GameplayTuning.FOOD_UPGRADE_LEVEL_COST


static func core_cost(level_config: Dictionary, cores: int) -> int:
	return level_config["core_base_cost"] + cores * level_config["core_step_cost"]


static func can_buy_core(money: int, core_cost_value: int, cores: int, paused: bool, game_over: bool, level_cleared: bool) -> bool:
	return money >= core_cost_value and cores < GameplayTuning.CORE_GOAL and not paused and not game_over and not level_cleared


static func minimum_fish_cost(fish_types: Array) -> int:
	var minimum_cost := 999999
	for config in fish_types:
		minimum_cost = min(minimum_cost, int(config["cost"]))
	return minimum_cost


static func can_buy_fish(money: int, fish_config: Dictionary, game_over: bool, level_cleared: bool) -> bool:
	return money >= int(fish_config["cost"]) and not game_over and not level_cleared


static func can_upgrade_food(money: int, food_level: int, upgrade_cost: int, game_over: bool, level_cleared: bool) -> bool:
	return money >= upgrade_cost and food_level < GameplayTuning.MAX_FOOD_LEVEL and not game_over and not level_cleared
