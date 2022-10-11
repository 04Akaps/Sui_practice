module game::rock_paper_scissors {

    use sui::object::{UID, new, delete};
    use sui::tx_context::{sender, TxContext};
    use sui::transfer::{transfer};

    use std::vector::{Self};
    use std::hash;

    const NONE: u8 = 0;
    const ROCK: u8 = 1;
    const PAPER: u8 = 2;
    const SCISSORS: u8 = 3;
    const CHEAT: u8 = 111;

    const STATUS_READY: u8 = 0;
    const STATUS_HASH_SUBMISSION: u8 = 1;
    const STATUS_HASHES_SUBMITTED: u8 = 2;
    const STATUS_REVEALING: u8 = 3;
    const STATUS_REVEALED: u8 = 4;

    struct ThePrize has key ,store {
        id : UID
    }

    struct Game has key {
        id : UID,

        prize : ThePrize,

        player_one: address,
        player_two: address,

        hash_one: vector<u8>,
        hash_two: vector<u8>,

        gesture_one: u8,
        gesture_two: u8,
    }

    struct PlayerTurn has key {
        id: UID,
        hash: vector<u8>,
        player: address,
    }

    struct Secret has key {
        id: UID,
        salt: vector<u8>,
        player: address,
    }

    public fun get_status(game : &Game) : u8 {
        let h1_len = vector::length(&game.hash_one);
        let h2_len = vector::length(&game.hash_two);

        if(game.gesture_one != NONE && game.gesture_two != NONE) {
            STATUS_REVEALED
        } else if(game.gesture_one != NONE || game.gesture_two != NONE){
            STATUS_REVEALING
        } else if( h1_len == 0 && h2_len == 0){
            STATUS_READY
        } else if(h1_len != 0 && h2_len != 0 ){
            STATUS_HASHES_SUBMITTED
        } else if(h1_len != 0 || h2_len != 0){
            STATUS_HASH_SUBMISSION
        }else {
            0
        }
    }

    public entry fun new_game(player_one : address, player_two : address, ctx : &mut TxContext){
        transfer(Game {
            id : new(ctx),
            prize : ThePrize{id : new(ctx)},
            player_one, 
            player_two,
            hash_one : vector[],
            hash_two : vector[],
            gesture_one : NONE,
            gesture_two : NONE
        }, sender(ctx))
    }

    public entry fun player_turn(at : address , hash : vector<u8>, ctx : &mut TxContext) {
        transfer(PlayerTurn{
            hash,
            id : new(ctx),
            player : sender(ctx)
        }, at);
    }

    public entry fun add_hash(game : &mut Game , cap : PlayerTurn) {
        let PlayerTurn { hash, id, player} = cap;
        let status = get_status(game);

        assert!(status == STATUS_HASH_SUBMISSION || status == STATUS_READY, 0);
        assert!(game.player_one == player || game.player_two == player, 0);

        if( player == game.player_one && vector::length(&game.hash_one) == 0) {
            game.hash_one == hash;
        } else if(player == game.player_two && vector::length(&game.hash_two) == 0){
            game.hash_two = hash;
        } else {
            abort 0
        };

        delete(id);
    }

    public entry fun reveal(at :address, salt : vector<u8> , ctx : &mut TxContext){
        transfer( Secret {
            id : new(ctx),
            salt, 
            player : sender(ctx)
        }, at);
    }

    public entry fun match_sectet(game : &mut Game, secret : Secret ){
        let Secret { salt, player, id} = secret;

        assert!(player == game.player_one || player == game.player_two, 0);


        if (player == game.player_one ){
            game.gesture_one = find_gesture(salt, &game.hash_one);
        } else if (player == game.player_two){
            game.gesture_two = find_gesture(salt, &game.hash_two);
        };

        delete(id);
    }

    public entry fun select_winner(game : Game, ctx : &mut TxContext) {
        assert!(get_status(&game) == STATUS_REVEALED, 0);

        let Game {
            id, 
            prize,
            player_one,
            player_two,
            hash_one : _,
            hash_two : _,
            gesture_one,
            gesture_two
        } = game;

        let p1_wins = play(gesture_one, gesture_two);
        let p2_wins = play(gesture_two, gesture_one);

        delete(id);

        if (p1_wins){
            transfer(prize, player_one)
        } else if(p2_wins){
            transfer(prize, player_two)
        } else {
            transfer(prize, sender(ctx))
        };
    }

    fun play(one : u8, two : u8) : bool {
        if (one == ROCK && two == SCISSORS) { true}
        else if (one == PAPER && two == ROCK) { true}
        else if (one == SCISSORS && two == PAPER) { true}
        else if (one != CHEAT && two == CHEAT) { true}
        else {false}
    }


    fun find_gesture(salt : vector<u8>, hash : &vector<u8>) : u8{
        if( hash(ROCK, salt) == *hash){
            ROCK
        } else if (hash(PAPER, salt) == *hash){
            PAPER
        } else if (hash(SCISSORS, salt) == *hash){
            SCISSORS
        }else{
            CHEAT
        }
    }

    fun hash(gesture : u8, salt : vector<u8>) : vector<u8> {
        vector::push_back(&mut salt, gesture);
        hash::sha2_256(salt)
    }


}