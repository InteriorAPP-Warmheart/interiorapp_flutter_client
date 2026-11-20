WAPLL mascot PNG assets

- All images are individual 320 x 320 px RGBA PNG files with transparent backgrounds.
- Character size and bottom alignment are normalized across frames for easier overlay animation.
- Look-around frames: 02_look_left.png -> 03_look_front.png -> 04_look_right.png.
- Running loop frames: 07_run_01.png -> 08_run_02.png -> 09_run_03.png -> 10_run_04.png, then repeat.
- Seated happy loop: 05_happy_sit_loop.png.
- Relief transition: 11_relief_sit.png -> 12_happy_transition.png, then use the seated happy loop if desired.

Flutter example:
Image.asset('assets/mascot/01_fall.png', fit: BoxFit.contain)

These are extracted/raster PNG sprite assets, not a Rive or Lottie animation file. Flutter should control frame timing and the mascot overlay position.
