module shared_object::my_module {

    use sui::object::{Self, UID};
    use sui::balance::{Self, Balance, zero};
    use sui::tx_context::{TxContext, sender};
    use sui::sui::SUI;
    use sui::transfer::{transfer, share_object};
    use sui::coin::{Self, Coin};

    const NOT_ENOUGH : u64 = 0;
    const TOO_MUTCH : u64 = 1;

    struct ShopOwnerCap has key { id : UID}

    struct Donut has key {id : UID}

    struct DonutShop has key {
        id : UID,
        price : u64,
        balance: Balance<SUI>
    }

    fun init(ctx: &mut TxContext){
        transfer(ShopOwnerCap {
            id: object::new(ctx)
        }, sender(ctx));

        share_object(DonutShop {
            id :object::new(ctx),
            price : 1000,
            balance : zero()
        })  
    }

    public entry fun buy_one_donut(
        shop : &mut DonutShop, payment : &mut Coin<SUI>, ctx : &mut TxContext
    ) {
        let shop_price : u64 = shop.price; // bring price

        assert!(coin::value(payment) == shop_price, NOT_ENOUGH);
        // calculate payment has enough value

        let coin_balance = coin::balance_mut(payment); // bring the can changable balance

        let paid = balance::split(coin_balance, shop_price); // delete shop_price from coin_balance
        // paid == shop_price

        // will payment's balance = coin_balance will be deleted shop_price

        balance::join(&mut shop.balance, paid);
        // add paid amount to shop.balance

        transfer(Donut {
            id : object::new(ctx)
        }, sender(ctx))
        // and send donut
    }

    public entry fun buy_multi_donut (
        shop : &mut DonutShop, payment : &mut Coin<SUI>, ctx : &mut TxContext
    ) {
        let shop_price : u64 = shop.price;
        let value = coin::value(payment);

        assert!(value / shop_price >= 1 , NOT_ENOUGH);
        assert!(value % shop_price == 0, TOO_MUTCH);

        let coin_balance = coin::balance_mut(payment);

        let paid = balance::split(coin_balance, shop_price);

        balance::join(&mut shop.balance, paid);

        transfer(Donut {
            id : object::new(ctx)
        }, sender(ctx))
    }

    public entry fun eat_donut(d: Donut) {
        let Donut { id } = d;

        object::delete(id);
    }

    public entry fun collect_profits (
         shop : &mut DonutShop, ctx : &mut TxContext
    ) {
        let amount : u64 = balance::value(&shop.balance);
        // get balance from shop.balance

        let profits = coin::take(&mut shop.balance, amount, ctx);
        // get all amount

        transfer(profits, sender(ctx))

    }

}