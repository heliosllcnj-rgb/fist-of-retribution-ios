# Fist of Retribution: Project Zero - phone builds

Builds the iPhone (and soon Android) version on GitHub Actions.

- `game/` - the game itself (characters, stages, menus, sound, scripts)
- `patches/engine.patch` - small changes to the IKEMEN GO engine (picture at the top of a tall screen, portrait)
- `android-wrapper/` - the Android app shell (from Jesuszilla/ikemen-droid) with the same panel
- `ios-wrapper/` - the iPhone app shell (from Jesuszilla/ikemen-ios) with the arcade stick and button panel
- `.github/workflows/build.yml` - the build

Each push to `main` builds `FistOfRetribution-unsigned.ipa` and `FistOfRetribution.apk` and puts them on the Releases page ("Phone builds (latest)"). Install the IPA
it with Sideloadly or AltStore.
