# Surflex Staking Pool

> **Network:** Sui **Testnet**
>
> | Package ID                                                                                                                                                                    | Shared Pool Object ID                                                |
> | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
> | [`0x59275d4cdd158aa2b28ccaeac416fbc10a11786271473e651168f1b489f84dd9`](https://suiscan.xyz/testnet/object/0x59275d4cdd158aa2b28ccaeac416fbc10a11786271473e651168f1b489f84dd9) | [`0xf73e718ec1e4f3a2589d0cdcab6696f69b86dbedaa902c7d82b965e9ee534f98`](https://suiscan.xyz/testnet/object/0xf73e718ec1e4f3a2589d0cdcab6696f69b86dbedaa902c7d82b965e9ee534f98) |

---

## ✨ Overview

`surflex::surflex` is a **shared‑object staking pool** written in Move for the Sui blockchain. Anyone can deposit a `Coin<SUI>` into a single on‑chain treasury; every deposit triggers an on‑chain `StakeEvent` that indexers and back‑ends can stream in real time.


---

## 📦 Module API

| Entry Function            | Description                                                                                    | Who can call       |
| ------------------------- | ---------------------------------------------------------------------------------------------- | ------------------ |
| `init_pool(initial_coin)` | Bootstraps the pool **once**: merges `initial_coin` into the treasury, then shares the object. | Deployer, one‑time |
| `stake(pool, deposit)`    | Merges `deposit` (`Coin<SUI>`) into the shared treasury and emits `StakeEvent`.                | Anyone             |
| `get_total(pool)`         | Read‑only helper that returns total staked SUI (`u64`).                                        | Anyone             |

### Event type

```move
struct StakeEvent {
    amount: u64,
    sender: address,
}
```

---

## 🚀 Quick Start (Sui CLI)

### 1. Publish (the module is already live – keep for reference)

```bash
sui client publish --path . \
  --env testnet \
  --gas-budget 100000000
```

The resulting `packageId` should match the table above.

### 2. Create the pool (`init_pool`)

```bash
# Prepare any Coin<SUI> with ≥ 1 MIST (10‑9 SUI)
INITIAL=0x<COIN_ID>
GAS=0x<ANOTHER_COIN>

sui client call \
  --env testnet \
  --package 0x59275d4cdd158aa2b28ccaeac416fbc10a11786271473e651168f1b489f84dd9 \
  --module  surflex \
  --function init_pool \
  --args    $INITIAL \
  --gas-object $GAS \
  --gas-budget 50000000
```

If the pool already exists you can skip this step; otherwise, `effects.created` will list the shared pool object ID (see table).

### 3. Stake SUI

```bash
POOL=0x59275d4cdd158aa2b28ccaeac416fbc10a11786271473e651168f1b489f84dd9
DEPOSIT=0x<YOUR_DEPOSIT_COIN>
GAS=0x<ANOTHER_COIN>
AMOUNT=10

sui client call \
  --env testnet \
  --package 0x59275d4cdd158aa2b28ccaeac416fbc10a11786271473e651168f1b489f84dd9 \
  --module  surflex \
  --function stake_amount \
  --args    0xf73e718ec1e4f3a2589d0cdcab6696f69b86dbedaa902c7d82b965e9ee534f98 $DEPOSIT $AMOUNT \
  --gas-object $GAS \
  --gas-budget 50000000
```

> **Note:** the *entire balance* of `DEPOSIT` is staked. Use `split-coin` first if you want to stake a specific amount.

### 4. Query pool & events

```bash
# Total amount staked
sui client object --env testnet --id $POOL | jq '.data.content.fields.staked_amount'

# Real‑time event stream
sui client events --env testnet \
  --query MoveEventType=0x59275d4cdd158aa2b28ccaeac416fbc10a11786271473e651168f1b489f84dd9::surflex::StakeEvent
```
