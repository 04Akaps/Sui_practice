module game::hero {

    use sui::tx_context::{TxContext, sender};
    use sui::object::{UID, ID,new, uid_to_inner, id};
    use sui::transfer::{freeze_object, transfer};
    use sui::coin::{Coin, value};
    use sui::sui::SUI;
    use sui::math;

    use std::option::{Option, some};

    const MAX_HP: u64 = 1000;
    const MAX_MAGIC: u64 = 10;
    const MIN_SWORD_COST: u64 = 100;

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
        admin :address
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
        moster : ID,
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
            admin : sender
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

    //  ---- game play ----

    public fun buy_sword (
        game : &GameInfo,
        payment : Coin<SUI>,
        ctx: &mut TxContext
    ) {
        let value = value(&payment);

        assert!(value >= MIN_SWORD_COST, EINSUFFICIENT_FUNDS);
        transfer(payment, game.admin);

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

    public fun create_new_hero (
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

    // ---- check Function ----

    public fun check_game_id(g : &GameInfo, id : ID){
        assert!(id(g) == id , 403);
    }

    public fun sword_owner_check(s : &Sword, owner : address){
        assert!(s.owner == owner, 403);
    }
  


}