module pool::myDefi {

    use sui::object::{UID, new};
    use sui::coin::{Self, Coin};
    use sui::balance::{Self, Supply, Balance, join};
    use sui::sui::SUI;
    use sui::tx_context::{ TxContext, sender};
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

    entry fun change_treasury_owner<P,T> 
        treasury : &mut Treasury<P,T>, 
        new_owner : address,
        ctx : &mut TxContext) 
    {
        // Owner를 변경
        // createPool에서 Treasury생성이 되는데 이를 변경
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
        // return  -> Balance Struct with value = amount

        transfer(
            coin::from_balance(split_balance, ctx),
            // return Coin Struct with Balance
            t.owner
        );
        // Pool에 쌓여있는 Coin을 Balace로 바꾸고, Coin으로 만들어서 전송
    }

    entry fun withdraw_total_from_treasuary<P,T>(
        t : &mut Treasury<P,T>,
        ctx : &mut TxContext
    ){
        assert!(sender(ctx) == t.owner, ENotOwner);

        let total_amount  = balance::value(&t.sui);
        // return total value : u64

        let split_balance = balance::split(&mut t.sui, total_amount);

        transfer(
            coin::from_balance(split_balance, ctx),
            t.owner
        )
        // Pool에 쌓여있는 Coin을 Balace로 바꾸고, Coin으로 만들어서 전송 다

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
        // transaction sender will be a Treasury Owner
        
        let sui_amt : u64 = coin::value(&sui);
        let tok_amt : u64 = coin::value(&token);
        // get Coin Balance -> u64

        assert!(sui_amt > 0 && tok_amt > 0, EZeroAmount);
        assert!(sui_amt < MAX_POOL_VALUE && tok_amt < MAX_POOL_VALUE, EPoolFull);
        assert!(fee_lp >= 0 && fee_lp < 10000, EWrongFee);
        assert!(fee_treasury >= 0 && fee_lp < 2000, EWrongFee);
        // basic value check

        let share = math::sqrt(sui_amt) * math::sqrt(tok_amt);
        let lsp_supply = balance::create_supply(LSP<P, T> {});
        // create Supply struct -> value zero
        let lsp = balance::increase_supply(&mut lsp_supply, share);
        // increate supply  and return Balance

        // Supply Struct used for minting or burning
        // is same struct Balance

        share_object(Pool {
            id: new(ctx),
            token: coin::into_balance(token),
            sui: coin::into_balance(sui),
            lsp_supply,
            fee_lp,
            fee_treasury
        });

        coin::from_balance(lsp , ctx)
        // return New Coin
    }

    entry fun swap_sui_<P,T> (
        pool : &mut Pool<P,T>,
        sui : Coin<SUI>,
        treasury : &mut Treasury<P,T>,
        ctx : &mut TxContext
    ) {
        transfer(
            swap_sui(pool, sui,treasury, ctx),
            sender(ctx)
        )
    }

    public fun swap_sui<P, T> (
        pool : &mut Pool<P, T>,
        sui : Coin<SUI>,
        treasury : &mut Treasury<P,T>,
        ctx : &mut TxContext
    ) : Coin<T>{
        assert!(coin::value(&sui) > 0 , EZeroAmount);

        let sui_balance  = coin::into_balance(sui); 
        let sui_balance_value : u64 = balance::value(&sui_balance);
        let sui_balance_to_treasury = balance::split(&mut sui_balance, ((sui_balance_value * pool.fee_treasury as u128) / FEE_SCALING as u64));
        // return Balance type -> sui_balance.value - value

        deposit_into_treasury(treasury, coin::from_balance(sui_balance_to_treasury, ctx));

        let (sui_reserve, token_reserve, _) = get_amounts(pool);

        assert!(sui_reserve > 0 && token_reserve > 0 , EReservesEmpty);

        let output_amount = get_input_price (
            balance::value(&sui_balance),
            sui_reserve,
            token_reserve,
            pool.fee_lp
        );

        balance::join(&mut pool.sui, sui_balance);
        coin::take(&mut pool.token, output_amount ,ctx)
        // return new coin with pool.token - output_amount
    }

    entry fun swap_token_<P, T> {
        pool : &mut Pool<P, T>,
        token : Coin<T>,
        treasury : &mut Treasury<P,T>,
        ctx : &mut TxContext
    } {
        transfer(
            swap_token(pool,token,treasury,ctx),
            sender(ctx)
        )
    }

    public fun swap_token(
        pool : &mut Pool<P, T>,
        token : Coin<T>,
        treasury : &mut Treasury<P,T>,
        ctx : &mut TxContext
    ) {
        assert!(coin::value(&token) > 0 , EZeroAmount);

        let tok_balance = coin::into_balance(token);
        // return Balance
        let (sui_reserve, token_reserve , _) = get_amounts(pool);
        // return : u64

        assert!(sui_reserve >0 && token_reserve > 0, EReservesEmpty);

        let output_amount = get_input_price(
            balance::value(&tok_balance),
            token_reserve,
            sui_reserve,
            pool.fee_lp
        );

        join(&mut pool.token, tok_balance);

        let output_to_treasury = ((output_amount * pool.fee_treasury as u128) / FEE_SCALING as u64);

        deposit_into_treasury(treasury, coin::take(&mut pool.sui, output_to_treasury, ctx));

        coin::take(&mut pool.sui, output_amount, output_to_treasury, ctx)
    }

    entry fun add_liquidity_<P, T> (
        pool : &mut Pool<P,T>,
        sui: Coin<SUI>,
        token : Coin<T>,
        ctx : &mut TxContext
    ) {
        transfer(
            add_liquidity(pool, sui, token, ctx),
            sender(ctx)
        );
    }

    public fun add_liquidity<P, T> (
        pool : &mut Pool<P,T>,
        sui: Coin<SUI>,
        token : Coin<T>,
        ctx : &mut TxContext
    ) : Coin<LSP<P, T>> {
        assert!(coin::value(&sui) > 0, EZeroAmount);
        assert!(coin::value(&token) > 0, EZeroAmount);

        let sui_balance = coin::into_balance(sui);
        let token_balance = coin::into_balance(token);

        let (sui_amount, tok_amount, lsp_supply) = get_amounts(pool);

        let sui_added : u64 = balance::value(&sui_balance);
        let tok_added : u64 = balance::value(&tok_balance);

        let share_minted = math::min(
            (sui_added * lsp_supply) / sui_amount,
            (tok_added * lsp_supply) / tok_amount
        );

        let sui_amt : u64 = balance::join(&mut pool.sui, sui_balance);
        let tok_amt : u64 = balance::join(&mut pool.token, tok_balance);

        assert!(sui_amt < MAX_POOL_VALUE, EPoolFull);   
        assert!(tok_amt < MAX_POOL_VALUE, EPoolFull);

        let balance = balance::increase_supply(&mut pool.lsp_supply, share_minted);
        coin::from_balance(balance, ctx)
    }

    entry fun remove_liquidity_<P,T> (
        pool : &mut Pool<P,T>,
        lsp : Coin<LSP<P, T>>,
        ctx : &mut TxContext
    ) {
        let (sui, token) = remove_liquidity(pool, lsp, ctx);

        let sender : address = sender(ctx);

        transfer(sui, sender);
        transfer(token,sender);
    }

    public fun remove_liquidity<P,T> (
        pool : &mut Pool<P,T>,
        lsp : Coin<LSP<P, T>>,
        ctx : &mut TxContext
    ) : (Coin<SUI>, Coin<T>) {
        let lsp_amount = coin::value(&lsp);

        assert!(lsp_amount > 0, EZeroAmount);

        let (sui_amt, tok,_amt, lsp_supply) = get_amounts(pool);

        let sui_removed = (sui_amt * lsp_amount) / lsp_supply;
        let tok_removed = (tok_amt * lsp_amount) / lsp_supply;

        balance::decrease_supply(&mut pool.lsp_supply, coin::into_balance(lsp));

        (
            coin::take(&mut pool.sui, sui_removed, ctx),
            coin::take(&mut pool.token, tok_removed, ctx)
        )
    }

    public fun get_amounts<P, T>(pool : &Pool<P, T>) : (u64, u64, u64) {
        (
            balance::value(&pool.sui),
            balance::value(&pool.token),
            balance::supply_value(&pool.lsp_supply)
        )
    }

    public fun get_input_price(
        input_amount : u64,
        input_reserve : u64,
        output_reserve : u64,
        fee_lp : u64
    ) : u64 {
        let (
            input_amount,
            input_reserve,
            output_reserve,
            fee_lp
        ) = (
            (input_amount as u128),
            (input_reserve  as u128),
            (output_reserve  as u128),
            (fee_lp  as u128)
        );


        let input_amount_with_fee = input_amount * (FEE_SCALING - fee_lp);
        let numerator  = input_amount_with_fee * output_reserve;
        let denominator = (input_reserve * FEE_SCALING) + input_amount_with_fee;

        (numerator / denominator as u64)
    }

}


module pool::realDefi {

    use myDefi::myDefi;
    use sui::sui::SUI;
    use sui::tx_context::{Self, TxContext};
    use sui::balance::{Self, Supply};
    use sui::object::{Self, UID};
    use sui::coin::{Self, Coin};
    use sui::transfer;


    struct RealDefi has drop {}

    struct TreasuryCap has key, store {
        id : UID,
        supply : Supply<RealDefi>
    }

    entry fun create_pool<T>(
        token : Coin<T>,
        sui : Coin<SUI>,
        fee_lp : u64,
        fee_treasury : u64,
        _treasury_cap : &TreasuryCap,
        ctx : &mut TxContext
    ) {
        let lsp = myDefi::create_pool(RealDefi{}, token,sui,fee_lp, fee_treasury, ctx);
        transfer::transfer(lsp , tx_context::sender(ctx));
    }

    fun init(ctx : &mut TxContext){
        let sender = tx_context::sender(ctx);

        let treasury_cap = TreasuryCap {
            id : object::new(ctx),
            supply : balance::create_supply(RealDefi {})
        };

        let total_supply = balance::increase_supply<RealDefi>(&mut treasury_cap.supply, 1000000000);
        let coin_total_supply = coin::from_balance(total_supply, ctx);

        transfer::transfer(coin_total_supply, sender);
        transfer::transfer(treasury_cap, sender);
    }

}