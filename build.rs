fn main() {
    println!("cargo::rerun-if-changed=src/libretro/log.c");
    cc::Build::new()
        .file("src/libretro/log.c")
        .warnings(true)
        .compile("game10_core_log");
}
