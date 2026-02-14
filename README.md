# RO Survivor - Ragnarok Online Themed Survivor.io Clone

A complete, playable Survivor.io-style game with Ragnarok Online theming made for Godot 4.2+

## 🎮 Game Features

- **Auto-attacking weapons**: Fireball and Lightning spells that target enemies automatically
- **Animated sprites**: Idle and walk animations for all characters (support for sprite sheets!)
- **HP bars below characters**: Color-coded health bars (green/yellow/red) for player and enemies
- **Floating damage numbers**: RO-style damage numbers (yellow for damage dealt, red for damage taken)
- **Enemy waves**: Poring and Lunatic enemies that spawn continuously with increasing difficulty
- **Level up system**: Gain experience from enemies and choose upgrades on level up
- **Pickup system**: Collect experience gems and health potions
- **HUD**: Health bar, experience bar, level display, and timer
- **Game over screen**: Shows your survival time and level reached

## 🚀 How to Run

1. Download and install [Godot 4.6+](https://godotengine.org/)
2. Open Godot
3. Click "Import" and select the `project.godot` file
4. Press F5 or click "Run Project"

## 🎨 Customizing Sprites

All sprites are located in the `sprites/` folder. The game now supports **animated sprites**!

### Single Frame Sprites (Simple - Currently Used)
Replace these PNG files with your own art:
- `player.png` (32x32) - Your main character (default: blue swordsman)
- `poring.png` (32x32) - Slime enemy
- `lunatic.png` (32x32) - Rabbit enemy

### Animated Sprite Sheets (Advanced - Example Included)
For animations, use these sprite sheets:
- `player_idle.png` (64x32 - 2 frames) - Idle breathing animation
- `player_walk.png` (128x32 - 4 frames) - Walking animation
- `poring_idle.png` (64x32 - 2 frames) - Bouncing animation
- `poring_walk.png` (96x32 - 3 frames) - Moving animation
- `lunatic_idle.png` (64x32 - 2 frames) - Ear twitching
- `lunatic_walk.png` (128x32 - 4 frames) - Hopping animation

**See ANIMATION_GUIDE.md for detailed instructions on adding your own animations!**

### Projectiles & Items
- `fireball.png` (16x16) - Fireball projectile
- `exp_gem.png` (16x16) - Experience gem pickup
- `health_potion.png` (16x16) - Health potion pickup

**Important**: Keep the same filenames and dimensions for best results!

## 🎯 Controls

- **WASD** or **Arrow Keys** - Move your character
- The game auto-attacks enemies
- Experience gems and health potions are auto-collected when nearby

## 📁 Project Structure

```
ro_survivor/
├── project.godot          # Main project file
├── scenes/
│   ├── main.tscn         # Main game scene
│   ├── player.tscn       # Player character
│   ├── enemies/          # Enemy scenes
│   ├── weapons/          # Weapon scenes
│   ├── projectiles/      # Projectile scenes
│   ├── pickups/          # Pickup item scenes
│   └── ui/               # UI screens
├── scripts/
│   ├── player.gd         # Player controller
│   ├── enemy.gd          # Enemy AI
│   ├── enemy_spawner.gd  # Enemy spawning system
│   ├── game_manager.gd   # Game state management
│   ├── projectile.gd     # Projectile behavior
│   ├── weapons/          # Weapon scripts
│   ├── pickups/          # Pickup scripts
│   └── ui/               # UI scripts
└── sprites/              # All game sprites (REPLACE THESE!)
```

## 🛠️ Adding More Content

### Adding a New Enemy

1. Create a new scene in `scenes/enemies/`
2. Use the existing enemy scenes as templates
3. Adjust stats in the scene properties:
   - `speed` - Movement speed
   - `max_health` - Health points
   - `exp_value` - Experience given on death
   - `contact_damage` - Damage dealt to player

4. Add to enemy spawner in `scripts/enemy_spawner.gd`

### Adding a New Weapon

1. Create a new script in `scripts/weapons/`
2. Create a new scene in `scenes/weapons/`
3. Add the weapon name to the upgrade system in `scripts/ui/upgrade_screen.gd`
4. Implement the `upgrade()` function for weapon progression

### Adjusting Difficulty

Edit these values in their respective scripts:

- **Player stats**: `scripts/player.gd` (speed, health, damage)
- **Enemy stats**: Enemy scene files in `scenes/enemies/`
- **Spawn rate**: `scripts/enemy_spawner.gd` (spawn_interval)
- **Difficulty scaling**: `scripts/enemy_spawner.gd` (difficulty_multiplier calculation)

## 🎲 Upgrade System

The game includes these upgrade types:

1. **New Weapons** - Unlock Lightning spell
2. **Weapon Upgrades** - Improve existing weapons (damage, fire rate, projectiles)
3. **Stat Upgrades**:
   - Max Health +20
   - Speed +15
   - Damage +5
   - Pickup Range +20

## 💡 Tips for Development

- The game uses Godot's built-in physics system
- Collision layers are set up for proper interaction
- All placeholder sprites are simple colored shapes - perfect for replacement!
- The code is well-commented and modular
- UI uses Godot's Control nodes for easy customization

## 🐛 Known Limitations

- Currently 2 enemy types (Poring and Lunatic)
- Currently 2 weapon types (Fireball and Lightning)
- No sound effects or music (add in `audio/` folder)
- No particle effects (can add using Godot's particle system)
- Simple graphics (intentionally - for you to customize!)

## 📝 License

This is a template project for learning and game development. Feel free to use and modify as needed!

## 🎉 Have Fun!

This is a fully functional game ready to play. Just replace the sprites with your Ragnarok Online themed art and you're good to go!

For questions about Godot or game development, check out the [Godot Documentation](https://docs.godotengine.org/).
