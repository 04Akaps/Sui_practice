module pool::myDefi {

    use sui::object::{UID, new};
    use sui::coin::{Self, Coin};
    use sui::balance::{Self, Supply, Balance, join};
    use sui::sui::SUI;
    use sui::tx_context::{Self, TxContext, sender};
    use sui::transfer::{transfer, share_object};
    use sui::math;

    const EZeroAmount: u64 = 0;
    const EWrongFee: u64 = 1;
    const EReservesEmpty: u64 = 2;
    const EShareEmpty: u64 = 3;
    const EPoolFull: u64 = 4;
    const ENotOwner: u64 = 5;
    const FEE_SCALING: u128 = 10000;

    const MAX_POOL_VALUE: u64 = {
        18446744073709551615 / 10000
    };

    struct LSP<phantom P, phantom T> has drop{}

    struct Pool<phantom P, phantom T> has key {
        id: UID,
        sui: Balance<SUI>,
        token: Balance<T>,
        lsp_supply: Supply<LSP<P, T>>,
        /// Fee Percent is denominated in basis points.
        fee_lp: u64,
        /// Fee Percent Treasury
        fee_treasury: u64,
    }

    struct Treasury <phantom P, phantom T> has key {
        id : UID,
        sui : Balance<SUI>,
        owner : address
    }

    fun init(_: &mut TxContext) {}

    entry fun change_treasury_owner<P,T> (
        treasury : &mut Treasury<P,T>, 
        new_owner : address,
        ctx : &mut TxContext) 
    {
        assert!(sender(ctx) == treasury.owner , ENotOwner);
        treasury.owner = new_owner;
    }

    fun deposit_into_treasury<P,T>(t : &mut Treasury<P,T>, sui : Coin<SUI>){
        join(
            &mut t.sui,
            coin::into_balance(sui)
        );
        // add balance to treasury.sui
        // into_balance -> delete coinObject, then return only Balance<T>
    }

    entry fun withdraw_amount_from_treasury<P,T>(
        t : &mut Treasury<P,T>,
        amount : u64, 
        ctx : &mut TxContext
    ){
        assert!(sender(ctx) == t.owner, ENotOwner);

        let split_balance = balance::split(&mut t.sui, amount);

        transfer(
            coin::from_balance(split_balance, ctx),
            t.owner
        );
    }

    entry fun withdraw_total_from_treasuary<P,T>(
        t : &mut Treasury<P,T>,
        ctx : &mut TxContext
    ){
        assert!(sender(ctx) == t.owner, ENotOwner);

        let total_amount  = balance::value(&t.sui);
        let split_balance = balance::split(&mut t.sui, total_amount);

        transfer(
            coin::from_balance(split_balance, ctx),
            t.owner
        )
    }

    public fun create_pool<P: drop, T> (
        _ :P,
        token : Coin<T>,
        sui : Coin<SUI>,
        fee_lp : u64,
        fee_treasury : u64,
        ctx : &mut TxContext
    ) : Coin<LSP<P,T>> {

        share_object(Treasury<P,T> { 
            id: new(ctx), 
            sui: balance::zero<SUI>(), 
            owner: sender(ctx) 
        });
        
        let sui_amt = coin::value(&sui);
        let tok_amt = coin::value(&token);

        assert!(sui_amt > 0 && tok_amt > 0, EZeroAmount);
        assert!(sui_amt < MAX_POOL_VALUE && tok_amt < MAX_POOL_VALUE, EPoolFull);
        assert!(fee_lp >= 0 && fee_lp < 10000, EWrongFee);
        assert!(fee_treasury >= 0 && fee_lp < 2000, EWrongFee);

        let share = math::sqrt(sui_amt) * math::sqrt(tok_amt);
        let lsp_supply = balance::create_supply(LSP<P, T> {});
        let lsp = balance::increase_supply(&mut lsp_supply, share);

        share_object(Pool {
            id: new(ctx),
            token: coin::into_balance(token),
            sui: coin::into_balance(sui),
            lsp_supply,
            fee_lp,
            fee_treasury
        });

        coin::from_balance(lsp , ctx)
    }

    public fun swap_sui<P, T> (
        pool : &mut Pool<P, T>,
        sui : Coin<SUI>,
        treasury : &mut treasury<P,T>,
        ctx : &mut TxContext
    ) : Coin<T>{
        assert!(coin::value(&sui) > 0 , EZeroAmount);

        let sui_balance  = coin::into_balance(sui);
        let sui_balance_value : u64 = balance::value(&sui_balance);


    }


}