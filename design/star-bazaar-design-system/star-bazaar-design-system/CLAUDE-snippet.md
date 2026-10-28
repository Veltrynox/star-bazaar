## UI design system

The game's UI design system lives in `design/star-bazaar-design-system/`.
Before any UI work (Godot scenes, themes, HUD, panels, notices):
- Read `design/star-bazaar-design-system/README.md` first: voice, exact in-game wording, colours, layout.
- Colours, spacing, radii and type sizes come from `tokens.json`. Use those values; don't invent new ones.
- Component guidelines: `components/<Name>/README.md`. Visual reference: open `screens/SystemView.html` (the game screen) and the other files in `screens/`.
- Icons: `icons/*.svg` (24px grid, 1.5px stroke). Import into Godot as textures and tint with modulate.
- Fonts: Jost (words) and JetBrains Mono (numbers), from Google Fonts.
