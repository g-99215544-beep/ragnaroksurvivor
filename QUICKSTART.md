# 🎮 QUICK START GUIDE - RO Survivor

## ⚡ Get Playing in 3 Steps

### 1. Import to Godot
- Download and install [Godot 4.6 or newer](https://godotengine.org/download)
- Open Godot Engine
- Click "Import"
- Navigate to and select `project.godot`
- Click "Import & Edit"

### 2. Run the Game
- Press **F5** or click the ▶️ Play button in top-right
- The game will start immediately!

### 3. Play!
- **WASD** or **Arrow Keys** to move
- Survive as long as you can
- Level up and choose upgrades
- Defeat Porings and Lunatics!

---

## 🎨 Replace Sprites (Make it YOUR game!)

1. Open the `sprites/` folder
2. Replace these files with your own art:
   - `player.png` (32x32) - Your character
   - `poring.png` (32x32) - First enemy  
   - `lunatic.png` (32x32) - Second enemy
   - `fireball.png` (16x16) - Projectile
   - `exp_gem.png` (16x16) - Experience pickup
   - `health_potion.png` (16x16) - Health pickup

3. Keep the same filenames and sizes
4. Press F5 to see your art in action!

---

## 🎯 What You Get

✅ **Fully playable game** - no coding needed to play
✅ **2 auto-attacking weapons** - Fireball & Lightning
✅ **2 enemy types** - Poring (slow) & Lunatic (fast)
✅ **Level up system** - Choose upgrades as you level
✅ **Automatic pickups** - Gems and potions fly to you
✅ **Complete UI** - Health bar, XP bar, timer, game over
✅ **Scaling difficulty** - Gets harder over time
✅ **Well-commented code** - Easy to modify

---

## 🔧 Common Issues

**Game won't import?**
- Make sure you have Godot 4.6 or newer (NOT Godot 3.x or older 4.x versions)

**Sprites look wrong?**
- Godot will reimport on first load - this is normal

**Want to change difficulty?**
- Edit numbers in `scripts/player.gd` (line 5-8)
- Edit numbers in `scripts/enemy_spawner.gd` (line 3-5)

---

## 📚 Next Steps

- Read the full README.md for detailed info
- Check the scripts folder for game logic
- Modify stats to balance your game
- Add your own Ragnarok-themed sprites!
- Export your game (Project > Export in Godot)

**Have fun creating!** 🎉
