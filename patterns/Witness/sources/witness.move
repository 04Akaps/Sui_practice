module witness::guardian {

    use sui::object::{UID, new};
    use sui::tx_context::{TxContext};
    
    struct Guardian<phantom  T : drop> has key, store {
        id : UID
    }

    public fun create_guardian<T : drop> (
        _witness : T, ctx: &mut TxContext
    ) : Guardian<T> {
        Guardian {id : new(ctx)}
    }
}

module witness::peace_guardian {

    use sui::tx_context::{TxContext, sender};
    use sui::transfer::{Self};

    use 0x0::guardian;

    struct PeaceGuardian has drop {
        power : u64
    }

    fun init(ctx : &mut TxContext){
        transfer::transfer(
            guardian::create_guardian(
            PeaceGuardian{power :3}, ctx), 
        sender(ctx))
    }
}