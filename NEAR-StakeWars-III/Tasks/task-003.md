## Mount Staking Pool `(Challenge 003)`

1. Membuat Staking Pool Contract

    ```bash
    near call factory.shardnet.near create_staking_pool '{"staking_pool_id": "nama_wallet", "owner_id": "xx.shardnet.near", "stake_public_key": "public_key_kamu", "reward_fee_fraction": {"numerator": 5, "denominator": 100}, "code_hash":"DD428g9eqLL8fWUxv8QSpVFzyHi1Qd16P8ephYCTmMSZ"}' --accountId="<nama wallet kalian>.shardnet.near" --amount=30 --gas=300000000000000
    ```
 
    `public_key_kamu` ganti dengan `public_key` wallet kalian menggunakan command dibawah ini.
    
    ```bash
    cat ~/.near/validator_key.json | jq .public_key
    ```
    
    `--amount=30` kalian bisa ubah jumlah stake NEAR kalian dari 30 ke berapapun yang kalian mau (karena 30 adalah minimum stakenya), 1 wallet memiliki 500 NEAR tapi lebih baik kalian sisakan NEAR (lebih banyak lebih baik) untuk membayar gas fee nantinya. Namun untuk memastikan berapa NEAR yang dibutuhkan, kalian bisa cek seat price [disini](https://explorer.shardnet.near.org/nodes/validators).


2. Jika sudah selesai, Maka hasilnya seperti Berikut ini

    (gambar)

3. Cek validators kalian di explorer 
    
    https://explorer.shardnet.near.org/nodes/validators


## Lanjutkan ke Challenge 004 untuk melakukan monitoring status pada node

[Menjalankan Monitoring Status pada node]()
