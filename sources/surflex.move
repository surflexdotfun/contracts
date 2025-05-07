module surflex::surflex {

    use sui::object::UID;
    use sui::tx_context::TxContext;
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
    }

    // / One‑time initializer — deployer runs this once to bootstrap the shared pool.
    public entry fun init_pool(seed_coin: Coin<SUI>, ctx: &mut TxContext) {
        // let mut bal = balance::Balance<SUI>(0);
        let seed_balance = sui::coin::into_balance(seed_coin);
        let seed_val = balance::value(&seed_balance);

        let pool = StakingInfo {
            id: object::new(ctx),
            treasury: seed_balance,
            staked_amount: seed_val,
        };
        transfer::share_object(pool);
    }

    // / Stake SUI into the shared pool.
    public entry fun stake_amount(
        pool: &mut StakingInfo,
        mut payment_coin: Coin<SUI>,
        amount: u64,
        ctx: &mut TxContext,
    ) {
        let stake_part = sui::coin::split(&mut payment_coin, amount, ctx);

        let stake_balance = sui::coin::into_balance(stake_part);
        balance::join(&mut pool.treasury, stake_balance);
        pool.staked_amount = pool.staked_amount + amount;

        event::emit<StakeEvent>(StakeEvent { amount, sender: tx_context::sender(ctx) });

        transfer::public_transfer(payment_coin, tx_context::sender(ctx));
    }

    public fun get_total(pool: &StakingInfo): u64 {
        pool.staked_amount
    }
}
