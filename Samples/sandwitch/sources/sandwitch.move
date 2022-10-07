module sandwitch::eat_some {

    use sui::object::{UID, new, delete};
    use sui::sui::SUI;
    use sui::balance::{Self, Balance, zero, join, split};
    use sui::coin::{ Coin,  balance_mut, value, take};

    use sui::tx_context::{TxContext, sender};
    use sui::transfer::{transfer, share_object};

    struct Ham has key{
        id : UID
    }

    struct Bread has key {
        id : UID
    }

    struct Sandwitch has key {
        id : UID
    }

    struct Owner has key {
        id : UID
    }

    struct Grocery has key {
        id : UID,
        profits : Balance<SUI>
    }

    const HAM_PRICE: u64 = 10;
    const BREAD_PRICE: u64 = 2;

    const EInsufficientFunds: u64 = 0;
    const ENoProfits: u64 = 1;

    fun init (ctx : &mut TxContext){
        transfer(Owner {
            id : new(ctx)
        }, sender(ctx));

        share_object(Grocery {
            id : new(ctx),
            profits : zero<SUI>()
        });
    }

    public entry fun buy_ham(
        grocery : &mut Grocery,
        c : &mut Coin<SUI>,
        ctx : &mut TxContext
    ) {
        buy_items(grocery, c, ctx, true);
    }

    public entry fun buy_bread (
        grocery : &mut Grocery,
        c : &mut Coin<SUI>,
        ctx : &mut TxContext
    ){
        buy_items(grocery, c, ctx, false);
    }

    public entry fun make_sandwitch (
        h : Ham,
        b : Bread,
        ctx : &mut TxContext
    ) {
        let Ham {id: h_id} = h;
        let Bread {id: b_id} = b;

        delete(h_id);
        delete(b_id);

        transfer(Sandwitch {
            id : new(ctx)
        }, sender(ctx));
    }

    public fun get_profits(g : &Grocery) : u64 {
        balance::value(&g.profits)
    }

    public entry fun withdraw_profits(_ : &Owner, g : &mut Grocery, ctx : &mut TxContext){
        let amount = balance::value(&g.profits);

        assert!(amount > 0, ENoProfits);

        let coin = take(&mut g.profits, amount, ctx);

        transfer(coin, sender(ctx));
    }

    fun buy_items(
        grocery : &mut Grocery,
        c : &mut Coin<SUI>,
        ctx : &mut TxContext,
        is_ham : bool
    ) {

        // let mut_balance = balance_mut(c);
        // can not write that because c is distributed mutably

        if(is_ham){
            assert!(value(c) == HAM_PRICE , EInsufficientFunds);

            let mut_balance = balance_mut(c);

            let value = split(mut_balance , HAM_PRICE);

            join(&mut grocery.profits, value); 

            transfer(Ham {id : new(ctx)}, sender(ctx))
        }else{
            assert!(value(c) == BREAD_PRICE , EInsufficientFunds);

            let mut_balance = balance_mut(c);

            let value = split(mut_balance, BREAD_PRICE);

            join(&mut grocery.profits, value); 

            transfer(Bread {id : new(ctx)}, sender(ctx))
        }
    }
}