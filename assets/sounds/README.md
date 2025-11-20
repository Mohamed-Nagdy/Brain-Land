# Sound Assets

This directory should contain sound effect files for the BrainLand game.

## Required Sound Files

The following sound files are referenced in the code but not yet implemented:

- `correct.mp3` - Played when a correct answer is given
- `incorrect.mp3` - Played when an incorrect answer is given

## Adding Sound Files

To add sound files:

1. Place MP3 files in this directory
2. Ensure files are named exactly as listed above
3. The AudioService will automatically load them from `assets/sounds/`

## Current Status

The AudioService has been configured to gracefully handle missing sound files during development. The app will continue to function without sound effects, but will log a message when sound files are not found.

## For Production

Before releasing the app, you should:
1. Add actual sound effect files
2. Test audio playback on both iOS and Android
3. Ensure files are optimized for mobile (compressed, appropriate bitrate)
