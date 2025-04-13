# Node Setup NEAR Stake Wars: Episode III  
_A New Validator Complete Guide (Bahasa Indonesia)_

![image](https://user-images.githubusercontent.com/100946299/180820007-7114510b-0c25-40cf-bc52-9d1534901156.png)

---

## Spesifikasi Minimum

Sebelum mempersiapkan node, pastikan device/server memenuhi spesifikasi minimum berikut:

| Hardware | Spesifikasi   |
|----------|--------------|
| CPU      | 4-Core CPU   |
| RAM      | 8GB DDR4     |
| Storage  | 500GB SSD    |

---

## Setup VPS

Sebelum menjalankan tugas node StakeWars-III, kalian dapat membuat VPS sesuai persyaratan di [DigitalOcean](https://www.digitalocean.com/?refcode=3e669f831302&utm_campaign=Referral_Invite&utm_medium=Referral_Program&utm_source=badge).  
Bagi pengguna baru, biasanya belum bisa pakai droplet/VPS yang besar, jadi harus request dulu. Pilih VPS di region dengan spek yang sesuai (contoh: Storage Optimized, RAM 32GB/4CPUs, 600GB NVMe SSDs, 6TB Transfer, $262/month, $0.390/hour).

---

## Challenges

Challenges pada event StakeWars-Episode-III memiliki tingkat kesulitan dan poin yang variatif.  
Sebelum menjalankan node, kalian harus mengisi form [Chunk-Only Producer Onboarding Form](https://nearprotocol1001.typeform.com/to/Z39N7cU9).  
Pada bagian ID, isi dengan email kalian.

| Nomor Challenge | Deskripsi | Poin Maksimum | Deadline | Link Tutorial |
|-----------------|-----------|---------------|----------|---------------|
| 001 | Memasang NEAR CLI | - | 7 September 2022 | [task-001](https://github.com/cbjohnson90/Testnet-Guides/blob/main/NEAR-StakeWars-III/Tasks/task-001.md) |
| 002 | Menjalankan Validator, dan Setup Wallet | 30 UNP | 7 September 2022 | [task-002](https://github.com/cbjohnson90/Testnet-Guides/blob/main/NEAR-StakeWars-III/Tasks/task-002.md) |
| 003 | Mount Staking Pool | 10 UNP | 7 September 2022 | [task-003](https://github.com/cbjohnson90/Testnet-Guides/blob/main/NEAR-StakeWars-III/Tasks/task-003.md) |
| 004 | Menjalankan Monitoring Status pada node | 15 UNP | 7 September 2022 | [task-004](https://github.com/cbjohnson90/Testnet-Guides/blob/main/NEAR-StakeWars-III/Tasks/task-004.md) |
| 005 | Membuat guide / tutorial Stakewars III | 10 UNP | 7 September 2022 |  |
| 006 | Menjalankan Ping Secara Otomatis Per 2 Jam Sekali | 5 UNP | 7 September 2022 | [task-006](https://github.com/cbjohnson90/Testnet-Guides/blob/main/NEAR-StakeWars-III/Tasks/task-006.md) |
| 007 | Membuat output berupa data science dari data staking | 30 DNP, 50 UNP, 200 USD in $LiNEAR untuk submission terbaik | 7 September 2022 |  |
| 008 | Pembagian hasil staking | 30 DNP, 50 UNP | 7 September 2022 |  |
| 009 | Memonitor Uptime di shardnet scoreboard | 15 UNP | 7 September 2022 |  |
| 010 | Delegasi token dari dev untuk uptime >= 60% | - | 7 September 2022 |  |
| 011 | Staking Farm 2.0 | 30 DNP, 50 UNP, 200 USD in $LiNEAR untuk submission terbaik | 7 September |  |
| 012 | - | - | 7 September 2022 |  |
| 013 | Menjalankan backup node | 25 UNP, 10 DNP | 11 Agustus 2022 |  |
| 014 | Menjalankan Auto-backup script | 15 DNP | 7 September 2022 |  |
| 015 | Menjalankan Kuutamo Service | 10 DNP | 7 September 2022 |  |
| 016 | - | - | 7 September 2022 |  |
| 017 | Menjalankan Validator di jaringan akash | (Testnet Bounty) 100 USD in $LiNEAR untuk 3 submission terbaik | 7 September 2022 |  |
| 018 | Membuat video tutorial mengenai StakeWars III | 50 UNP, 200 USD in $LiNEAR untuk submission terbaik | 7 September 2022 |  |

---

```text
1 UNP (UNLOCKED NEAR POINTS) = 1 NEAR
1 DNP (DELEGATED NEAR POINTS) = 500 NEAR DELEGATED YOUR MAINNET VALIDATOR
