extends RefCounted


static func should_fail_without_fish(fish_count: int, money: int, minimum_fish_cost: int, no_fish_timer: float, no_fish_grace_time: float) -> bool:
	if fish_count > 0:
		return false
	return money < minimum_fish_cost or no_fish_timer >= no_fish_grace_time


static func next_no_fish_timer(fish_count: int, no_fish_timer: float, delta: float) -> float:
	if fish_count > 0:
		return 0.0
	return no_fish_timer + delta


static func unlocked_level_after_clear(current_level: int, highest_unlocked_level: int, max_level: int) -> int:
	if current_level < max_level:
		return max(highest_unlocked_level, current_level + 1)
	return highest_unlocked_level


static func should_unlock_cleaner_snail(current_level: int, unlocked_cleaner_snail: bool) -> bool:
	return current_level == 1 and not unlocked_cleaner_snail


static func should_unlock_bubble_seahorse(current_level: int, unlocked_bubble_seahorse: bool) -> bool:
	return current_level == 2 and not unlocked_bubble_seahorse


static func should_unlock_electric_jellyfish(current_level: int, max_level: int, unlocked_electric_jellyfish: bool) -> bool:
	return current_level == max_level and not unlocked_electric_jellyfish


static func should_clear_level(cores: int) -> bool:
	return cores >= 3
