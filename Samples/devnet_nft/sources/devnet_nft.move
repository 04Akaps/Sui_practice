module devnet_nft::my_nft {

    use sui::object::{Self, UID, ID, new};
    use sui::tx_context::{Self};
    use sui::transfer::{Self};
    use sui::event;

    use std::string::{Self};

    struct Owner has key, store {
        id : UID
    }

    struct DevNetNFT has key, store{
        id : UID,
        name : string::String,
        description : string::String,
        metadata : string::String,
        tokenId : u64
    }

    // **** event  *****

    struct NFTMinted has copy, drop {
        object_id : ID, // only have address type
        creator : address,
        name : string::String
    }

    public fun get_NFT_name(nft : &DevNetNFT) : string::String{
        nft.name
    }

    public fun get_NFT_description(nft : &DevNetNFT) : string::String{
        nft.description
    }

    public fun get_NFT_metadata(nft: &DevNetNFT) : string::String{
        nft.metadata
    }

    public fun get_NFT_tokenId(nft : &DevNetNFT) : u64{
        nft.tokenId
    }

    fun init(ctx : &mut tx_context::TxContext) {
        transfer::transfer(Owner {
            id : new(ctx)
        }, tx_context::sender(ctx))
    }

    public entry fun mint_to_sender_by_owner (
        _ : &Owner ,
        metadata : vector<u8>,
        description : vector<u8>,
        name : vector<u8>,
        tokenId : u64,
        ctx : &mut tx_context::TxContext
    ){
        let sender : address = tx_context::sender(ctx);

        let newNft = DevNetNFT {
            id : new(ctx),
            name : string::utf8(name),
            description : string::utf8(description),
            metadata : string::utf8(metadata),
            tokenId : tokenId
        };

        event::emit(NFTMinted {
            object_id : object::id(&newNft),
            creator: sender,
            name : string::utf8(name)
        });

        transfer::transfer(newNft, sender);
    }

    public entry fun transfer(
        nft : DevNetNFT, to : address, _ : &mut tx_context::TxContext
    ) {
        transfer::transfer(nft, to);
    }

    public entry fun update_description(
        nft : &mut DevNetNFT,
        new_description : vector<u8>,
        _ : &mut tx_context::TxContext
    ) {
        nft.description = string::utf8(new_description);
    }

    public entry fun burn (
        nft :  DevNetNFT,
        _ : &mut tx_context::TxContext
    ) {
        let DevNetNFT { id, name :_, description : _, metadata : _, tokenId : _} = nft;

        object::delete(id);
    }

    public entry fun change_owner (
        _ : &Owner,
        owner: Owner,
        ctx : &mut tx_context::TxContext,
    ) {
        let Owner { id} = owner;
        object::delete(id);

        transfer::transfer(Owner {
            id : new(ctx)
        },tx_context::sender(ctx));
    }

}