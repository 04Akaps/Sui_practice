module lock::my_module {

    use sui::object::{Self, UID};
    use std::option::{Self, Option};

    const E_LOCK_EMPTY : u64 = 0;
    const E_KEY_MISMATCH : u64 = 1;
    const E_LOCK_IS_FULLE : u64 = 2;


    struct Lock<T :store + key> has key, store{
        id : UID,
        locked: Option<T>
    }
}