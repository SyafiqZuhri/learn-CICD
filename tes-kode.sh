#!/bin/bash
echo "🧪 [ROBOT MEMULAI PENGETESAN KODE] 🧪"

# Ambil rumus dari file aplikasi.sh
source ./aplikasi.sh > /dev/null

# Robot mengecek: Apakah total bayarnya benar 55.000?
if [ $TOTAL_BAYAR -eq 55000 ]; then
    echo "✅ TES SUKSES: Rumus matematika di aplikasi benar!"
    exit 0
else
    echo "❌ TES GAGAL: Rumus salah hitung! Jangan deploy ke server!"
    exit 1
fi
