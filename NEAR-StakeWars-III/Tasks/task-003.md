## Mount Staking Pool `(Challenge 003)`

1. Membuat Staking Pool Contract

    ```bash
    near call factory.shardnet.near create_staking_pool '{"staking_pool_id": "nama_wallet", "owner_id": "xx.shardnet.near", "stake_public_key": "public_key_kamu", "reward_fee_fraction": {"numerator": 5, "denominator": 100}, "code_hash":"DD428g9eqLL8fWUxv8QSpVFzyHi1Qd16P8ephYCTmMSZ"}' --accountId="<nama wallet anda>.shardnet.near" --amount=30 --gas=300000000000000
    ```
 
    `public_key_kamu` ganti dengan `public_key` wallet kalian menggunakan command dibawah ini.
    
    ```bash
    cat ~/.near/validator_key.json | jq .public_key
    ```
    
    `--amount=30` kalian dapat bebas untuk merubah jumlah stake (30 merupakan angka minimum stake pada validator). Sangat dianjurkan untuk menyisakan banyak NEAR untuk keperluan gas. Namun untuk memastikan berapa NEAR yang dibutuhkan, kalian bisa cek seat price di link berikut https://explorer.shardnet.near.org/nodes/validators .


2. Jika sudah selesai, Maka hasilnya seperti Berikut ini

    ![image](https://user-images.githubusercontent.com/100946299/180949409-35e30857-976c-43f1-b32a-3c349fad14ac.png)

3. Cek validators kalian di explorer 
    
    https://explorer.shardnet.near.org/nodes/validators


## Lanjutkan ke Challenge 004 untuk melakukan monitoring status pada node

[Menjalankan Monitoring Status pada node](https://github.com/cbjohnson90/Testnet-Guides/blob/main/NEAR-StakeWars-III/Tasks/task-004.md)
