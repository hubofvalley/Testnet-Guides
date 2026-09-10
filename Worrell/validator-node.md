# Worrell Testnet Validator Node

## Automatic installation

Use the Grand Valley menu as the primary entrypoint:

Run the reviewed public launcher directly:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/hubofvalley/Valley-of-Worrel-Testnet/main/resources/valleyofWorrel.sh)
```

The launcher executes the canonical script in [Valley-of-Worrel-Testnet](https://github.com/hubofvalley/Valley-of-Worrel-Testnet). The menu starts with the Valley privacy notice, requirements, official endpoints, and a confirmation gate before installation. Installation then asks for pruned/archive storage and direct `worrelld`/Cosmovisor runtime; pruned is the default with keep-recent `100` and interval `20`.

For a normal node user, the installer persists `$HOME/go/bin` in `~/.bash_profile`, so `worrelld` is available in new login shells. It also writes controlled runtime settings to `$WORRELL_HOME/.worrell.env`. In root-only mode it uses `/usr/local/bin` and `/var/lib/worrell` without modifying `/root/.bash_profile`. Run `source ~/.bash_profile` only after normal-user installation.

## Manual installation

### Requirements

Ubuntu 22.04 LTS, 2 vCPU, 4 GB RAM, 100 GB SSD, and a stable network with public P2P reachability. The upstream runbook recommends `worrelld` v0.1.2 and Go `1.25.10+` for source builds.

### Network configuration

- Chain ID: `worrell-testnet-1`
- Home: `~/.worrell`
- Token: `uworrell` (1 WORRELL = 1,000,000 uworrell)
- Minimum gas: `0.025uworrell`
- P2P: `26656`
- RPC: `26657`
- Genesis SHA256: `a81c507b12ba0678c3172394ff4bb03e1c3db60050cc5568c127a24ec19378fd`

Official peers:

```text
bb9164c1bd9ed9ff2c0fd9e09b23285698e231de@164.68.98.186:26656
40128ea31b1cfb5d4b24fc9e32ee0c468586c983@worrell-testnet-peer.itrocket.net:12656
```

### Join the testnet

```bash
mkdir -p "$HOME/go/bin"
# install the verified v0.1.2 release asset for your architecture
worrelld init <moniker> --chain-id worrell-testnet-1 --home "$HOME/.worrell"
curl -fsSL https://raw.githubusercontent.com/worrellchain/networks/main/worrell-testnet-1/genesis.json \
  -o "$HOME/.worrell/config/genesis.json"
echo 'a81c507b12ba0678c3172394ff4bb03e1c3db60050cc5568c127a24ec19378fd  '"$HOME/.worrell/config/genesis.json" | sha256sum -c -
worrelld genesis validate-genesis --home "$HOME/.worrell"
```

Choose the application-state retention policy before starting the service. For a normal validator, use pruned mode:

```toml
pruning = "custom"
pruning-keep-recent = "100"
pruning-interval = "20"
```

For an archive node, retain all application-state history:

```toml
pruning = "nothing"
pruning-keep-recent = "0"
pruning-interval = "0"
```

Changing from pruned to archive later cannot recreate states already deleted. This choice is independent of direct `worrelld` versus Cosmovisor runtime.

Set `persistent_peers` in `config.toml` and `minimum-gas-prices = "0.025uworrell"` in `app.toml`, then run:

```bash
worrelld start --home "$HOME/.worrell"
worrelld status --home "$HOME/.worrell" 2>&1 | jq '.sync_info'
```

Wait for `catching_up: false` before creating a validator. The Valley status screen reads this boolean directly from the local RPC, so a synced node is shown as `false`, not `UNKNOWN`.

### Create a validator

Create or recover a key, check its balance, and inspect the consensus public key:

```bash
worrelld keys add <key-name> --home "$HOME/.worrell" --output text
worrelld keys show <key-name> -a --home "$HOME/.worrell"
worrelld tendermint show-validator --home "$HOME/.worrell"
```

The text-mode key-creation command prints a new mnemonic only once. Write it down and store it offline before continuing; recovery accepts an existing mnemonic and does not print it back. Neither the command nor the Valley launcher saves or uploads it. Avoid terminal recording or transcript tools while creating keys.

The Valley default uses 20 WORRELL self-delegation (`20000000uworrell`), 5% commission, 25% max commission, 1% max daily change, and `1000000` uworrell minimum self-delegation. Review `validator.json` before signing:

```bash
worrelld tx staking create-validator validator.json \
  --from <key-name> --chain-id worrell-testnet-1 --home "$HOME/.worrell" \
  --gas auto --gas-adjustment 1.5 --gas-prices 0.025uworrell --yes
```

### Delegate to a validator

Use Valley menu `2f` after the local node reports `catching_up: false`.
The guarded flow resolves the local key, validates the target
`worrellvaloper1...` address, queries the account balance and validator record
through the local RPC, and asks for an explicit `yes` confirmation. It uses
Cosmos SDK `tx staking delegate`; Worrell has no separate `stake` command.

Amounts must be positive integers with exactly one `uworrell` suffix:

```bash
worrelld tx staking delegate <worrellvaloper1...> 1000000uworrell \
  --from <key-name> --chain-id worrell-testnet-1 --home "$HOME/.worrell" \
  --node tcp://127.0.0.1:26657 \
  --gas auto --gas-adjustment 1.5 --gas-prices 0.025uworrell --yes
```

Review the balance, validator record, target address, and exact amount before
signing. Do not paste a mnemonic or private key into a command or chat.

### Operations

```bash
sudo systemctl status worrelld --no-pager
sudo journalctl -u worrelld -fn 100 -o cat
worrelld query slashing signing-info "$(worrelld tendermint show-address --home "$HOME/.worrell")" --home "$HOME/.worrell"
```

Never run two instances with the same `priv_validator_key.json`; double-signing can cause a severe slash. Keep RPC, REST, gRPC, and Prometheus private unless deliberately protected.

## Canonical guide

The complete menu reference, checksum handling, port-prefix behaviour, backup flow, and known limitations are maintained in the [Valley-of-Worrel-Testnet repository](https://github.com/hubofvalley/Valley-of-Worrel-Testnet).


## Apply a snapshot

Use the Valley menu: `1. Node Interactions` -> `h. Apply Snapshot`.

The flow keeps the standard Valley UX:

1. Choose `ITRocket` or `Sychonix`.
2. Choose `Pruned`.
3. Review provider, height, size, update metadata, and archive URL.
4. Press Enter to continue, then type `APPLY-WORRELL-SNAPSHOT` for the destructive confirmation.

Current provider sources:

- ITRocket: rotating archive resolved from `https://server-3.itrocket.net/testnet/worrell/.current_state.json`.
- Sychonix: `https://snapshot.sychonix.com/testnet/worrell/worrell-snapshot.tar.lz4`.

The helper downloads and validates the LZ4 archive before downtime, accepts only a top-level `data/` tree, rejects links/special files and unsafe paths, preserves `config/` and the current `data/priv_validator_state.json`, and restarts the existing service only if it was active before the snapshot. Archive snapshots are not offered until a provider publishes a verified archive source. Snapshot application does not change pruning configuration or direct/Cosmovisor runtime.
