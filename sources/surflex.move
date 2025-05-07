module surflex::surflex {

    use sui::balance::{Self, Balance};
    use sui::coin::Coin;
    use sui::sui::SUI;
    use sui::event;
    
    /// Emitted when `stake()` is called.
    public struct StakeEvent has copy, drop, store {
        amount: u64,
        sender: address,
    }

    /// The single global pool.
    public struct StakingInfo has key, store {
        id: UID,
        treasury: Balance<SUI>,
        staked_amount: u64,
        pot_amount: u64,
    }

    /// One-time initializer — deployer runs this once to bootstrap the shared pool.
    /// No seed coin is required; the pool starts empty.
    public entry fun init_pool(pot_amount: u64, ctx: &mut TxContext) {
        let pool = StakingInfo {
            id: object::new(ctx),
            treasury: balance::zero<SUI>(),   // empty Balance<SUI>
            staked_amount: 0,                 // start at 0
            pot_amount,
        };
        transfer::share_object(pool);
    }

    /// Stake SUI into the shared pool.
    public entry fun stake(
        pool: &mut StakingInfo,
        mut payment_coin: Coin<SUI>,
        ctx: &mut TxContext,
    ) {
        let stake_part = sui::coin::split(&mut payment_coin, pool.pot_amount, ctx);

        let stake_balance = sui::coin::into_balance(stake_part);
        balance::join(&mut pool.treasury, stake_balance);
        pool.staked_amount = pool.staked_amount + pool.pot_amount;

        event::emit<StakeEvent>(StakeEvent {
            amount: pool.pot_amount,
            sender: tx_context::sender(ctx),
        });

        transfer::public_transfer(payment_coin, tx_context::sender(ctx));
    }

    public fun get_total(pool: &StakingInfo): u64 {
        pool.staked_amount
    }
}