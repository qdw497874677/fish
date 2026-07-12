extends RefCounted

const GameplayTuning := preload("res://scripts/data/gameplay_tuning.gd")


const TACTICAL_UPGRADES := [
	{
		"id": "efficient_farming",
		"name": "高效养殖",
		"category": "养殖协议",
		"description": "鱼吃下食物时，成长进度提高 20%。",
		"accent": "38bdf8",
	},
	{
		"id": "coin_preservation",
		"name": "金币保全",
		"category": "资源协议",
		"description": "新金币寿命提高 35%，玩家磁吸范围提高 25%。",
		"accent": "facc15",
	},
	{
		"id": "guard_training",
		"name": "护卫强化",
		"category": "防线协议",
		"description": "护卫鱼射程提高 25%，攻击冷却缩短 20%。",
		"accent": "34d399",
	},
	{
		"id": "emergency_supply",
		"name": "应急补给",
		"category": "补给协议",
		"description": "每次击退当前全部敌人后，免费投放 1 份低级鱼食。",
		"accent": "fb7185",
	},
]


static func tuning_copy_is_valid() -> bool:
	var expected_descriptions := {
		"efficient_farming": "鱼吃下食物时，成长进度提高 %d%%。" % _increase_percent(GameplayTuning.TACTICAL_GROWTH_MULTIPLIER),
		"coin_preservation": "新金币寿命提高 %d%%，玩家磁吸范围提高 %d%%。" % [_increase_percent(GameplayTuning.TACTICAL_COIN_LIFE_MULTIPLIER), _increase_percent(GameplayTuning.TACTICAL_COIN_MAGNET_MULTIPLIER)],
		"guard_training": "护卫鱼射程提高 %d%%，攻击冷却缩短 %d%%。" % [_increase_percent(GameplayTuning.TACTICAL_GUARD_RANGE_MULTIPLIER), _decrease_percent(GameplayTuning.TACTICAL_GUARD_COOLDOWN_MULTIPLIER)],
		"emergency_supply": "每次击退当前全部敌人后，免费投放 1 份低级鱼食。",
	}
	for upgrade_value in TACTICAL_UPGRADES:
		var upgrade: Dictionary = upgrade_value
		var upgrade_id := str(upgrade.get("id", ""))
		if not expected_descriptions.has(upgrade_id) or str(upgrade.get("description", "")) != expected_descriptions[upgrade_id]:
			return false
	return expected_descriptions.size() == TACTICAL_UPGRADES.size()


static func _increase_percent(multiplier: float) -> int:
	return int(round((multiplier - 1.0) * 100.0))


static func _decrease_percent(multiplier: float) -> int:
	return int(round((1.0 - multiplier) * 100.0))
