# Sound Assets for BrainLand

This directory contains all sound effect files for the BrainLand game.

## Required Sound Files

The following sound files are referenced in the code and should be placed in this directory:

### UI Sound Effects
- `button_click.mp3` - Played when any button is tapped
  - Duration: ~100ms
  - Type: Short, pleasant click sound

### Game Feedback Sounds
- `correct.mp3` - Played when a correct answer is given
  - Duration: ~500ms
  - Type: Cheerful, encouraging sound (e.g., chime, ding)
  
- `incorrect.mp3` - Played when an incorrect answer is given
  - Duration: ~300ms
  - Type: Gentle, non-punitive sound (e.g., soft buzz)

### Achievement Sounds
- `level_complete.mp3` - Played when a level is completed
  - Duration: ~2s
  - Type: Triumphant fanfare
  
- `star.mp3` - Played when a star is earned
  - Duration: ~500ms
  - Type: Sparkle or twinkle sound
  
- `reward.mp3` - Played when a reward is unlocked
  - Duration: ~1s
  - Type: Exciting unlock sound
  
- `chest_open.mp3` - Played when opening a reward chest
  - Duration: ~1.5s
  - Type: Chest opening with anticipation
  
- `celebration.mp3` - Played during celebration animations
  - Duration: ~2s
  - Type: Party/celebration sound with confetti

## Audio Specifications

All audio files should meet these specifications:
- **Format**: MP3
- **Sample Rate**: 44.1 kHz
- **Bit Rate**: 128 kbps (good quality, reasonable file size)
- **Channels**: Stereo
- **Normalization**: Peak normalized to -3dB to prevent clipping
- **File Size**: Keep under 100KB per file when possible

## Child-Friendly Audio Guidelines

When creating or selecting audio:
1. **Encouraging**: Sounds should be positive and motivating
2. **Non-Scary**: Avoid harsh, loud, or startling sounds
3. **Clear**: Sounds should be distinct and recognizable
4. **Age-Appropriate**: Suitable for children aged 5-11
5. **Volume**: Moderate volume levels, not too loud

## Adding Sound Files

To add sound files:
1. Place MP3 files in this directory (`assets/sounds/`)
2. Ensure files are named exactly as listed above
3. Run `flutter pub get` to register the assets
4. The AudioManager will automatically load them

## Development Mode

The AudioManager is configured to gracefully handle missing sound files:
- Missing files will be logged but won't crash the app
- The game will continue to function without sound effects
- Check the console for "Failed to play sound" messages

## Testing Audio

To test audio playback:
1. Add sound files to this directory
2. Run the app on a physical device (emulators may have audio issues)
3. Test with volume up and headphones
4. Verify sounds play at appropriate times
5. Test mute functionality

## For Production

Before releasing the app:
1. ✅ Add all required sound effect files
2. ✅ Test audio playback on both iOS and Android
3. ✅ Ensure files are optimized for mobile
4. ✅ Verify child-friendly audio guidelines are met
5. ✅ Test with different device volumes
6. ✅ Verify mute functionality works correctly

## Current Status

⚠️ **Development Mode**: Placeholder documentation created. Actual audio files need to be added before production release.

## Resources for Audio Assets

Free, child-friendly sound effect resources:
- **Freesound.org**: Community-sourced sound effects (check licenses)
- **Zapsplat.com**: Free sound effects for games
- **Mixkit.co**: Free sound effects and music
- **OpenGameArt.org**: Game-specific audio assets

Remember to check licensing requirements for any audio you use!
