#[no_mangle]
pub extern "C" fn my_func() -> u64 {
    return 41;
}

#[no_mangle]
pub extern "C" fn my_other_func() -> u64 {
    return 42;
}
