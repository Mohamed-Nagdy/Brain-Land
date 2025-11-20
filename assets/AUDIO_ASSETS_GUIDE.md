# BrainLand Audio Assets Guide

This document provides a comprehensive guide for implementing audio assets in the BrainLand educational game.

## Overview

BrainLand uses audio to enhance the learning experience through:
- **Background Music**: Zone-specific ambient music
- **Sound Effects**: Immediate feedback for user actions
- **Encouraging Audio**: Positive reinforcement for children

## Directory Structure

```
assets/
├── sounds/          # Sound effects (short audio clips)
│   ├── README.md
│   ├── button_click.mp3
│   ├── correct.mp3
│   ├── incorrect.mp3
│   ├── level_complete.mp3
│   ├── star.mp3
│   ├── reward.mp3
│   ├── chest_open.mp3
│   └── celebration.mp3
└── music/           # Background music (looping tracks)
    ├── README.md
    ├── main_menu.mp3
    ├── math_forest.mp3
    ├── logic_mountain.mp3
    ├── memory_river.mp3
    └── shape_valley.mp3
```

## Audio Implementation Status

### ✅ Completed
- AudioManager singleton class implemented
- Sound effect and music track enums defined
- Volume controls (music and sound effects separate)
- Mute/unmute functionality
- Graceful error handling for missing files
- Asset paths configured in pubspec.yaml

### ⚠️ Pending
- Actual audio files need to be added
- Audio integration in UI components
- Settings screen for audio controls
- Property-based tests for audio feedback

## Quick Start for Developers

### 1. Adding Audio Files

Place your audio files in the appropriate directories:
- Sound effects → `assets/sounds/`
- Background music → `assets/music/`

Ensure filenames match exactly:
- `button_click.mp3`, `correct.mp3`, etc.

### 2. Using AudioManager in Code

```dart
// Get the singleton instance
final audioManager = AudioManager.instance;

// Initialize (call once at app startup)
await audioManager.initialize();

// Play sound effects
await audioManager.playSound(SoundEffect.correctAnswer.path);
await audioManager.playSound(SoundEffect.buttonClick.path);

// Play background music
await audioManager.playMusic(MusicTrack.mathForest.path);

// Control volume
await audioManager.setMusicVolume(0.7);  // 0.0 to 1.0
await audioManager.setSoundVolume(0.8);

// Mute/unmute
await audioManager.mute();
await audioManager.unmute();
await audioManager.toggleMute();

// Stop music
await audioManager.stopMusic();
```

### 3. Integration Points

Audio should be integrated at these key points:

#### UI Interactions
- **Button taps**: `SoundEffect.buttonClick`
- **Navigation**: `SoundEffect.buttonClick`

#### Game Feedback
- **Correct answer**: `SoundEffect.correctAnswer`
- **Incorrect answer**: `SoundEffect.incorrectAnswer`
- **Level complete**: `SoundEffect.levelComplete`
- **Star earned**: `SoundEffect.starEarned`

#### Rewards & Achievements
- **Reward unlock**: `SoundEffect.rewardUnlock`
- **Chest open**: `SoundEffect.chestOpen`
- **Celebration**: `SoundEffect.celebration`

#### Background Music
- **World map**: `MusicTrack.mainMenu`
- **Math Forest**: `MusicTrack.mathForest`
- **Logic Mountain**: `MusicTrack.logicMountain`
- **Memory River**: `MusicTrack.memoryRiver`
- **Shape Valley**: `MusicTrack.shapeValley`

## Audio Design Principles

### For Children (Ages 5-11)

1. **Encouraging, Not Punitive**
   - Correct sounds: Cheerful, rewarding
   - Incorrect sounds: Gentle, non-judgmental
   - Never use harsh or scary sounds

2. **Clear and Distinct**
   - Each sound should be easily recognizable
   - Different actions should have different sounds
   - Avoid similar-sounding effects

3. **Volume Appropriate**
   - Not too loud or startling
   - Comfortable for extended play
   - Balanced with background music

4. **Repetition-Friendly**
   - Sounds will be heard many times
   - Should remain pleasant after repetition
   - Avoid annoying or grating sounds

### Technical Guidelines

1. **File Format**: MP3 (widely supported)
2. **Sample Rate**: 44.1 kHz
3. **Bit Rate**: 
   - Sound effects: 128 kbps
   - Music: 128-192 kbps
4. **Duration**:
   - Sound effects: 100ms - 2s
   - Music: 2-3 minutes (looping)
5. **File Size**:
   - Sound effects: < 100KB
   - Music: < 3MB

## Testing Audio

### Manual Testing Checklist

- [ ] All sound effects play correctly
- [ ] Background music loops seamlessly
- [ ] Volume controls work (music and sound effects)
- [ ] Mute functionality works
- [ ] Audio plays on iOS devices
- [ ] Audio plays on Android devices
- [ ] No audio crashes or errors
- [ ] Audio doesn't interfere with other apps
- [ ] Battery usage is reasonable

### Automated Testing

Property-based test for immediate feedback:
```dart
// **Feature: brainland-game, Property 5: Answer feedback is immediate**
test('answer feedback includes audio', () {
  // Test that audio plays within acceptable timeframe
  // Validates: Requirements 2.2, 10.2
});
```

## Troubleshooting

### Common Issues

**Audio not playing:**
- Check file exists in correct directory
- Verify filename matches exactly (case-sensitive)
- Ensure `flutter pub get` was run after adding files
- Test on physical device (emulators may have issues)

**Audio too quiet/loud:**
- Adjust volume in AudioManager
- Check device volume settings
- Verify audio file normalization

**Music not looping:**
- AudioManager sets loop mode automatically
- Check for errors in console logs

**Performance issues:**
- Ensure audio files are compressed
- Check file sizes (should be < 3MB for music)
- Monitor memory usage

## Resources

### Free Audio Resources
- **Freesound.org**: Sound effects
- **Incompetech.com**: Background music
- **Zapsplat.com**: Game sound effects
- **OpenGameArt.org**: Game audio

### Audio Editing Tools
- **Audacity**: Free, open-source audio editor
- **GarageBand**: Mac/iOS audio creation
- **FL Studio**: Professional DAW

### Licensing
Always check licensing requirements:
- Commercial use allowed?
- Attribution required?
- Modifications allowed?
- Redistribution terms?

## Production Checklist

Before release:
- [ ] All audio files added and tested
- [ ] Audio quality verified
- [ ] File sizes optimized
- [ ] Licensing documented
- [ ] Attribution added (if required)
- [ ] iOS audio tested
- [ ] Android audio tested
- [ ] Volume controls tested
- [ ] Mute functionality tested
- [ ] Battery impact assessed
- [ ] Child-safety verified

## Support

For questions or issues:
1. Check console logs for error messages
2. Verify file paths and names
3. Test on physical device
4. Review AudioManager implementation
5. Check pubspec.yaml asset configuration

---

**Last Updated**: November 20, 2024
**Status**: Development - Audio files pending
