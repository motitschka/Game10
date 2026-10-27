use std::env;
use std::path::PathBuf;
use std::process::Command;

fn main() {
    println!("cargo::rerun-if-changed=src/libretro/log.c");
    cc::Build::new()
        .file("src/libretro/log.c")
        .warnings(true)
        .compile("game10_core_log");
    if env::var("CARGO_CFG_TARGET_OS").as_deref() == Ok("windows") {
        windows_resources();
    }
}

/// On Windows `game10.exe` carries the app icon and its version, compiled with MinGW's `windres`
/// (`WINDRES` overrides which one). `scripts/release/windows.sh` makes the icon from `data/game10.svg`
/// and passes its path in `GAME10_ICO`.
fn windows_resources() {
    println!("cargo::rerun-if-env-changed=GAME10_ICO");
    println!("cargo::rerun-if-env-changed=WINDRES");
    let out = PathBuf::from(env::var("OUT_DIR").unwrap());
    let version = env::var("CARGO_PKG_VERSION").unwrap();
    let [major, minor, patch] =
        ["MAJOR", "MINOR", "PATCH"].map(|part| env::var(format!("CARGO_PKG_VERSION_{part}")).unwrap());
    let icon = match env::var("GAME10_ICO") {
        Ok(path) => {
            println!("cargo::rerun-if-changed={path}");
            format!("1 ICON \"{}\"\n", path.replace('\\', "/"))
        }
        Err(_) => {
            println!("cargo::warning=GAME10_ICO isn't set, so game10.exe gets no icon");
            String::new()
        }
    };
    let rc = format!(
        r#"{icon}1 VERSIONINFO
FILEVERSION {major},{minor},{patch},0
PRODUCTVERSION {major},{minor},{patch},0
FILEOS 0x40004
FILETYPE 0x1
BEGIN
  BLOCK "StringFileInfo"
  BEGIN
    BLOCK "040904B0"
    BEGIN
      VALUE "CompanyName", "Matei Novotny"
      VALUE "FileDescription", "Game10"
      VALUE "FileVersion", "{version}"
      VALUE "InternalName", "game10"
      VALUE "LegalCopyright", "Copyright (C) 2026 Matei Novotny, GPL-3.0-or-later"
      VALUE "OriginalFilename", "game10.exe"
      VALUE "ProductName", "Game10"
      VALUE "ProductVersion", "{version}"
    END
  END
  BLOCK "VarFileInfo"
  BEGIN
    VALUE "Translation", 0x409, 1200
  END
END
"#
    );
    let (rc_file, object) = (out.join("game10.rc"), out.join("game10-resources.o"));
    std::fs::write(&rc_file, rc).unwrap();
    let windres = env::var("WINDRES").unwrap_or_else(|_| "x86_64-w64-mingw32-windres".into());
    let status = Command::new(&windres)
        .arg("--output-format=coff")
        .arg("--input")
        .arg(&rc_file)
        .arg("--output")
        .arg(&object)
        .status()
        .unwrap_or_else(|e| panic!("can't run {windres}: {e}"));
    assert!(status.success(), "{windres} failed ({status})");
    println!("cargo::rustc-link-arg-bins={}", object.display());
}
