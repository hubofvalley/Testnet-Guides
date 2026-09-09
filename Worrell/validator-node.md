# Worrell Testnet Validator Node

## Automatic installation

Use the Grand Valley menu as the primary entrypoint:

```bash
bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/Worrell/resources/valleyofWorrel.sh)
```

This loader is kept in Testnet-Guides and executes the canonical script in [Valley-of-Worrel-Testnet](https://github.com/hubofvalley/Valley-of-Worrel-Testnet). The menu starts with the Valley privacy notice, requirements, official endpoints, and a confirmation gate before installation.

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

Set `persistent_peers` in `config.toml` and `minimum-gas-prices = "0.025uworrell"` in `app.toml`, then run:

```bash
worrelld start --home "$HOME/.worrell" --chain-id worrell-testnet-1
worrelld status --home "$HOME/.worrell" 2>&1 | jq '.sync_info'
```

Wait for `catching_up: false` before creating a validator.

### Create a validator

Create or recover a key, check its balance, and inspect the consensus public key:

```bash
worrelld keys add <key-name> --home "$HOME/.worrell"
worrelld keys show <key-name> -a --home "$HOME/.worrell"
worrelld tendermint show-validator --home "$HOME/.worrell"
```

The upstream example uses 20,000,000 WORRELL self-delegation (`20000000000000uworrell`), 5% commission, 25% max commission, 1% max daily change, and `1000000` uworrell minimum self-delegation. Review `validator.json` before signing:

```bash
worrelld tx staking create-validator validator.json \
  --from <key-name> --chain-id worrell-testnet-1 --home "$HOME/.worrell" \
  --gas auto --gas-adjustment 1.5 --gas-prices 0.025uworrell --yes
```

### Operations

```bash
sudo systemctl status worrelld --no-pager
sudo journalctl -u worrelld -fn 100 -o cat
worrelld query slashing signing-info "$(worrelld tendermint show-address --home "$HOME/.worrell")" --home "$HOME/.worrell"
```

Never run two instances with the same `priv_validator_key.json`; double-signing can cause a severe slash. Keep RPC, REST, gRPC, and Prometheus private unless deliberately protected.

## Canonical guide

The complete menu reference, checksum handling, port-prefix behaviour, backup flow, and known limitations are maintained in the [Valley-of-Worrel-Testnet repository](https://github.com/hubofvalley/Valley-of-Worrel-Testnet).
