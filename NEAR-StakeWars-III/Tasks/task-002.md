# Menjalankan Validator, dan Setup Wallet `(Challenge 002)`

Pastikan server/device/VPS yang anda gunakan untuk menjalankan validator sudah memenuhi syarat minimum, agar nantinya validator dapat berjalan dengan lancar.

1. Cek Kelayakan Spesifikasi VPS

    ```bash
    lscpu | grep -P '(?=.*avx )(?=.*sse4.2 )(?=.*cx16 )(?=.*popcnt )' > /dev/null \
    && echo "Supported" \
    || echo "Not supported"
    ```
    
    (gambar)

    
    apabila responnya "Supported" maka VPS anda dapat menjalankan untuk validator StakeWars-III, namun apabila responnya "Not supported" maka VPS anda tidak layak digunakan untuk menjalankan validator StakeWars-III
    
2. Install Developer Tools

    Developer Tools diperlukan untuk menjalankan perintah-perintah yang diperlukan dalam menjalankan validator.

    ```bash
    sudo apt install -y git binutils-dev libcurl4-openssl-dev zlib1g-dev libdw-dev libiberty-dev cmake gcc g++ python docker.io protobuf-compiler libssl-dev pkg-config clang llvm cargo
    ```
    
    (gambar)

    
3. Install Python pip

    ```bash
    sudo apt install python3-pip
    ```
    
    ![Screenshot_9](https://user-images.githubusercontent.com/35837931/180378558-467b3b50-7970-43bc-b2bd-e047b8e7786b.png)


4. Sesuaikan Konfigurasi
    
    ```bash
    USER_BASE_BIN=$(python3 -m site --user-base)/bin
    export PATH="$USER_BASE_BIN:$PATH"
    ```
    
    (gambar)


5. Install Building Environment

    ```bash
    sudo apt install clang build-essential make
    ```
    
    (gambar)

    

6. Install Rust dan Cargo

    ```bash
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    ```
    
    (gambar)
    
    pencet y lalu enter
    
    (gambar)
    
    masukkan angka 1 lalu enter

7. Source the Environment

    ```bash
    source $HOME/.cargo/env
    ```
    
    (gambar)


## Klon `nearcore` Project

1. Clone Repository

    ```bash
    git clone https://github.com/near/nearcore
    cd nearcore
    git fetch
    ```
    
    
2. Checkout Commit

    ```bash
    git checkout 0f81dca95a55f975b6e54fe6f311a71792e21698
    ```
    
    (gambar)
    
    
3. Compile `nearcore` Binary

    Pastikan kalian posisinya masih didalam folder `nearcore`.
    
    ```bash
    cargo build -p neard --release --features shardnet
    ```
    
    (gambar)

    Di langkah "Compile `nearcore` Binary" ini akan memakan waktu yang lumayan banyak (estimasi saya adalah 30-35 menit). Namun hal tersebut tergantung dengan spesifikasi VPS yang anda gunakan 
    
4. Initialize Working Directory
    
    - Delete old `genesis.json` (apabila sebelumnya sudah pernah menjalankan node StakeWars)

        ```bash
        rm ~/.near/genesis.json
        ```
        
    - Download new `genesis.json`
    
        ```bash
        ./target/release/neard --home ~/.near init --chain-id shardnet --download-genesis
        ```
        
        (gambar)
        
    - Memasang Snapshot `(Optional)`
        
        Install `AWS-CLI`
        
        ```bash
        sudo apt-get install awscli -y
        ```
        
        Hapus `genesis.json` sebelumnya lalu download ulang file `genesis.json`
        
        ```bash
        rm ~/.near/genesis.json
        wget -O ~/.near/genesis.json https://s3-us-west-1.amazonaws.com/build.nearprotocol.com/nearcore-deploy/shardnet/genesis.json
        ```

    
5. Replace `config.json`

    ```bash
    rm ~/.near/config.json
    wget -O ~/.near/config.json https://s3-us-west-1.amazonaws.com/build.nearprotocol.com/nearcore-deploy/shardnet/config.json
    
    ```
    
    (gambar)

    
6. Jalankan Node

   Kalian harus menunggu proses mendownload headers beres (mencapai 100%). Karena node belum berjalan di didalam sistem (masih dari terminal), maka tab terminal tidak boleh sampai tertutup sampai proses download header selesai.

    ```bash
    cd ~/nearcore
    ./target/release/neard --home ~/.near run
    ```
    
    (gambar)

    
    Saat proses download header sudah 100% ( `EpochId(`11111111111111111111111111111111`)` berubah menjadi tulisan yang berbeda ), matikan node menggunakan `CTRL+C` supaya tidak terjadi konflik/masalah pada saat pembuatan service nanti.
    
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

    (gambar)


3. Create wallet (Buat wallet)

    (gambar)



4. Enter wallet name (masukkan nama wallet)

    (gambar)


5. Simpan Phrase dan Verify Phrase

    (gambar)


6. Lalu masukkan Phrase yang sudah disimpan tadi


7. Klik Next dan Beri akses ke `NEAR-CLI` dengan klik `connect`


    (gambar)
    
    
8. Masukkan `Account ID` anda lalu pencet confirm (contoh : <nama wallet anda>.shardnet.near).


    (gambar)



9. Setelah Memberi Akses, Kalian akan melihat gambar berikut.


    (gambar)


    Apabila sudah terlihat seperti di gambar di atas, maka anda sudah berhasil memberi akses wallet anda ke NEAR-CLI
    
10. Masukkan `Account ID` yang telah anda buat ke dalam VPS lalu tekan enter

    (gambar)


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

## Lanjutkan ke Challenge 003 untuk melakukan Mount Staking Pool

[Mount Staking Pool]()
