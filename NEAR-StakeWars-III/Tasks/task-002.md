# Menjalankan Validator, dan Setup Wallet `(Challenge 002)`

Pastikan server/device/VPS yang anda gunakan untuk menjalankan validator sudah memenuhi syarat minimum, agar nantinya validator dapat berjalan dengan lancar.

1. Cek Kelayakan Spesifikasi VPS

    ```bash
    lscpu | grep -P '(?=.*avx )(?=.*sse4.2 )(?=.*cx16 )(?=.*popcnt )' > /dev/null \
    && echo "Supported" \
    || echo "Not supported"
    ```
    
    ![image](https://user-images.githubusercontent.com/100946299/180930082-8c30d579-dd2c-4c57-9f15-aaee6d267cd2.png)

    
    apabila responnya "Supported" maka VPS anda dapat menjalankan untuk validator StakeWars-III, namun apabila responnya "Not supported" maka VPS anda tidak layak digunakan untuk menjalankan validator StakeWars-III
    
2. Install Developer Tools

    Developer Tools diperlukan untuk menjalankan perintah-perintah yang diperlukan dalam menjalankan validator.

    ```bash
    sudo apt install -y git binutils-dev libcurl4-openssl-dev zlib1g-dev libdw-dev libiberty-dev cmake gcc g++ python docker.io protobuf-compiler libssl-dev pkg-config clang llvm cargo
    ```
    
    ![image](https://user-images.githubusercontent.com/100946299/180930160-b96a3198-9c65-400b-991c-3b6d8e462e38.png)

    
3. Install Python pip

    ```bash
    sudo apt install python3-pip
    ```
    
    ![image](https://user-images.githubusercontent.com/100946299/180930221-6d3ab673-3013-4ff5-a629-33cd165f69dc.png)


4. Sesuaikan Konfigurasi
    
    ```bash
    USER_BASE_BIN=$(python3 -m site --user-base)/bin
    export PATH="$USER_BASE_BIN:$PATH"
    ```
    
    ![image](https://user-images.githubusercontent.com/100946299/180930273-e181f84f-2b6f-43b6-97ba-f0507458cad2.png)


5. Install Building Environment

    ```bash
    sudo apt install clang build-essential make
    ```
    
    ![image](https://user-images.githubusercontent.com/100946299/180930314-3f54ff8b-8b26-46bf-bb00-c1ac6500cb8e.png)

    

6. Install Rust dan Cargo

    ```bash
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    ```
    
    ![image](https://user-images.githubusercontent.com/100946299/180930374-c3af5ef6-7afe-4a86-bdee-620b501e7be7.png)
    
    pencet y lalu enter
    
    ![image](https://user-images.githubusercontent.com/100946299/180930437-9f98b79e-b8be-40e7-8660-86c35aca10b4.png)
    
    masukkan angka 1 lalu enter

7. Source the Environment

    ```bash
    source $HOME/.cargo/env
    ```
    
    ![image](https://user-images.githubusercontent.com/100946299/180930580-76ecb3a0-d023-4646-990f-2f3cb2f0f185.png)


## Klon `nearcore` Project

1. Clone Repository

    ```bash
    git clone https://github.com/near/nearcore
    cd nearcore
    git fetch
    ```
    
    ![image](https://user-images.githubusercontent.com/100946299/180930690-389b1691-6c1d-428c-b460-21650b837a61.png)

    
2. Checkout Commit

    ```bash
    git checkout 0f81dca95a55f975b6e54fe6f311a71792e21698
    ```
    
    ![image](https://user-images.githubusercontent.com/100946299/180930757-a0665329-ce4c-4d58-aa6c-ceef33cca8e9.png)
    
    
3. Compile `nearcore` Binary

    Pastikan kalian posisinya masih didalam folder `nearcore`.
    
    ```bash
    cargo build -p neard --release --features shardnet
    ```
    
    ![image](https://user-images.githubusercontent.com/100946299/180930961-8e5f1e15-b899-4229-8e4d-d8c21f482397.png)
    ![image](https://user-images.githubusercontent.com/100946299/180932520-3d20cc33-f13d-4fa7-b8e3-7de56da88c94.png)


    Di langkah "Compile `nearcore` Binary" ini akan memakan waktu yang lumayan banyak (estimasi saya adalah 20 menitan). Namun hal tersebut tergantung dengan spesifikasi VPS yang anda gunakan 
    
4. Initialize Working Directory
    
    - Delete old `genesis.json` (apabila sebelumnya sudah pernah menjalankan node StakeWars)

        ```bash
        rm ~/.near/genesis.json
        ```
        
    - Download new `genesis.json`
    
        ```bash
        ./target/release/neard --home ~/.near init --chain-id shardnet --download-genesis
        ```
        
        ![image](https://user-images.githubusercontent.com/100946299/180932668-2a7b76ff-b483-4f2c-9e85-49ad44ffef3f.png)
        
    - Memasang Snapshot `(Optional)`
        
        Install `AWS-CLI`
        
        ```bash
        sudo apt-get install awscli -y
        ```
        
        ![image](https://user-images.githubusercontent.com/100946299/180932717-deb9a4a0-f709-4fab-8dc5-22ea1205dc29.png)

        
        Hapus `genesis.json` sebelumnya lalu download ulang file `genesis.json`
        
        ```bash
        rm ~/.near/genesis.json
        wget -O ~/.near/genesis.json https://s3-us-west-1.amazonaws.com/build.nearprotocol.com/nearcore-deploy/shardnet/genesis.json
        ```
        ![image](https://user-images.githubusercontent.com/100946299/180932817-1c247943-a0de-4d08-9ca4-7bc460218cfd.png)

    
5. Replace `config.json`

    ```bash
    rm ~/.near/config.json
    wget -O ~/.near/config.json https://s3-us-west-1.amazonaws.com/build.nearprotocol.com/nearcore-deploy/shardnet/config.json
    
    ```
    
    ![image](https://user-images.githubusercontent.com/100946299/180932877-8d1b743d-fb51-46f4-a6d1-6829483f17ad.png)

    
6. Jalankan Node

   Kalian harus menunggu proses mendownload headers beres (mencapai 100%). Karena node belum berjalan di didalam sistem (masih dari terminal), maka tab terminal tidak boleh sampai tertutup sampai proses download header selesai.

    ```bash
    cd ~/nearcore
    ./target/release/neard --home ~/.near run
    ```
    
    ![image](https://user-images.githubusercontent.com/100946299/180932970-7369c437-30ba-4b7c-8244-f7f566ced740.png)
    ![image](https://user-images.githubusercontent.com/100946299/180933662-26416b60-3cbd-4105-a4ea-384c8af2241f.png)
    ![image](https://user-images.githubusercontent.com/100946299/180943388-23d044c7-ac32-4c02-b0b3-c72119fbae95.png)
    ![image](https://user-images.githubusercontent.com/100946299/180943434-423b5123-7e3d-412e-82a4-6e196d40ab4a.png)


    
    Saat proses download header sudah 100% ( `EpochId(`11111111111111111111111111111111`)` berubah menjadi tulisan yang berbeda ), matikan node menggunakan `CTRL+C` supaya tidak terjadi konflik/masalah pada saat pembuatan service nanti. Agak lama prosesnya jadi sabar ya.
    
7. Membuat Service
   
    - Menggunakan command `vi` :

       ```bash
       sudo vi /etc/systemd/system/neard.service
       ```
       Lalu masukkan kode berikut ini :
       
        ```bash
        [Unit] 
        Description=NEARd Daemon Service 
        [Service] 
        Type=simple 
        User=$USER
        #Group=near 
        WorkingDirectory=$HOME/.near
        ExecStart=$HOME/nearcore/target/release/neard run 
        Restart=on-failure 
        RestartSec=30 
        KillSignal=SIGINT 
        TimeoutStopSec=45 
        KillMode=mixed 
        [Install] 
        WantedBy=multi-user.target
        ```
        Kemudian tekan `ESC` dan ketik `:wq` `enter`.

    **Atau**

    - Menggunakan command `tee` :

        ```bash
        sudo tee /etc/systemd/system/neard.service > /dev/null <<EOF 
        [Unit] 
        Description=NEARd Daemon Service 
        [Service] 
        Type=simple 
        User=$USER
        #Group=near 
        WorkingDirectory=$HOME/.near
        ExecStart=$HOME/nearcore/target/release/neard run 
        Restart=on-failure 
        RestartSec=30 
        KillSignal=SIGINT 
        TimeoutStopSec=45 
        KillMode=mixed 
        [Install] 
        WantedBy=multi-user.target 
        EOF
        ```
    
8. Aktifkan Service

    ```bash
    sudo systemctl daemon-reload
    sudo systemctl enable neard
    sudo systemctl start neard
    
    apabila anda mengalami error pada service, kalian bisa memasukkan perintah berikut :
    sudo systemctl reload neard
    ```

9. Cek Log

    ```bash
    journalctl -n 100 -f -u neard
    ```
    Apabila kalian ingin menampilkan log dengan lebih jelas dengan warna yang variatif, kalian dapat menginstall `ccze` menggunakan command dibawah ini.
    
    ```bash
    sudo apt install ccze
    ```
    
    Lalu masukkan command di bawah ini untuk cek log menggunakan `ccze`
    
    ```bash
    journalctl -n 100 -f -u neard | ccze -A
    ```

## Connect Wallet ke NEAR-CLI dan Generate Validator Key

Anda perlu memasukkan shardnet wallet kalian untuk menjalankan validatornya dengan menggunakan perintah di bawah ini :

1. Autorisasi wallet

    ```bash
    near login
    ```
2. Copy Link Autorisasi Wallet ke Browser anda

    ![image](https://user-images.githubusercontent.com/100946299/180943925-0dae8509-a5b0-499b-b6a2-1e3d27f14ea8.png)


3. Create wallet (Buat wallet)

    ![image](https://user-images.githubusercontent.com/100946299/180944382-0712110c-11a0-433b-86e4-f6e66ef9d5ca.png)



4. Enter wallet name (masukkan nama kalian)

    ![image](https://user-images.githubusercontent.com/100946299/180944498-4ee4bdd4-607b-443b-8feb-5a573955eea8.png)


5. Simpan Phrase dan Verify Phrase

6. Lalu masukkan Phrase yang sudah disimpan tadi

7. Klik Next dan Beri akses ke `NEAR-CLI` dengan klik `connect`


    ![image](https://user-images.githubusercontent.com/100946299/180947037-6a249515-2a19-482d-861a-a61c7e786203.png)
    
    
8. Masukkan `Account ID` anda lalu pencet confirm (contoh : <nama wallet anda>.shardnet.near).


    ![image](https://user-images.githubusercontent.com/100946299/180947136-5ab91193-3b07-404d-bff1-10ad1bc468e3.png)



9. Setelah Memberi Akses, Kalian akan melihat gambar berikut.


    ![image](https://user-images.githubusercontent.com/100946299/180947260-278943c5-dcb9-465c-9724-f517acfb58a5.png)


    Apabila sudah terlihat seperti di gambar di atas, maka anda sudah berhasil memberi akses wallet anda ke NEAR-CLI
    
10. Masukkan `Account ID` yang telah anda buat ke dalam VPS lalu tekan enter

    ![image](https://user-images.githubusercontent.com/100946299/180947842-e42f090d-b5d7-471f-a4a6-8a7542d19868.png)


11. Generate Key untuk `validator_key.json`
    
    ```bash
    near generate-key <nama wallet kalian>.factory.shardnet.near
    ```

12. Pindahkan file `validator_key.json` ke directory `.near`
    
    ```bash
    cp ~/.near-credentials/shardnet/<nama wallet kalian>.factory.shardnet.near.json ~/.near/validator_key.json
    ```
    
13. Ganti kata `private_key` ke `secret_key` di dalam file `validator_key.json`

    ```bash
    nano ~/.near/validator_key.json
    ```
    
    Lalu tekan `CTRL + O` dan `CTRL + X`
    
14. Simpan file `node_key.json` dan `validator_key.json` bertujuan untuk membackup node yang sudah anda deploy. Mencegah apabila di kemudian hari VPS anda mati, jadi anda dapat menjalankan node nya di VPS yang berbeda
    - Simpan atau copy isi file `node_key.json`
    
        ```bash
        nano ~/.near/node_key.json
        ```
    
    - Simpan atau copy isi file `validator_key.json`

        ```bash
        nano ~/.near/validator_key.json
        ```
        
#### PENTING!!! Syarat untuk menjadi Validator
Terdapat kriteria keberhasilan untuk menjadi Validator yang aktif. Untuk melihat kriteria keberhasilan menjadi validator secara kesuluruhan, anda dapat membuka official link NEAR 

* Node harus sudah dalam full sinkron.
* `validator_key.json` harus ditempatkan yang benar.
* Kontrak validator harus sama dengan `public_key` di `validator_key.json`
* `account_id` harus disetel ke contract id staking pool
* Harus ada delegasi yang cukup untuk memenuhi jumlah seat minimum. Lihat jumlah seat [disini](https://explorer.shardnet.near.org/nodes/validators).
* Proposal harus sudah diajukan dengan melakukan ping ke contract validator kalian.
* Setelah Proposal disetujui (accepted) validators  harus menunggu 2-3 epoch untuk menjadi validator aktif.
* Setelah menjadi validator, validator harus menghasilkan lebih dari 90% block yang ditugaskan.

Cek running status dari validator node. Jika `Validator` sudah muncul, maka pool sudah terpilih didalam validators list saat ini.

## Lanjutkan ke Challenge 003 untuk melakukan Mount Staking Pool `(Challenge 003)`

[Mount Staking Pool](https://github.com/cbjohnson90/Testnet-Guides/blob/main/NEAR-StakeWars-III/Tasks/task-003.md)  `(Challenge 003)`
