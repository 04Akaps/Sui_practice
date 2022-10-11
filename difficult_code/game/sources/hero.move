module game::hero {

    use sui::tx_context::{TxContext, sender};
    use sui::object::{UID, ID,new, uid_to_inner, id, delete};
    use sui::transfer::{freeze_object, transfer};
    use sui::coin::{Coin, value, balance_mut, take};
    use sui::balance::{ Self, Balance, split, join, zero};
    use sui::sui::SUI;
    use sui::math;
    use sui::event;

    use std::option::{Option, some, is_some, borrow,borrow_mut};

    const MAX_HP: u64 = 1000;
    const MAX_MAGIC: u64 = 10;
    const MAX_POTION : u64  = 500;
    const MIN_SWORD_COST: u64 = 100;
    const MIN_POTION_CONST : u64 = 120;

    const EMONSTER_WON: u64 = 0;
    const EHERO_TIRED: u64 = 1;
    const ENOT_ADMIN: u64 = 2;
    const EINSUFFICIENT_FUNDS: u64 = 3;
    const ENO_SWORD: u64 = 4;
    const ASSERT_ERR: u64 = 5;

    struct Hero has key, store{
        id :UID,
        hp : u64,
        exp: u64,
        sword : Option<Sword>,
        game_id : ID,
    }

    struct Sword has key, store {
        id : UID,
        magic : u64,
        strength : u64,
        game_id : ID,
        owner : address,
    }

    struct Potion has key, store {
        id : UID,
        potency : u64,
        game_id : ID
    }

    struct Monster has key {
        id : UID,
        hp : u64,
        strength : u64,
        game_id : ID,
    }

    struct GameInfo has key {
        id : UID,
        admin :address,
        wallet: Balance<SUI>
    }

    struct GameAdmin has key {
        id : UID,
        mosters_created: u64,
        potions_created: u64,
        game_id : ID
    }

    struct MoseterSlainEvent has copy, drop {
        slayer_address : address,
        hero : ID,
        monster : ID,
        game_id : ID
    }


    fun init(ctx : &mut TxContext){
        initialize(ctx);
    }

    fun initialize(ctx : &mut TxContext){
        let sender : address = sender(ctx); 

        let uid = new(ctx);
        let game_id = uid_to_inner(&uid);

        freeze_object(GameInfo {
            id : uid,
            admin : sender,
            wallet : zero<SUI>()
        });

        transfer(
            GameAdmin {
                game_id,
                id : new(ctx),
                mosters_created : 0,
                potions_created : 0,
            },
            sender
        )
    }

    //  ---- acquire data ----
    public fun buy_sword (
        game : &mut GameInfo,
        payment : &mut Coin<SUI>,
        ctx: &mut TxContext
    ) {
        let value = value(payment);
        assert!(value >= MIN_SWORD_COST, EINSUFFICIENT_FUNDS);

        let mut_balance = balance_mut(payment);
        let amount = split(mut_balance, value);
        join(&mut game.wallet, amount);

        let magic = (value - MIN_SWORD_COST) / MIN_SWORD_COST;

        let new_sword = Sword {
            id : new(ctx),
            magic : math::min(magic, MAX_MAGIC),
            strength : 1,
            game_id : id(game),
            owner : sender(ctx)
        };

        transfer(new_sword , sender(ctx));
    }

    public fun buy_potion (
        game :  &mut GameInfo,
        payment :&mut  Coin<SUI>,
        ctx : &mut TxContext
    ) {
        let value = value(payment);
        assert!(value >= MIN_SWORD_COST, EINSUFFICIENT_FUNDS);

        let mut_balance = balance_mut(payment);
        let amount = split(mut_balance, value);
        join(&mut game.wallet, amount);

        let new_potion = Potion {
            id: new(ctx),
            potency : math::min(value, MAX_POTION),
            game_id : id(game)
        };

        transfer(new_potion, sender(ctx));
    }

    // created monster by Owner
    public entry fun create_monster_by_owner (
        game : &GameInfo,
        admin : &mut GameAdmin,
        hp : u64,
        strength : u64,
        user : address,
        ctx : &mut TxContext
    ) {
        check_owner(game.admin, sender(ctx));

        admin.mosters_created =   admin.mosters_created + 1;

        transfer(Monster{
            id : new(ctx),
            hp, 
            strength,
            game_id : id(game)
        }, user);
    }

    public entry fun create_new_hero (
        game: &GameInfo, 
        sword : Sword,
        ctx: &mut TxContext
    )  {
        check_game_id(game, sword.game_id);
        sword_owner_check(&sword, sender(ctx));

        let new_hero = Hero {
            id : new(ctx),
            hp : MAX_HP,
            exp : 0,
            sword : some(sword),
            game_id : id(game)
        };

        transfer(new_hero, sender(ctx));
    }

    // ---- game play ----

    public entry fun hunt_monster(
        game : &GameInfo, 
        hero : &mut Hero, 
        monster : Monster , 
        ctx: &mut TxContext
    ) {
        check_game_id(game, hero.game_id);
        check_game_id(game, monster.game_id);

        let Monster {id : monster_id, strength : monster_strength, hp, game_id : _} = monster;

        let hero_strength = get_hero_strength(hero);

        let monster_hp = hp;
        let hero_hp = hero.hp;

        while(monster_hp > hero_strength){
            monster_hp = monster_hp - hero_strength;

            assert!(hero_hp >= monster_strength , EMONSTER_WON);
            hero_hp = hero_hp - monster_strength;
        };

        hero.hp = hero_hp;
        hero.exp = hero.exp + hp;

        level_up_sword(borrow_mut(&mut hero.sword) , 1);

        event::emit(MoseterSlainEvent {
            slayer_address : sender(ctx),
            hero : uid_to_inner(&hero.id),
            monster : uid_to_inner(&monster_id),
            game_id : id(game)
        });

        delete(monster_id)
    }

    public fun get_hero_strength(hero: &Hero) : u64{
        assert!(hero.hp != 0 , 403);

        let sword_strength = if (is_some(&hero.sword)) {
            sword_strength(borrow(&hero.sword))
            // return immutable reference
        }else{
            0
        };

        (hero.exp * hero.hp) + sword_strength
    }

    public fun sword_strength(sword: &Sword): u64 {
        sword.magic + sword.strength
    }

    fun level_up_sword(sword : &mut Sword, amount : u64){
        sword.strength = sword.strength + amount;
    }

    public fun heal(hero : &mut Hero, potion : Potion) {

        let Potion  {id, potency, game_id : _} = potion;

        delete(id);

        hero.hp =math::min(hero.hp + potency, MAX_HP);
    }

    // ---- check Function ----

    fun check_owner(admin : address, sender : address){
        assert!(admin == sender, 403);
    }

    public fun check_game_id(g : &GameInfo, id : ID){
        assert!(id(g) == id , 403);
    }

    public fun sword_owner_check(s : &Sword, owner : address){
        assert!(s.owner == owner, 403);
    }

    fun withdraw(
        game : &mut GameInfo,
        ctx : &mut TxContext
    ) {
        assert!(game.admin == sender(ctx), 403);

        let amount = balance::value(&game.wallet);

        assert!(amount> 0, 402);

        let coin = take(&mut game.wallet, amount, ctx);
        
        transfer(coin, sender(ctx));
    }

}