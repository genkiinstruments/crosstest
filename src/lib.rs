pub use ffi::*;

#[cxx::bridge]
mod ffi {
    extern "Rust" {
    }

    unsafe extern "C++" {
        include!("crosstest/cpp/lib.h");

        pub fn foo();
    }
}
