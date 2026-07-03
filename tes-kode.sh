#!/bin/bash

OUTPUT=$(./aplikasi.sh)
TOTAL_BAYAR=$(echo "$OUTPUT" | grep -oP 'Rp \K[0-9]+')

echo "🚀 [ROBOT MEMULAI PENGETESAN KODE] 🚀"
echo "Total Bayar dari Aplikasi: Rp $TOTAL_BAYAR"

if [ "$TOTAL_BAYAR" -eq 55000 ]; then
    echo "✅ TES BERHASIL: Rumus sudah benar (55000)!"
    exit 0
else
    echo "❌ TES GAGAL: Rumus salah hitung! Jangan deploy ke server!"
    exit 1
fi
