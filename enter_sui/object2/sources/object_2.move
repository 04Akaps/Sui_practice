module object2::my_module {
    use sui::object::{Self, UID};
    use sui::transfer::{transfer};
    use sui::tx_context::{TxContext, sender};

    struct Object has key{
        id : UID,
        custom_field : u64,
        child_obj : ChildObject,
        nested_obj : AnotherObject,
    }


    struct ChildObject has store {
        a_filed : bool
    }

    struct AnotherObject has store {
        id : UID
    }

    public fun write_field(field : &mut Object, v : u64) {
        if(some_conditional_logic(v)){
            field.custom_field = v;
        }
    }

    public fun transfer_to(field: Object, receipient: address, v: u64){
        assert!(some_conditional_logic(v), 0);
        transfer(field, receipient);
    }

    public fun read_field(o: &Object): u64 {
        o.custom_field
    }

    public fun create(tx : &mut TxContext) : Object {
        Object {
            id : object::new(tx),
            custom_field : 0,
            child_obj : ChildObject{a_filed : false},
            nested_obj : AnotherObject{id : object::new(tx)}
        }
    }

    public entry fun main(
        to_write : &mut Object,
        to_consume : Object,
        int_input : u64,
        receipient : address,
        ctx : &mut TxContext
    )  {
        write_field(to_write, 3);
        transfer_to(to_consume, receipient, int_input);

        transfer(create(ctx), sender(ctx));
    }

    fun some_conditional_logic(v : u64): bool {
        if(v == 3){
            true
        }else{
            false
        }
    }


}