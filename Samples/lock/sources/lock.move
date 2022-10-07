module lock::my_lock {

    use sui::object::{ borrow_id , UID, ID, new, uid_to_inner};
    use sui::tx_context::{TxContext, sender};
    use sui::transfer::{Self};

    use std::option::{ fill, extract, is_some, is_none, Option, some};

    const LOCK_IS_EMPTY : u64 = 0;
    const KEY_IS_MISMATCH : u64 =1;
    const LOCK_IS_FULL : u64 = 2;

    struct Lock<T :store + key> has store,key {
        id : UID,
        locked : Option<T> // vector<T> variable
    }

    struct Key<phantom T: store + key> has key, store {
        id: UID,
        for: ID,
    }

    public fun get_key<T: store + key> (k : &Key<T>) : ID {
        k.for
    }

    public entry fun create<T : store+ key>(obj : T, ctx : &mut TxContext) {
        let id = new(ctx); // return UID type
        let for = uid_to_inner(&id); // return ID type

        transfer::share_object(Lock<T> {
            id,
            locked : some(obj)
        });

        transfer::transfer(Key<T> {
            id : new(ctx),
            for : for
        }, sender(ctx));
    }

    public entry fun lock<T :store + key> (
        obj : T,
        lock : &mut Lock<T>,
        key : &Key<T>
    ) { 
        assert!(is_none(&lock.locked), LOCK_IS_FULL);
        assert!(&key.for == borrow_id(lock), KEY_IS_MISMATCH);

        fill(&mut lock.locked, obj);
    }

    public fun unlock<T :store + key> (
        lock : &mut Lock<T>,
        key : &Key<T>,
    ) : T {
        assert!(is_some(&lock.locked), LOCK_IS_EMPTY);
        assert!(&key.for == borrow_id(lock), KEY_IS_MISMATCH);

        extract(&mut lock.locked)
    }
}