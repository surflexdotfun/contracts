# Surflex Staking Pool

> **Network:** Sui **Testnet**
>
> | Package ID                                                                                                                                                                    | Shared Pool Object ID                                                |
> | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
> | [`0xb0b3b4ba254802a811b3c6cf42a7c84fe052049e6863a763f9256b2cacc4f61d`](https://suiscan.xyz/testnet/object/0xb0b3b4ba254802a811b3c6cf42a7c84fe052049e6863a763f9256b2cacc4f61d) | [`0x53cb0fff0b93acc58151794f5cb06b0739b6a14e6a6f8d159395c2eda2911bcc`](https://suiscan.xyz/testnet/object/0x53cb0fff0b93acc58151794f5cb06b0739b6a14e6a6f8d159395c2eda2911bcc) |

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
  --package 0xb0b3b4ba254802a811b3c6cf42a7c84fe052049e6863a763f9256b2cacc4f61d \
  --module  surflex \
  --function init_pool \
  --args    $INITIAL \
  --gas-object $GAS \
  --gas-budget 50000000
```

If the pool already exists you can skip this step; otherwise, `effects.created` will list the shared pool object ID (see table).

### 3. Stake SUI

```bash
POOL=0xb0b3b4ba254802a811b3c6cf42a7c84fe052049e6863a763f9256b2cacc4f61d
DEPOSIT=0x<YOUR_DEPOSIT_COIN>
GAS=0x<ANOTHER_COIN>

sui client call \
  --env testnet \
  --package 0xb0b3b4ba254802a811b3c6cf42a7c84fe052049e6863a763f9256b2cacc4f61d \
  --module  surflex \
  --function stake_amount \
  --args    0x53cb0fff0b93acc58151794f5cb06b0739b6a14e6a6f8d159395c2eda2911bcc $DEPOSIT \
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
  --query MoveEventType=0xb0b3b4ba254802a811b3c6cf42a7c84fe052049e6863a763f9256b2cacc4f61d::surflex::StakeEvent
```
