## Menjalankan Monitoring Status pada node `(Challenge 004)`

1. Install jq

   ```bash
   sudo apt install curl jq
   ```

2. Cek node version

   ```bash
   curl -s http://127.0.0.1:3030/status | jq .version
   ```

   ![image](https://user-images.githubusercontent.com/100946299/183800267-9a0350c0-cab4-409a-978c-ce05aa8f2426.png)

   - Cek Delegators dan Stake

     ```bash
     near view <nama wallet anda>.factory.shardnet.near get_accounts '{"from_index": 0, "limit": 10}' --accountId <nama wallet anda>.shardnet.near

     ```

   - Cek Block Produced
     ```bash
     curl -s -d '{"jsonrpc": "2.0", "method": "validators", "id": "dontcare", "params": [null]}' -H 'Content-Type: application/json' 127.0.0.1:3030 | jq  '.result.current_validators[] | select(.account_id | contains ("<nama wallet anda>.factory.shardnet.near"))'
     ```
   - Cek Reason Validator Kicked
     ```bash
     curl -s -d '{"jsonrpc": "2.0", "method": "validators", "id": "dontcare", "params": [null]}' -H 'Content-Type: application/json' 127.0.0.1:3030 | jq -c '.result.prev_epoch_kickout[] | select(.account_id | contains ("<nama wallet anda>.factory.shardnet.near"))' | jq .reason
     ```

3. Cek Sinkronisasi

   Apabila status sync adalah `true` maka node anda belum tersinkronisasi. Namun apabila status sync anda adalah `false` maka node anda sudah tersinkronisasi. Gunakan perintah dibawah ini :

   ```
   curl -s http://127.0.0.1:3030/status | jq .sync_info
   ```

## Anda dapat lanjut ke challenge 006 (challenge 005 diminta buat tutorial di Medium atau Github)

[Menjalankan Ping Secara Otomatis Per 2 Jam Sekali](https://github.com/cbjohnson90/Testnet-Guides/blob/main/NEAR-StakeWars-III/Tasks/task-006.md) `(Challenge 006)`
