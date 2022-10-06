module my_first_package::my_module {

    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    struct Sword has key, store {
        id: UID,
        magic: u64,
        strength: u64,
    }

    struct Forge has key, store { 
        id: UID,
        swords_created: u64,
    }

    fun init(ctx: &mut TxContext) {
        let admin = Forge {
            id: object::new(ctx),
            swords_created: 0,
        };
        // send admin Data to publisher
        transfer::transfer(admin, tx_context::sender(ctx));
    }


    public fun magic(self: &Sword): u64 {
        self.magic
    }

    public fun strength(self: &Sword): u64 {
        self.strength
    }

    public fun swords_created(self: &Forge): u64 {
        self.swords_created
    }

    // part 5: public/ entry functions (introduced later in the tutorial)

    #[test]
    public fun test_sword_create() {
        // create a dummy TxContext for Testing
        let ctx = tx_context::dummy();

        let sword = Sword {
            id : object::new(&mut ctx),
            magic: 42,
            strength : 7,
        };

        // if use this drop option is not necessary and assert code also not necessary
        // let dummy_address = @0xCAFE;
        // transfer::transfer(sword, dummy_address);

        assert!(magic(&sword) == 42 && strength(&sword) == 7, 1);
    }
}