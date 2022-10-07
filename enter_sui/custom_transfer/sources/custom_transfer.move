module custom_transfer::my_module {
    const WRONG_AMOUNT : u64 = 0;

    use sui::object::{UID, new};
    use sui::balance::{Self, Balance, zero};
    use sui::sui::SUI;
    use sui::tx_context::{TxContext, sender};
    use sui::transfer::{transfer, share_object};
    use sui::coin::{Coin, value, into_balance};

    struct GovernmentCapability has key { id : UID}

    struct TitleDeed has key {
        id : UID,
    }

    struct LandRegistry has key {
        id : UID,
        balance : Balance<SUI>,
        fee : u64
    }

    fun init(ctx : &mut TxContext) {
        transfer(GovernmentCapability {
            id : new(ctx)
        }, sender(ctx));

        share_object(LandRegistry {
            id : new(ctx),
            balance : zero<SUI>(),
            fee : 10000
        })
    }

    public entry fun issue_title_deed(
        _ : &GovernmentCapability,
        for : address,
        ctx : &mut TxContext
    ) {
        transfer(TitleDeed{
            id : new(ctx)
        }, for)
    }

    public entry fun transfer_ownership(
        registry : &mut LandRegistry,
        paper : TitleDeed,
        fee : Coin<SUI>,
        to : address
    ) {
        assert!(value(&fee) == registry.fee, WRONG_AMOUNT);

        balance::join(&mut registry.balance, into_balance(fee));
        

        transfer(paper, to)
    }
}