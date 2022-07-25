## Menjalankan Monitoring Status pada node `(Challenge 004)`

1. Install jq

    ```bash
    sudo apt install curl jq
    ```

2. Cek node version

    ```bash
    curl -s http://127.0.0.1:3030/status | jq .version
    ```
    
    (gambar)
    
    - Cek Delegators dan Stake

        ```bash
        near view xx.factory.shardnet.near get_accounts '{"from_index": 0, "limit": 10}' --accountId <nama wallet anda>.shardnet.near

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
