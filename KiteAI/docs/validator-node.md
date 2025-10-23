# KiteAI Validator Node Guide

Panduan ini menjelaskan cara setup dan menjalankan Validator Node untuk KiteAI, menyesuaikan dengan pola dokumentasi node pada project lain.

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

3. Jalankan validator node dengan Docker Compose:
   ```bash
   docker compose up --build
   ```

4. Validator node akan berjalan pada port yang diatur di `.env` (`KITEAI_API_PORT`).

## Konfigurasi

- Semua konfigurasi dapat diatur melalui file `.env`.
- Variabel penting:
  - `KITEAI_API_PORT` — port API validator
  - `KITEAI_SECRET_KEY` — secret untuk autentikasi/keamanan

## Update & Maintenance

Untuk update validator node:
```bash
bash resources/update.sh
```

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
- [update.sh](../resources/update.sh)