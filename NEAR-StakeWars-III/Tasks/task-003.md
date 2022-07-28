## Mount Staking Pool `(Challenge 003)`

1. Membuat Staking Pool Contract

    ```bash
    near call factory.shardnet.near create_staking_pool '{"staking_pool_id": "<nama wallet anda>", "owner_id": "<nama wallet anda>.shardnet.near", "stake_public_key": "<public key anda>", "reward_fee_fraction": {"numerator": 5, "denominator": 100}, "code_hash":"DD428g9eqLL8fWUxv8QSpVFzyHi1Qd16P8ephYCTmMSZ"}' --accountId="<nama wallet anda>.shardnet.near" --amount=30 --gas=300000000000000
    ```
 
    Ganti ` <public key anda> ` dengan public key anda. Public key dapat dilihat menggunakan command di bawah ini :
    
    ```bash
    cat ~/.near/validator_key.json | jq .public_key
    ```
    
    `--amount=30` kalian dapat bebas untuk merubah jumlah stake (30 merupakan angka minimum stake pada validator). Sangat dianjurkan untuk menyisakan banyak NEAR untuk keperluan gas. Namun untuk memastikan berapa NEAR yang dibutuhkan, kalian bisa cek seat price di link berikut https://explorer.shardnet.near.org/nodes/validators .


2. Jika sudah selesai, Maka hasilnya seperti Berikut ini

    ![image](https://user-images.githubusercontent.com/100946299/180949409-35e30857-976c-43f1-b32a-3c349fad14ac.png)

3. Cek validators kalian di explorer 
    
    https://explorer.shardnet.near.org/nodes/validators
    


## Transaction Commands

1.  Mengubah Commission Rate
    
    Anda dapat merubah commission rate pada validator anda dengan menggunakan command di bawah ini :
    
    ```bash
    near call <nama wallet anda>.factory.shardnet.near update_reward_fee_fraction '{"reward_fee_fraction": {"numerator": <angka commision rate>, "denominator": 100}}' --accountId <nama wallet anda>.shardnet.near --gas=300000000000000
    ```
    
    
2.  Deposit dan Stake NEAR
    
    ```bash
    near call <nama wallet anda>.factory.shardnet.near deposit_and_stake --amount <jumlah NEAR yang akan kalian stake> --accountId <nama wallet anda>.shardnet.near --gas=300000000000000
    ```
    
    
3.  Unstake NEAR

    Akan memakan waktu 2-3 epoch untuk menyelesaikan proses unstaking. Anda dapat melakukan unstake pada validator dengan menggunakan command dibawah ini :
    
    ```bash
    near call <nama wallet anda>.factory.shardnet.near unstake '{"amount": "<jumlah yoctoNEAR yang akan kalian stake>"}' --accountId <nama wallet anda>.shardnet.near --gas=300000000000000
    ```
    
    sesuaikan jumlah yoctoNEAR yang anda ingin stake di bagian  `<jumlah yoctoNEAR yang akan kalian stake>`
    
    rasio : `1 NEAR = 1000000000000000000000000 yoctoNEAR`
    
    
4.  Withdraw

    Witdrawal baru bisa dilakukan apabila proses unstake sudah selesai. Anda dapat melakukan withdraw pada validator dengan menggunakan command dibawah ini :
    
    ```bash
    near call <nama wallet anda>.factory.shardnet.near withdraw '{"amount": "<jumlah yoctoNEAR yang akan kalian withdraw>"}' --accountId <nama wallet anda>.shardnet.near --gas=300000000000000
    ```
    sesuaikan jumlah yoctoNEAR yang anda ingin stake di bagian  `<jumlah yoctoNEAR yang akan kalian withdraw>`
    
    rasio : `1 NEAR = 1000000000000000000000000 yoctoNEAR`
    
    berikut adalah command untuk withdraw seluruh unstaked NEAR di validator : 
    
    ```bash
    near call <nama wallet anda>.factory.shardnet.near withdraw_all --accountId <nama wallet anda>.shardnet.near --gas=300000000000000
    ```
    
5.  Ping

    Untuk mengupdate laporan dan staked balance untuk delegator anda, maka command ping harus dilakukan. Untuk mengupdate rewards saat ini, ping pun harus dilakukan di setiap epoch. Untuk melakukan ping otomatis dapat dilihat di task-006
    Anda dapat melakukan ping pada validator dengan menggunakaan command dibawah ini : 
    
    ```bash
    near call <nama wallet anda>.factory.shardnet.near ping '{}' --accountId <nama wallet anda>.shardnet.near --gas=300000000000000
    ```
    
    Balances Total Balance Command :

    ```bash
    near view <nama wallet anda>.factory.shardnet.near get_account_total_balance '{"account_id": "<nama wallet anda>.shardnet.near"}'
    ```
    
 
6.  Staked Balance

    Anda dapat melakukan cek staked balance pada validator dengan menggunakaan command dibawah ini :
    
    ```bash
    near view <nama wallet anda>.factory.shardnet.near get_account_staked_balance '{"account_id": "<nama wallet anda>.shardnet.near"}'
    ```
    
7.  Unstaked Balance

    Anda dapat melakukan cek unstaked balance pada validator dengan menggunakaan command dibawah ini :
    
    ```bash
    near view <nama wallet anda>.factory.shardnet.near get_account_unstaked_balance '{"account_id": "<nama wallet anda>.shardnet.near"}'
    ```

8.  Available for Withdrawal

    Anda dapat melakukan cek berapa jumlah token yang dapat anda withdraw pada validator dengan menggunakaan command dibawah ini :
    
    ```bash
    near view <nama wallet anda>.factory.shardnet.near is_account_unstaked_balance_available '{"account_id": "<nama wallet anda>.shardnet.near"}'
    ```

9.  Pause / Resume Staking

    -   Pause Staking Command : 

        ```bash
        near call <nama wallet anda>.factory.shardnet.near pause_staking '{}' --accountId <nama wallet anda>.shardnet.near
        ```
        
    -   Resume Staking Command :

        ```bash
        near call <nama wallet anda>.factory.shardnet.near resume_staking '{}' --accountId <nama wallet anda>.shardnet.near
        ```

## Lanjutkan ke Challenge 004 untuk melakukan monitoring status pada node

[Menjalankan Monitoring Status pada node](https://github.com/cbjohnson90/Testnet-Guides/blob/main/NEAR-StakeWars-III/Tasks/task-004.md)  `(Challenge 004)`
