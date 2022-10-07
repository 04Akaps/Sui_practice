module transfer::wrapper {
    
    use sui::object::{UID, new};
    use sui::tx_context::{TxContext};

    struct Wrapper<T : store> has key, store{
        id :UID,
        contents : T
    }

    public fun contents<T:store> (c : &Wrapper<T>) : &T {
        &c.contents
    }

    public fun create<T :store> (
        contents : T, ctx: &mut TxContext
    ): Wrapper<T> {
        Wrapper{
            contents,
            id : new(ctx)
        }
    }
}

module transfer::profile {
    use 0x0::wrapper;

    use sui::url::{Self,Url};
    use std::string::{Self, String};
    use sui::transfer::{transfer};
    use sui::tx_context::{sender, TxContext};

    struct ProfileInfo has store{
        name :String,
        url : Url
    }

    public fun name(info : &ProfileInfo) : &String {
        &info.name
    }

    public fun url(info : &ProfileInfo) : &Url {
        &info.url
    }

    public fun create_profile (
        name : vector<u8>, url : vector<u8>, ctx : &mut TxContext
    ) {
        let container = wrapper::create(ProfileInfo {
            name : string::utf8(name),
            url : url::new_unsafe_from_bytes(url)
        }, ctx);

        transfer(container, sender(ctx))
    }
}