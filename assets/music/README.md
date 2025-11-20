# Background Music for BrainLand

This directory contains all background music tracks for the BrainLand game.

## Required Music Files

The following music files are referenced in the code and should be placed in this directory:

### Main Menu
- `main_menu.mp3` - Background music for the world map/main menu
  - Duration: 2-3 minutes (looping)
  - Style: Upbeat, welcoming, adventurous
  - Tempo: Moderate (100-120 BPM)
  - Mood: Exciting but not overwhelming

### Zone-Specific Music

#### Math Forest
- `math_forest.mp3` - Background music for Math Forest zone
  - Duration: 2-3 minutes (looping)
  - Style: Nature-themed, playful, educational
  - Instruments: Woodwinds, light percussion, xylophone
  - Mood: Curious, encouraging

#### Logic Mountain
- `logic_mountain.mp3` - Background music for Logic Mountain zone
  - Duration: 2-3 minutes (looping)
  - Style: Thoughtful, puzzle-like, mysterious
  - Instruments: Piano, strings, light synth
  - Mood: Contemplative, focused

#### Memory River
- `memory_river.mp3` - Background music for Memory River zone
  - Duration: 2-3 minutes (looping)
  - Style: Flowing, calm, concentration-friendly
  - Instruments: Harp, flute, gentle water sounds
  - Mood: Peaceful, focused

#### Shape Valley
- `shape_valley.mp3` - Background music for Shape Valley zone
  - Duration: 2-3 minutes (looping)
  - Style: Colorful, geometric, rhythmic
  - Instruments: Marimba, bells, light electronic
  - Mood: Playful, creative

## Audio Specifications

All music files should meet these specifications:
- **Format**: MP3
- **Sample Rate**: 44.1 kHz
- **Bit Rate**: 128-192 kbps
- **Channels**: Stereo
- **Normalization**: Peak normalized to -6dB for comfortable listening
- **Loop Points**: Seamless loop (fade in/out or perfect loop)
- **File Size**: Keep under 3MB per file when possible

## Music Design Guidelines

When creating or selecting background music:

### Child-Friendly Criteria
1. **Non-Distracting**: Should support focus, not demand attention
2. **Positive**: Uplifting and encouraging tone
3. **Age-Appropriate**: Suitable for children aged 5-11
4. **Repetition-Friendly**: Pleasant even after many loops
5. **Volume**: Moderate, allowing for concentration

### Technical Requirements
1. **Seamless Looping**: Music should loop without noticeable breaks
2. **Consistent Volume**: No sudden loud or quiet sections
3. **No Lyrics**: Instrumental only to avoid distraction
4. **Tempo Stability**: Consistent tempo throughout

### Zone Differentiation
Each zone should have distinct musical character:
- **Math Forest**: Natural, organic sounds
- **Logic Mountain**: Thoughtful, puzzle-like
- **Memory River**: Calm, flowing
- **Shape Valley**: Geometric, rhythmic

## Implementation Notes

The AudioManager handles music playback with these features:
- **Looping**: Music automatically loops seamlessly
- **Fade Transitions**: Smooth transitions between tracks
- **Volume Control**: Separate volume control from sound effects
- **Mute Support**: Can be muted independently

## Adding Music Files

To add music files:
1. Place MP3 files in this directory (`assets/music/`)
2. Ensure files are named exactly as listed above
3. Run `flutter pub get` to register the assets
4. The AudioManager will automatically load them via the MusicTrack enum

## Development Mode

The AudioManager is configured to gracefully handle missing music files:
- Missing files will be logged but won't crash the app
- The game will continue to function without background music
- Check the console for "Failed to play music" messages

## Testing Music

To test music playback:
1. Add music files to this directory
2. Run the app on a physical device (emulators may have audio issues)
3. Navigate between zones to test different tracks
4. Verify smooth looping
5. Test volume controls and mute functionality
6. Ensure music doesn't interfere with sound effects

## Performance Considerations

- Music files are loaded on-demand, not all at once
- Only one music track plays at a time
- Previous track is stopped before starting a new one
- Memory is managed efficiently by the AudioManager

## For Production

Before releasing the app:
1. ✅ Add all required music files
2. ✅ Test music playback on both iOS and Android
3. ✅ Verify seamless looping on all tracks
4. ✅ Ensure files are optimized for mobile
5. ✅ Test transitions between zones
6. ✅ Verify volume controls work correctly
7. ✅ Test with different device volumes
8. ✅ Ensure music doesn't drain battery excessively

## Current Status

⚠️ **Development Mode**: Placeholder documentation created. Actual music files need to be added before production release.

## Resources for Music Assets

Free, royalty-free music resources:
- **Incompetech.com**: Kevin MacLeod's extensive library (CC BY)
- **FreePD.com**: Public domain music
- **Bensound.com**: Free music for games (check license)
- **Purple Planet Music**: Free music for games and apps
- **OpenGameArt.org**: Game-specific music assets

### Commissioned Music
For unique, professional music:
- Consider hiring a composer for original tracks
- Ensure you have full rights for commercial use
- Request seamless loop versions

Remember to check licensing requirements and attribution needs for any music you use!
