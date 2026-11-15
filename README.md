# Official NASA Realistic 3D Mars & Moon Exploration Game (November 2026)

An elite space exploration web application and 3D simulation game combining **Flutter Web (Dart)** with high-performance **Three.js / WebGL** rendering.

---

## 🚀 Key Features

1. **Standalone High-Performance Three.js / WebGL Scenes (Zero Black Screens)**:
   - **Orbital Mode (`web/orbit_scene.html`)**: Responsive rotating celestial spheres (Mars and Moon) with dynamic wireframe latitude/longitude coordinate grids, atmospheric Fresnel glow, solar lighting with terminator shadows, 4,500+ particle starfield, and pulsing landing beacon markers.
   - **Surface Recon Mode (`web/game_scene.html`)**: Interactive 3D terrain exploration featuring a realistic 6-wheel NASA rover, procedural boulders/rocks, driving kinematics with keyboard (W/A/S/D or Arrow keys) or on-screen touch controls, atmospheric dust fog, and geological spectrometry (Hematite, Water-Ice signatures).
   - **Crater Ice Contour Visualization**: Concentric elevation contour gradient rings at Shackleton Crater (South Pole) reflecting NASA Artemis radar scans.

2. **Clean Modular Flutter Architecture**:
   - `lib/main.dart`: Application entry point with Hive storage and Riverpod `ProviderScope`.
   - `lib/models/planet_mission.dart`: Planet catalogs, landing sites, and live telemetry data models.
   - `lib/providers/game_state_provider.dart`: Riverpod state management and Hive persistence for mission settings.
   - `lib/l10n/app_localizations.dart`: Comprehensive bilingual localization (English & Arabic) with dynamic LTR/RTL layout direction.
   - `lib/widgets/three_js_canvas_widget.dart`: Robust WebGL canvas embedding widget with cross-platform stub/web separation and bidirectional `postMessage` event bus.
   - `lib/widgets/holographic_hud_widget.dart`: Holographic watch HUD telemetry displaying orbital altitude, velocity, atmospheric pressure, surface temperature, radiation flux, life support oxygen levels, and interactive RCS thruster controls.
   - `lib/widgets/landing_site_card.dart`: Landing site inspection card with coordinates, elevation, hazard rating bars, and mission objectives.
   - `lib/screens/main_menu_screen.dart`: Mission launch center with celestial body selector (Mars / Moon).
   - `lib/screens/landing_screen.dart`: Precision landing coordinate targeting with interactive 3D globe lock.
   - `lib/screens/cockpit_screen.dart`: Spacecraft cockpit with canopy viewport framing, throttle slider, electromagnetic radar scanner, and mode switcher (Orbit vs Surface).

---

## 📁 Directory Structure

```text
nasa_space/
├── lib/
│   ├── main.dart                          # App Entrypoint (Hive & Riverpod setup)
│   ├── l10n/
│   │   └── app_localizations.dart         # English & Arabic Localization (RTL/LTR)
│   ├── models/
│   │   └── planet_mission.dart            # Planetary Catalog & Telemetry Models
│   ├── providers/
│   │   └── game_state_provider.dart       # Riverpod Game State & Hive Persistence
│   ├── screens/
│   │   ├── main_menu_screen.dart          # Planetary Selector & Mission Launch
│   │   ├── landing_screen.dart            # Precision Landing Coordinates
│   │   └── cockpit_screen.dart            # Spaceship / Rover Cockpit Simulator
│   └── widgets/
│       ├── holographic_hud_widget.dart    # Holographic Watch HUD Telemetry
│       ├── landing_site_card.dart         # Site Card with Hazard Ratings
│       ├── three_js_canvas_widget.dart    # Universal WebGL Embedding
│       ├── three_js_view_stub.dart        # Non-web Fallback Stub
│       └── three_js_view_web.dart         # Flutter Web IFrame & Event Bus
├── web/
│   ├── index.html                         # Enhanced NASA 2026 Web Bootstrapper
│   ├── orbit_scene.html                   # Standalone Three.js 3D Orbital Scene
│   └── game_scene.html                    # Standalone Three.js 3D Surface Scene
├── pubspec.yaml                           # Flutter Dependencies & Assets
└── README.md
```

---

## 🛠️ How to Run & Build

### Run locally in Chrome:
```bash
flutter run -d chrome
```

### Build production Web release:
```bash
flutter build web
```

### Standalone 3D Scenes:
The files in `web/` (`orbit_scene.html` and `game_scene.html`) are completely self-contained and can also be opened directly in any modern browser without a web server.
