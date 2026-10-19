# Emulators install as Flatpaks; Game10 itself is not a Flatpak

First-run Setup only generates `flatpak install` commands, because Flatpak behaves the same on every distro. Game10 itself is built from source rather than shipped on Flathub, because a sandboxed Game10 would need `flatpak-spawn --host` workarounds to start other Flatpak emulators and to read the Games Root freely.

## Consequences

The owner's DuckStation and Mesen are AppImages (not on Flathub), which is fine because the owner's Config is hand-written and Game10 doesn't use them anyway (see ADR 0008).
