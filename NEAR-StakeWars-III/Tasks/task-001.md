# Memasang NEAR-CLI `(Challenge 001)`

Di bagian ini, Anda terlebih dahulu menginstal `NEAR-CLI` untuk menjalankan validator nanti, karena memerlukan dompet shardnet yang harus digunakan untuk melakukan transaksi.

1. Update dan Upgrade Software

    ```bash
    sudo apt update && sudo apt upgrade -y
    ```

2. Install Developer Tools, Nodejs dan NPM

    ```bash
    curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -  

    sudo apt install build-essential nodejs

    PATH="$PATH"
    ```
    
   

    
3. Cek versi Nodejs dan NPM
    
    Pastikan versi Nodejs dan NPM kalian sudah berada di versi terbaru, anda dapat menggunakan cara di bawah ini.

    ```bash
    node -v
    ```
     > hasil : v18.6.0

    ```bash
    npm -v
    ```
     > hasil : 8.13.2

    
4. Install NEAR-CLI
    
    ```bash
    sudo npm install -g near-cli
    ```
    
5. Sesuaikan Shardnet sebagai NEAR Environment 

    ```bash
    export NEAR_ENV=shardnet
    ```


    ```bash
    echo 'export NEAR_ENV=shardnet' >> ~/.bashrc
    ```
    
    (gambar)

    
## Controlling Command

- Cek Daftar Proposals
    
    Di bagian ini Anda akan melihat daftar proposal yang diterima atau ditolak (Anda dapat memeriksanya nanti setelah membuat validator).
    
    - Cek daftar seluruh proposals
    
        ```bash
        near proposals
        ```
        
    - Cek daftar proposals secara spesifik

        ```bash
        near proposals | grep <nama wallet anda>.factory.shardnet.near
        ```
        
- Cek Daftar Validators Yang Aktif
    
    - Cek daftar seluruh validators aktif
    
        ```bash
        near validators current
        ```
        
    - Cek daftar validators secara spesifik

        ```bash
        near validators current | grep xx.factory.shardnet.near
        ```
- Cek Daftar Validators Next atau  Validators yang Proposalnya sudah diterima dan akan aktif di epoch selanjutnya
    
    - Cek daftar seluruh validators next
    
        ```bash
        near validators next
        ```
        
    - Cek daftar validators next secara spesifik

        ```bash
        near validators next | grep xx.factory.shardnet.near
        ```


## Setelah selesai memasang NEAR-CLI, anda dapat lanjut ke challenge 002

[Menjalankan Validator, dan Setup Wallet](https://github.com/cbjohnson90/Testnet-Guides/blob/main/NEAR-StakeWars-III/Tasks/task-002.md)

## Explorers
Wallet: https://wallet.shardnet.near.org/

Explorer: https://explorer.shardnet.near.org/