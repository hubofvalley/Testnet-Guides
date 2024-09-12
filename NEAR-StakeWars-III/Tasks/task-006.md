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
   near call $POOLID.factory.shardnet.near ping '{}' --accountId $ACCOUNTID.shardnet.near --gas=30000000000000 --node_url http://127.0.0.1:3030/ >> $LOGS/all.log
   near proposals | grep $POOLID >> $LOGS/all.log
   near validators current | grep $POOLID >> $LOGS/all.log
   near validators next | grep $POOLID >> $LOGS/all.log
   ```

   `setelah selesai edit PoolId dan AccountId, save filenya dengan cara pencet CTRL+O lalu CTRL+X`

3. Ganti execute permission file ping.sh

   ```bash
   chmod +x $HOME/scripts/ping.sh
   ```

4. Buka Crontab

   ```bash
   crontab -e
   ```

5. Masukkan angka 1
6. Set skala waktu ping per 2 jam

   ```bash
   0 */2 * * * sh $HOME/nearcore/scripts/ping.sh
   ```

   `setelah selesai Set skala waktu ping per 2 jam, save filenya dengan cara pencet CTRL+X lalu "y" lalu "enter"

7. Cek log

   ```bash
   cat $HOME/nearcore/logs/all.log
   ```

8. Cek crontab

   ```bash
   crontab -l
   ```

   ![image](https://user-images.githubusercontent.com/100946299/183812181-bd9b7f33-3033-4f93-ae43-e5f5ef3363c8.png)

submit form : https://docs.google.com/forms/d/e/1FAIpQLScp9JEtpk1Fe2P9XMaS9Gl6kl9gcGVEp3A5vPdEgxkHx3ABjg/viewform
