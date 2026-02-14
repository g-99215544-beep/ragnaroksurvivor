# 🎬 ANIMATION GUIDE - Adding Sprite Animations

## 📊 Current Animation Setup

The game now supports **animated sprites** with separate idle and walk animations!

### Animation States

Each character has 2 animation states:
1. **idle** - Plays when not moving (standing still)
2. **walk** - Plays when moving (any direction)

## 🎨 How to Add Your Own Animation Frames

### Option 1: Using Godot Editor (Recommended)

1. **Open Godot** and load the project
2. **Open a character scene** (e.g., `scenes/player.tscn`)
3. **Click on the AnimatedSprite2D node** in the scene tree
4. **In the Inspector**, click on "Sprite Frames" 
5. **This opens the SpriteFrames panel** at the bottom

#### Adding Frames:
1. Select "idle" or "walk" animation
2. Click the "Add frames from sprite sheet" button (grid icon)
3. Select your sprite sheet image
4. Set the grid size (e.g., 32x32 for player)
5. Select which frames to add
6. Adjust FPS (speed) as needed

### Option 2: Sprite Sheet Setup

**Create your sprite sheets with this layout:**

#### Player Sprite Sheet Example:
```
player_idle.png (64x32 - 2 frames of 32x32)
[Frame 1] [Frame 2]

player_walk.png (128x32 - 4 frames of 32x32)  
[Frame 1] [Frame 2] [Frame 3] [Frame 4]
```

#### Enemy Sprite Sheet Example:
```
poring_idle.png (64x32 - 2 frames)
poring_walk.png (96x32 - 3 frames)
```

### Option 3: Individual Frame Files

You can also use separate files:
```
sprites/player/
  ├── idle_1.png
  ├── idle_2.png
  ├── walk_1.png
  ├── walk_2.png
  ├── walk_3.png
  └── walk_4.png
```

## 🎯 Recommended Animation Frame Counts

### Player Character
- **Idle**: 2-4 frames (breathing animation)
- **Walk**: 4-8 frames (walking cycle)
- **FPS**: 6-10 for smooth animation

### Enemies
- **Poring (slime)**: 
  - Idle: 2-3 frames (bouncing)
  - Walk: 3-4 frames
  - FPS: 4-6 (slower, jiggly movement)

- **Lunatic (rabbit)**:
  - Idle: 2-4 frames (ear twitching)
  - Walk: 4-6 frames (hopping)
  - FPS: 6-8 (faster, energetic)

## 🔧 Adjusting Animation Speed

In Godot Editor:
1. Select the AnimatedSprite2D node
2. Open SpriteFrames panel
3. Select the animation (idle/walk)
4. Adjust the "Speed (FPS)" value
   - Lower = Slower (3-5 FPS)
   - Medium = Normal (6-8 FPS)
   - Higher = Faster (10+ FPS)

Or edit the scene file directly:
```gdscript
"speed": 8.0  # Change this number
```

## 📐 Frame Dimensions

**Keep these sizes for best results:**

| Sprite Type | Size | Notes |
|-------------|------|-------|
| Player | 32x32 | Each animation frame |
| Poring | 32x32 | Slime enemy |
| Lunatic | 32x32 | Rabbit enemy |
| Fireball | 16x16 | Can add rotation anim |
| Items | 16x16 | Can add sparkle anim |

## 🎨 Creating RO-Style Animations

### For Player (Swordsman/Mage):

**Idle Animation (2-4 frames):**
- Frame 1: Normal stance
- Frame 2: Slight breathing motion (chest up/down)
- Frame 3: Return to normal
- Frame 4: (Optional) Weapon slight movement

**Walk Animation (4 frames minimum):**
- Frame 1: Left foot forward
- Frame 2: Passing position
- Frame 3: Right foot forward  
- Frame 4: Passing position
- Loop back to Frame 1

### For Poring (Slime):

**Idle (2-3 frames):**
- Frame 1: Round shape
- Frame 2: Slightly squished (bouncing down)
- Frame 3: Return to round

**Walk (3-4 frames):**
- Frame 1: Stretched forward
- Frame 2: Compressed
- Frame 3: Stretched forward (opposite)
- Frame 4: Normal

### For Lunatic (Rabbit):

**Idle (2-4 frames):**
- Frame 1: Sitting
- Frame 2: Ears twitch up
- Frame 3: Ears normal
- Frame 4: Slight hop

**Walk (4-6 frames):**
- Frame 1: Crouch
- Frame 2: Jump up
- Frame 3: Air
- Frame 4: Landing
- Frame 5: Crouch again
- Frame 6: Repeat

## 💥 Damage Numbers

The game now shows **floating damage numbers** like Ragnarok Online!

### Damage Number Colors:
- 🟡 **Yellow/Orange** - Damage YOU deal to enemies
- 🔴 **Red** - Damage YOU take from enemies

### Damage Number Features:
- Floats upward with slight horizontal drift
- Fades out after 1 second
- Has black outline for visibility
- Scales up then down (pop effect)
- Random position variance (like RO)

## 🎮 Testing Your Animations

1. Import your frames into the SpriteFrames
2. Press F5 to run the game
3. Check animations:
   - Stand still = Should play idle
   - Move around = Should play walk
   - Direction changes = Sprite should flip
   - Take damage = Red numbers appear
   - Deal damage = Yellow numbers appear

## 🔄 Quick Animation Workflow

1. **Create your sprite sheets** (Photoshop, Aseprite, etc.)
2. **Export as PNG** with transparency
3. **Place in sprites/ folder**
4. **Open in Godot**
5. **Add to SpriteFrames** resource
6. **Adjust speed** to look good
7. **Test in game** (F5)
8. **Tweak and repeat!**

## 📝 Tips for Good Animations

✅ **Keep frame count low** - 4-8 frames is plenty
✅ **Consistent timing** - Use same FPS for similar characters
✅ **Smooth loops** - First and last frame should connect
✅ **Anticipation** - Add windup before big movements
✅ **Squash & stretch** - Makes movement feel alive
✅ **Reference RO sprites** - Look at actual RO game for inspiration

## 🎯 Advanced: Adding More Animations

Want to add attack or death animations? Edit the scripts:

```gdscript
# In player.gd or enemy.gd
func play_attack_animation():
    if $AnimatedSprite2D:
        $AnimatedSprite2D.play("attack")
        await $AnimatedSprite2D.animation_finished
        $AnimatedSprite2D.play("idle")
```

Then add the "attack" animation to SpriteFrames!

## 🐛 Troubleshooting

**Animation not playing?**
- Check if AnimatedSprite2D exists in scene
- Verify animation names match ("idle", "walk")
- Check if frames are added to SpriteFrames

**Animation too fast/slow?**
- Adjust FPS in SpriteFrames panel
- Typical range: 4-10 FPS

**Sprite not flipping?**
- Check if `flip_h` is being set in script
- Look at update_animation() function

**Damage numbers not showing?**
- Check if damage_number.tscn exists
- Verify the scene is being loaded in scripts

---

## 🎉 You're Ready!

The animation system is fully functional. Just add your sprite frames and watch your RO-themed game come to life! 

**Pro tip**: Start with simple 2-frame animations, then add more frames as you refine the art!
