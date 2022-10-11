module warrior_sui::warrior {

    use sui::object::{UID, new};
    use sui::tx_context::{Self, TxContext, sender};
    use sui::transfer::{transfer, share_object};

    use std::string;
    use std::option::{Self, Option};
    use std::vector;
    use std::hash;

    struct Ownership has key {
        id : UID
    }

    struct NFTGlobalData has key {
        id : UID,
        maxWarriorSupply : u64,
        mintedwarriors : u64,
        baseWarriorURL : string::String,
        baseWeaponURL : string::String,
        mintingEnabled : bool,
        owner : address,
        mintedAddresses : vector<address>
    }

    struct SuiWarriorNFT has key {
        id : UID,
        index : u64,
        name : string::String,
        baseAttackPower: u64,
        baseSpellPower: u64,
        baseHealthPoints : u64,
        experiencePoints : u64,
        url : string::String,
        equippedWeapon : Option<Weapon>
    }

    struct Weapon has key, store {
        id : UID,
        name : string::String,
        attackPower: u64,
        spellPower: u64,
        healthPoints : u64,
        url : string::String
    }

    struct Boss has key {
        id : UID,
        name : string::String,
        attackPower : u64,
        spellPower : u64,
        healthPoints : u64,
        experiencePointsReward : u64,
        url : string::String
    }

    // initializer

    fun init(ctx : &mut TxContext){
        let owner = Ownership {
            id : new(ctx)
        };

        let nftGlobalData = NFTGlobalData {
            id : new(ctx),
            maxWarriorSupply : 10000,
            mintedwarriors : 0,
            baseWarriorURL : string::utf8(b"https://ipfs.io/ipfs/QmSrgtDKdUw4a9GVxWH3fSiVnFKX4ivtwvkZZiopWSwLNW/"),
            baseWeaponURL : string::utf8(b"https://ipfs.io/ipfs/QmUPTXn9KrK3x5dD4x2RH3t2fNk7LgUUjVyygR7CsPyk6L/"),
            mintingEnabled : true,
            owner : sender(ctx),
            mintedAddresses : vector::empty()
        };

        share_object(nftGlobalData);
        transfer(owner, sender(ctx));
    }

    // Owner functions

    entry fun changeMintingStatus(
        flag : bool, 
        globalData : &mut NFTGlobalData, 
        ctx : &mut TxContext)
    {
        assert!(globalData.owner == sender(ctx),0);
        globalData.mintingEnabled = flag;
    }

    entry fun mintBoss(
        _ownership : &Ownership, 
        name : vector<u8>, 
        attackPower : u64, 
        spellPower: u64, 
        healthPoints : u64, 
        experiencePointsRewards : u64, 
        url : vector<u8>, 
        ctx : &mut TxContext
    ) {
        let boss = Boss {
            id : new(ctx),
            name : string::utf8(name),
            attackPower,
            spellPower,
            healthPoints,
            experiencePointsReward : experiencePointsRewards,
            url : string::utf8(url)
        };

        share_object(boss);
    }

    // getters

     public fun name(nft: &SuiWarriorNFT): &string::String {
        &nft.name
    }

    public fun url(nft: &SuiWarriorNFT): &string::String {
        &nft.url
    }

    public fun warriorBaseAttackPower(nft: &SuiWarriorNFT): u64 {
        nft.baseAttackPower
    }

    public fun warriorBaseSpellPower(nft: &SuiWarriorNFT): u64 {
        nft.baseSpellPower
    }

    public fun warriorBaseHealthPoints(nft: &SuiWarriorNFT): u64 {
        nft.baseHealthPoints
    }

    public fun weaponAttackPower(weapon: &Weapon): u64 {
        weapon.attackPower
    }

    public fun weaponSpellPower(weapon: &Weapon): u64 {
        weapon.spellPower
    }

    public fun weaponHealthPoints(weapon: &Weapon): u64 {
        weapon.healthPoints
    }

    // random number based on timestamp

    fun randArrayGenerator(seed : vector<u8>) : vector<u8> {
        hash::sha2_256(seed)
    }

    fun randNumber(ctx : &mut TxContext) : u64 {
        tx_context::epoch(ctx)
    }

    entry fun mintWarrior(
        globalData : &mut NFTGlobalData, 
        name : vector<u8>, 
        ctx : &mut TxContext
    ) {
        assert!(globalData.mintingEnabled, 0);
        assert!(globalData.mintedwarriors < globalData.maxWarriorSupply, 0);
        assert!(vector::length(&name) >= 3, 0);

        let sender= sender(ctx);
        let randArray = randArrayGenerator(name);

        assert!(vector::contains(&globalData.mintedAddresses, &sender) == false, 0);
        assert!(vector::length(&randArray) >= 3 , 0);

        let newWarrior = SuiWarriorNFT {
            id : new(ctx),
            index : globalData.mintedwarriors,
            name : string::utf8(name),
            baseAttackPower : (*vector::borrow(&randArray, 0) as u64) * 2,
            baseSpellPower: (*vector::borrow(&randArray, 1) as u64)*2,
            baseHealthPoints: (*vector::borrow(&randArray, 2) as u64)*2,
            experiencePoints : 0,
            url : globalData.baseWarriorURL,
            equippedWeapon : option::none(),
        };

        globalData.mintedwarriors =  globalData.mintedwarriors + 1;

        vector::push_back(&mut globalData.mintedAddresses, sender);
        transfer(newWarrior, sender);
    }

    entry fun mintWeapon(globalData : &mut NFTGlobalData, name : vector<u8>, ctx : &mut TxContext) {
        assert!(globalData.mintingEnabled , 0);
        assert!(vector::length(&name) >= 3, 0);

        let sender : address = sender(ctx);
        let randArray = randArrayGenerator(name);

        assert!(vector::length(&randArray) >= 3, 0);

        let newWeapon = Weapon {
            id : new(ctx),
            name : string::utf8(name),
            attackPower: (*vector::borrow(&randArray, 0) as u64)*2,
            spellPower: (*vector::borrow(&randArray, 1) as u64)*2,
            healthPoints: (*vector::borrow(&randArray, 2) as u64)*2,
            url : globalData.baseWeaponURL
        };

        transfer(newWeapon, sender);
    }

    // Game Logic
    entry fun battleAgainstBoss(boss : &Boss, nft : &mut SuiWarriorNFTm ctx : &mut TxContext){
        // 
    }
}