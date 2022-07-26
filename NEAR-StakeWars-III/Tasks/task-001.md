# Memasang NEAR-CLI `(Challenge 001)`

Di bagian ini, Anda terlebih dahulu menginstal `NEAR-CLI` untuk menjalankan validator nanti, karena memerlukan dompet shardnet yang harus digunakan untuk melakukan transaksi.

1. Update dan Upgrade Software

    ```bash
    sudo apt update && sudo apt upgrade -y
    ```

    ![image](https://user-images.githubusercontent.com/100946299/180929617-adde64f6-1781-4db7-bdfd-1be32829496d.png)


2. Install Developer Tools, Nodejs dan NPM

    ```bash
    curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -  

    sudo apt install build-essential nodejs

    PATH="$PATH"
    ```
    
    ![image](https://user-images.githubusercontent.com/100946299/180929753-38797e51-b239-4590-b9e6-3eb5bf1c1a23.png)


    
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
    
    ![image](https://user-images.githubusercontent.com/100946299/180929815-f4fdb3bd-10ac-44f6-a0ae-2f613a50e472.png)

    
5. Sesuaikan Shardnet sebagai NEAR Environment 

    ```bash
    export NEAR_ENV=shardnet
    ```


    ```bash
    echo 'export NEAR_ENV=shardnet' >> ~/.bashrc
    ```
    
    ![image](https://user-images.githubusercontent.com/100946299/180929925-6910e207-5531-4e65-a842-e428b565aff6.png)


    
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
        near validators current | grep <nama wallet anda>.factory.shardnet.near
        ```
- Cek Daftar Validators Next atau  Validators yang Proposalnya sudah diterima dan akan aktif di epoch selanjutnya
    
    - Cek daftar seluruh validators next
    
        ```bash
        near validators next
        ```
        
    - Cek daftar validators next secara spesifik

        ```bash
        near validators next | grep <nama wallet anda>.factory.shardnet.near
        ```


## Setelah selesai memasang NEAR-CLI, anda dapat lanjut ke challenge 002

[Menjalankan Validator, dan Setup Wallet](https://github.com/cbjohnson90/Testnet-Guides/blob/main/NEAR-StakeWars-III/Tasks/task-002.md) `(Challenge 002)`

## Explorers
Wallet: https://wallet.shardnet.near.org/

Explorer: https://explorer.shardnet.near.org/
