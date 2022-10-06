module object::my_module {

    use sui::object;
    use sui::tx_context::{Self, TxContext,sender};
    use sui::transfer;

    struct Color has key{
        id : object::UID, 
        red: u8,
        green : u8,
        blue : u8
    }

    fun new (red : u8, green : u8, blue : u8, ctx : &mut TxContext) : Color {
        Color{
            id : object::new(ctx),
            red,
            green,
            blue
        }
    }

    public fun transfer(color : Color, ctx : &mut tx_context::TxContext) {
        transfer::transfer(color, sender(ctx));
    }

    public fun get_color (self : &Color) : (u8, u8, u8) {
        (self.red, self.green, self.blue)
    }

}