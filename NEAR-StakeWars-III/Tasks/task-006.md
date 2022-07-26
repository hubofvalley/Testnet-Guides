# Menjalankan Ping Secara Otomatis Per 2 Jam Sekali
Disini kalian akan menjalankan ping otomatis tiap 2 jam sekali

1. Membuat folder log dan file ping.sh

    ```bash
    mkdir $HOME/nearcore/logs
    ```
    ```
    nano $HOME/nearcore/scripts/ping.sh
    ```
 2. Edit PoolId dan AccountId
    
    `<nama wallet anda> : hanya nama wallet anda tanpa .shardnet.near atau .factory.shardnet.near`
    
    ```bash
    #!/bin/sh
    # Ping call to renew Proposal added to crontab

    export NEAR_ENV=shardnet
    export LOGS=$HOME/nearcore/logs
    export POOLID="<nama wallet kalian>"
    export ACCOUNTID="<nama wallet kalian>"

    echo "---" >> $LOGS/all.log
    date >> $LOGS/all.log
    near call $POOLID.factory.shardnet.near ping '{}' --accountId $ACCOUNTID.shardnet.near --gas=300000000000000 >> $LOGS/all.log
    near proposals | grep $POOLID >> $LOGS/all.log
    near validators current | grep $POOLID >> $LOGS/all.log
    near validators next | grep $POOLID >> $LOGS/all.log
    ```
    `setelah selesai edit PoolId dan AccountId, save filenya dengan cara pencet CTRL+O lalu CTRL+X`
    
 3. Buka Crontab
    
    ```bash
    crontab -e
    ```
    
 4. Masukkan angka 1
 5. Set skala waktu ping per 2 jam
      
    ```bash
    0 */2 * * * sh $HOME/nearcore/scripts/ping.sh
    ```
    `setelah selesai Set skala waktu ping per 2 jam, save filenya dengan cara pencet CTRL+O lalu CTRL+X`
   
 6. Cek log
    
    ```bash
    cat $HOME/nearcore/logs/all.log
    ```
    
 submit form : https://docs.google.com/forms/d/e/1FAIpQLScp9JEtpk1Fe2P9XMaS9Gl6kl9gcGVEp3A5vPdEgxkHx3ABjg/viewform
