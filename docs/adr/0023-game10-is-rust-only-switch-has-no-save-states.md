# Game10 is written in Rust only, so Switch has no Save States

M9 planned to give Switch every saving feature, with `retro_reset` and Save States written as C++
commits in `swigino/`, suyu's source (ADR 0022). Before any of it was written, the owner decided
that Game10's code is Rust, always (2026-11-23).

**Game10's own code is Rust.** No new C++ (or C) is written for Game10: not in `swigino/`, not as a
patch to another emulator's source. `swigino/` changes only by taking in suyu's releases
(`swigino/SWIGINO.md`); the Game10 changes it already carries stay as they are.

**Switch gets no Save States and no Resume State.** suyu has none, and adding them means new code deep
inside suyu's CPU, kernel, GPU and audio, which is C++. The Pause Menu keeps Save state and Load state
greyed with its note, and no Resume State is written, as ADR 0019 set out.

**Restart game restarts the Core, from Game10.** swigino's `retro_reset` does nothing. Calling
`retro_unload_game` and then `retro_load_game` on the same loaded Core doesn't work either: the call
succeeds, but suyu never draws another frame (the M9 S1 check, 2026-11-23, on `swigino-2` with the
Space NX homebrew). So for swigino Game10 shuts the Core down the way quitting does and loads it
again for the same Game, inside the same Session.

## Consequences

- M9 shrinks to Restart game and Delete save data for one Game, both in Rust, plus its docs.
- ADR 0022's reason "the patch file was about to grow by Save States" no longer applies; swigino
  stays, because it is still the Core Game10 builds and publishes, and it follows suyu's releases.
- swigino's own general fixes are no longer offered upstream as new work (M9's old S5); merging
  suyu's releases continues.
- M11 (PS4) planned a libretro frontend for shadPS4 written as C++ patches (its Q2). That conflicts
  with this decision, so M11 needs the owner's call on another route before it starts.
- M10 and M12 use Cores from the libretro build server as they are, and are unaffected.
