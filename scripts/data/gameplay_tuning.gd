extends RefCounted

# This module is the source boundary for developer-adjustable gameplay values.

# Economy and progression
const FOOD_DROP_BASE_COST: int = 2
const FOOD_DROP_LEVEL_COST: int = 2
const FOOD_UPGRADE_BASE_COST: int = 120
const FOOD_UPGRADE_LEVEL_COST: int = 80
const MAX_FOOD_LEVEL: int = 3
const CORE_GOAL: int = 3
const CORE_NEAR_READY_RATIO: float = 0.8
const MAX_LEVEL: int = 5
const CLEANER_SNAIL_UNLOCK_LEVEL: int = 1
const BUBBLE_SEAHORSE_UNLOCK_LEVEL: int = 2
const ELECTRIC_JELLYFISH_UNLOCK_LEVEL: int = 3
const NO_FISH_GRACE_TIME: float = 12.0

# Fish baseline, feeding, evasion, and guard
const FISH_INITIAL_VELOCITY_X: float = 70.0
const FISH_INITIAL_VELOCITY_Y: float = 35.0
const FISH_INITIAL_HUNGER: float = 28.0
const FISH_MAX_HUNGER: float = 32.0
const FISH_FEED_SPEED: float = 125.0
const FISH_FEED_BASE_HUNGER_GAIN: float = 12.0
const FISH_FEED_NUTRITION_HUNGER_GAIN: float = 4.0
const FISH_FEED_GROWTH_GAIN: float = 0.21
const FISH_WANDER_ARRIVAL_RADIUS: float = 24.0
const FISH_WANDER_SPEED: float = 56.0
const FISH_WANDER_BLEND: float = 0.04
const FISH_SEPARATION_RADIUS: float = 58.0
const FISH_SEPARATION_FORCE: float = 115.0
const FISH_SEPARATION_SPEED_LIMIT: float = 145.0
const FISH_EVASION_RADIUS: float = 168.0
const FISH_EVASION_FULL_STRENGTH_RADIUS: float = 88.0
const FISH_EVASION_SPEED: float = 108.0
const FISH_EVASION_MINIMUM_BLEND: float = 0.12
const FISH_EVASION_MAXIMUM_BLEND: float = 0.28
const FISH_EVASION_REVERSE_MINIMUM_BLEND: float = 0.34
const GUARD_INITIAL_COOLDOWN_MIN: float = 0.4
const GUARD_INITIAL_COOLDOWN_MAX: float = 1.4
const GUARD_ATTACK_RANGE: float = 180.0
const GUARD_ATTACK_COOLDOWN: float = 2.4
const GUARD_APPROACH_SPEED: float = 118.0
const GUARD_ORBIT_SPEED: float = 52.0
const GUARD_PREFERRED_RANGE_RATIO: float = 0.72
const GUARD_STOP_BLEND: float = 0.12
const GUARD_APPROACH_BLEND: float = 0.18
const GUARD_ORBIT_BLEND: float = 0.1

# The 32/45/55 thresholds intentionally preserve the current compatibility behavior.
const HUD_HUNGRY_THRESHOLD_CURRENT: float = 45.0
const SEAHORSE_AUTO_FEED_THRESHOLD_CURRENT: float = 55.0

# Enemy and combat
const ENEMY_IDLE_DRIFT_SPEED: float = 20.0
const ENEMY_ATTACK_COOLDOWN: float = 1.2
const PLAYER_CLICK_DAMAGE: int = 1
const GUARD_ATTACK_DAMAGE: int = 1
const ELECTRIC_JELLYFISH_DAMAGE: int = 1
const ENEMY_FISH_DAMAGE: int = 1

const _ENEMY_HP_BY_TYPE: Dictionary = {
	"normal": 5,
	"tank": 9,
	"thief": 4,
}
const _ENEMY_SPEED_BY_TYPE: Dictionary = {
	"normal": 84.0,
	"tank": 56.0,
	"thief": 104.0,
}
const _ENEMY_REWARD_BY_TYPE: Dictionary = {
	"normal": 22,
	"tank": 35,
	"thief": 30,
}

# Resources and magnet
const FOOD_FALL_SPEED: float = 82.0
const FOOD_LIFETIME: float = 11.0
const COIN_FALL_SPEED: float = 55.0
const COIN_LIFETIME: float = 9.0
const COIN_SWEEP_RADIUS: float = 32.0
const COIN_MAGNET_RADIUS: float = 104.0
const COIN_MAGNET_PULL_SPEED: float = 420.0
const COIN_MAGNET_COLLECT_RADIUS: float = 10.0
const COIN_MAGNET_DURATION: float = 0.35

# Waves and defense
const ENEMY_WAVE_MINIMUM_SECONDS: float = 3.0
const ENEMY_WAVE_BASE_MINIMUM_MULTIPLIER: float = 0.9
const ENEMY_WAVE_RANGE_PADDING: float = 0.8
const ENEMY_WAVE_BASE_MAXIMUM_OFFSET: float = 4.5
const PRE_INVASION_WARNING_TIME: float = 2.0
const DEFENSE_HUNGER_MULTIPLIER: float = 0.5
const SAFE_REWARD_TIME: float = 3.0
const SAFE_REWARD_COIN_MULTIPLIER: float = 1.2

# Helpers
const CLEANER_SNAIL_SPEED: float = 185.0
const CLEANER_SNAIL_COLLECT_RADIUS: float = 28.0
const BUBBLE_SEAHORSE_SPEED: float = 220.0
const BUBBLE_SEAHORSE_ARRIVAL_RADIUS: float = 34.0
const BUBBLE_SEAHORSE_FEED_INTERVAL: float = 6.5
const BUBBLE_SEAHORSE_MAX_FOOD: int = 3
const ELECTRIC_JELLYFISH_ATTACK_INTERVAL: float = 3.6
const ELECTRIC_JELLYFISH_ATTACK_RANGE: float = 720.0

# Combos
const COIN_COMBO_WINDOW: float = 1.6
const COIN_COMBO_MAX: int = 8
const COIN_COMBO_BONUS_PER_STEP: float = 0.05
const COIN_COMBO_MAX_MULTIPLIER: float = 1.4

# Tactical upgrades
const TACTICAL_UPGRADE_MAX_SELECTIONS: int = 2
const TACTICAL_UPGRADE_MAX_OFFERS: int = 2
const TACTICAL_UPGRADE_OFFER_COUNT: int = 3
const TACTICAL_UPGRADE_TIMEOUT: float = 10.0
const TACTICAL_GROWTH_MULTIPLIER: float = 1.2
const TACTICAL_COIN_LIFE_MULTIPLIER: float = 1.35
const TACTICAL_COIN_MAGNET_MULTIPLIER: float = 1.25
const TACTICAL_GUARD_RANGE_MULTIPLIER: float = 1.25
const TACTICAL_GUARD_COOLDOWN_MULTIPLIER: float = 0.8


static func enemy_hp(enemy_type: String) -> int:
	return int(_ENEMY_HP_BY_TYPE.get(enemy_type, _ENEMY_HP_BY_TYPE["normal"]))


static func enemy_speed(enemy_type: String) -> float:
	return float(_ENEMY_SPEED_BY_TYPE.get(enemy_type, _ENEMY_SPEED_BY_TYPE["normal"]))


static func enemy_reward(enemy_type: String) -> int:
	return int(_ENEMY_REWARD_BY_TYPE.get(enemy_type, _ENEMY_REWARD_BY_TYPE["normal"]))
