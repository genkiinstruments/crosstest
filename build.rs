use std::env::var;

fn main() {
    let _target = var("TARGET").unwrap();
    let _build_profile = var("PROFILE").unwrap();
    let _target_os = var("CARGO_CFG_TARGET_OS").unwrap();

    cxx_build::bridge("src/lib.rs")
        .flag_if_supported("-std=gnu++17")
        .file("cpp/lib.cpp")
        .compile("lib_cxx");

    println!("cargo:rustc-link-lib=dylib=asound");

    println!("cargo:rerun-if-changed=build.rs");
    println!("cargo:rerun-if-changed=src/lib.rs");
    println!("cargo:rerun-if-changed=cpp");
}
