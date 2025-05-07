module surflex::surflex {

    use sui::object::UID;
    use sui::tx_context::TxContext;
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
        treasury: Coin<SUI>,
        staked_amount: u64,
    }

    /// One‑time initializer — deployer runs this once to bootstrap the shared pool.
    public entry fun init_pool(initial_coin: Coin<SUI>, ctx: &mut TxContext) {
        let amount = sui::coin::value(&initial_coin);

        let pool = StakingInfo {
            id: sui::object::new(ctx),
            treasury: initial_coin,
            staked_amount: amount,
        };

        sui::transfer::share_object(pool);
    }

    /// Stake SUI into the shared pool.
    public entry fun stake(pool: &mut StakingInfo, deposit: Coin<SUI>, ctx: &mut TxContext) {
        let amount = sui::coin::value(&deposit);

        sui::coin::join(&mut pool.treasury, deposit);
        pool.staked_amount = pool.staked_amount + amount;

        event::emit<StakeEvent>(StakeEvent {
            amount,
            sender: sui::tx_context::sender(ctx),
        });
    }

    public fun get_total(pool: &StakingInfo): u64 {
        pool.staked_amount
    }
}
