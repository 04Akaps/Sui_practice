/// Functions to send funds to addresses
module getbeef::transfers
{
    use sui::balance;
    use sui::coin::{Self, Coin};
    use sui::transfer;
    use sui::tx_context::TxContext;
    use sui::vec_map::{Self, VecMap};

    /// Send all funds to a given address
    public fun send_all<K: copy+drop, T>(
        funds: &mut VecMap<K, Coin<T>>,
        recipient: address,
        ctx: &mut TxContext)
    {
        // Accumulate balance
        let total_balance = balance::zero();
        let i = vec_map::size(funds);

        while (i > 0) {
            i = i - 1;
            let (_, coin) = vec_map::remove_entry_by_idx(funds, i);
            balance::join( &mut total_balance, coin::into_balance(coin) );
        };
        // Send all funds
        transfer::transfer(
            coin::from_balance(total_balance, ctx),
            recipient
        );
    }

    /// Send all funds (values) back to the associated addresses (keys)
    public fun refund_all<T>(funds: &mut VecMap<address, Coin<T>>)
    {
        let i = vec_map::size(funds);
        
        while (i > 0) {
            i = i - 1;
            let (addr, coin) = vec_map::remove_entry_by_idx(funds, i);
            transfer::transfer(coin, addr);
        }
    }
}