# Code Review: RO Survivor (Godot 4.6)

A Survivor.io-style game with Ragnarok Online theming. ~973 lines across 16 GDScript files.

## Bugs

### 1. Projectile out-of-bounds check uses world origin, not player position
**File:** `scripts/projectile.gd:25`
```gdscript
if global_position.length() > 2000:
```
`global_position.length()` measures distance from world origin (0,0), not from the player. If the player moves far from origin, projectiles fired nearby will be culled immediately. Should measure distance from the projectile's spawn point or from the player.

### 2. XP signal emits `experience` twice instead of `(gained, total, needed)`
**File:** `scripts/player.gd:112`
```gdscript
experience_gained.emit(experience, experience, experience_to_next_level)
```
The signal is declared as `(exp, total_exp, needed_exp)` but the first two args are both `experience` (current total). The `amount` parameter (XP just gained) is never passed. The HUD uses `current_exp / needed_exp` so it accidentally works, but the signal contract is misleading.

### 3. `damage_number.gd` has fragile setup/ready ordering
**File:** `scripts/ui/damage_number.gd:25`
```gdscript
# setup() sets: modulate = color
# _ready() then sets: modulate.a = 0.0
```
`_ready()` runs after `setup()` when the node is added to the tree. Line 25 resets alpha but preserves RGB only because `setup()` already set the full `modulate`. This works by coincidence.

### 4. Enemy drops ignore `exp_value` export
**File:** `scripts/enemy.gd:80`
```gdscript
exp_gem.exp_value = 1  # Hardcoded, ignores the enemy's @export exp_value
```
The enemy has `@export var exp_value = 1` but `die()` hardcodes the gem to 1 instead of using `self.exp_value`. Lunatics (set to 2 XP in the scene) only drop 1 XP gems.

## Design Issues

### 5. Dual pause state tracking
**Files:** `scripts/game_manager.gd:5,16`, `scripts/ui/upgrade_screen.gd:15`

GameManager has `is_paused` that gates `game_time`, but actual pausing uses `get_tree().paused = true` in upgrade_screen.gd. These two flags can desync.

### 6. Hardcoded absolute node paths
**Files:** `scripts/game_manager.gd:29,34`, `scripts/ui/hud.gd:25`, `scripts/ui/upgrade_screen.gd:122`

Paths like `"/root/Main/UI/UpgradeScreen"` will break silently if the scene tree is restructured. Prefer `@export NodePath` or `get_tree().get_first_node_in_group()`.

### 7. Unused `damage` export on enemy
**File:** `scripts/enemy.gd:6`
```gdscript
@export var damage = 5.0  # Never referenced; contact_damage is used instead
```

### 8. Unused `passive_items` array
**File:** `scripts/player.gd:14`
```gdscript
var passive_items = []  # Never read or written to
```

### 9. Weapon detection by string matching
**File:** `scripts/ui/upgrade_screen.gd:82,91,112`
```gdscript
if weapon.name.to_lower().contains(upgrade.weapon)
```
Relies on node name containing "fireball" or "lightning". If Godot auto-renames duplicate nodes, upgrades silently break. A `weapon_type` property would be more robust.

## Performance Concerns

### 10. `get_nodes_in_group("enemy")` called every weapon fire
**Files:** `scripts/weapons/fireball.gd:25`, `scripts/weapons/lightning.gd:19`

With `max_enemies = 100`, this allocates and iterates a new array every shot. Both weapons fire multiple times per second.

### 11. HP bar updates every frame unconditionally
**Files:** `scripts/ui/hp_bar.gd:40-42`, `scripts/ui/hud.gd:33-34`

Every enemy HP bar + the HUD health bar poll parent health every frame. With 100 enemies that's 100+ `update_health()` calls per frame. Signal-driven updates would be sufficient.

### 12. `load()` called on every damage number spawn
**Files:** `scripts/player.gd:97`, `scripts/enemy.gd:68`
```gdscript
var damage_label = load("res://scenes/ui/damage_number.tscn").instantiate()
```
`load()` is called each time damage is dealt. Should be `preload()` or cached. During intense combat this creates hundreds of nodes per second.

## Minor / Style

### 13. Godot 3 collision API in Godot 4 project
**File:** `scripts/projectile.gd:52-62`

Re-implements `set_collision_layer_bit()` / `set_collision_mask_bit()`. In Godot 4, use the built-in `set_collision_layer_value()` and `set_collision_mask_value()`.

### 14. Redundant collision handlers on projectile
**File:** `scripts/projectile.gd:28-50`

Both `_on_area_entered` and `_on_body_entered` handle enemy collision. The `hit_enemies` array prevents double-damage, but having both is confusing.

### 15. Magic numbers throughout
Damage cooldown `0.5`, gravity `100`, spawn distance `350`, health potion drop rate `0.1`, etc. Consider extracting to exported vars or named constants.

## Summary

| Category | Count |
|----------|-------|
| Bugs | 4 |
| Design issues | 5 |
| Performance | 3 |
| Minor/Style | 3 |

The most impactful bugs to fix are **#1** (projectile cull distance from origin) and **#4** (enemy `exp_value` ignored). The codebase is well-organized with clean separation of concerns and is easy to extend with new weapon/enemy types.
