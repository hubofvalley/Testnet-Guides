# KiteAI Storage Node Guide

Panduan ini menjelaskan cara setup dan menjalankan Storage Node untuk KiteAI, menyesuaikan dengan pola dokumentasi node pada project lain.

## Prasyarat

- Docker & Docker Compose
- Python 3.11+ (untuk pengembangan lokal)
- Koneksi internet stabil

## Langkah Instalasi

1. Clone repository dan masuk ke direktori KiteAI:
   ```bash
   git clone https://github.com/your-org/kiteai.git
   cd kiteai
   ```

2. Salin file environment:
   ```bash
   cp .env.example .env
   ```

3. Jalankan storage node dengan Docker Compose:
   ```bash
   docker compose up --build
   ```

4. Data storage akan tersimpan di folder `data/` (atau sesuai variabel `KITEAI_DATA_DIR`).

## Konfigurasi

- Semua konfigurasi dapat diatur melalui file `.env`.
- Variabel penting:
  - `KITEAI_DATA_DIR` — direktori data storage
  - `KITEAI_SNAPSHOT_URL` — URL snapshot untuk restore data

## Snapshot

Untuk mengaplikasikan snapshot pada storage node:
```bash
bash resources/apply_snapshot.sh
```
Pastikan variabel `KITEAI_SNAPSHOT_URL` sudah diisi di `.env`.

## Monitoring

- Cek status node: lihat log Docker Compose atau endpoint `/health` pada API.
- Untuk pengujian, gunakan perintah:
  ```bash
  curl http://localhost:8000/health
  ```

## Troubleshooting

- Pastikan port 8000 tidak digunakan aplikasi lain.
- Cek log error pada container dengan:
  ```bash
  docker compose logs api
  ```

## Referensi

- [KiteAI README](../README.md)
- [apply_snapshot.sh](../resources/apply_snapshot.sh)