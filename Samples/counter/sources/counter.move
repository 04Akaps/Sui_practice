module counter::counter{

    use sui::object::{UID, new};
    use sui::tx_context::{TxContext, sender};
    use sui::transfer::{transfer};

    const NOT_OWNER : u64 = 0;

    struct Counter has key {
        id : UID,
        owner : address,
        value : u64
    }

    public fun get_owner(c : &Counter) : address{
        c.owner
    }

    public fun get_value (c : &Counter ) : u64 {
        c.value
    }

    public entry fun create(ctx : &mut TxContext) {
        let sender_address = sender(ctx);

        let counter : Counter = Counter {
            id : new(ctx),
            owner : sender_address,
            value : 0
        };

        transfer(counter, sender_address);
    }


    public entry fun increment(c : &mut Counter, ctx : &mut TxContext) {
        check_owner(c, ctx);
        c.value = c.value + 1;
    }

    public entry fun decrease(c : &mut Counter, ctx : &mut TxContext) {
         check_owner(c, ctx);
        c.value = c.value - 1;
    }

    fun check_owner(c : &Counter, ctx : &TxContext){
        assert!(c.owner == sender(ctx), NOT_OWNER);
    }
}