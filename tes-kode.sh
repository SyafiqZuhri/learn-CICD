#!/bin/bash

# Jalankan aplikasi dan tangkap angka total bayarnya
OUTPUT=$(./aplikasi.sh)
TOTAL_BAYAR=$(echo "$OUTPUT" | grep -oP 'Rp \K[0-9]+')

echo "=== MEMULAI PENGUJIAN OTOMATIS ==="
echo "Total Bayar dari Aplikasi: Rp $TOTAL_BAYAR"

if [ "$TOTAL_BAYAR" -eq 55000 ]; then
    echo "✅ TES BERHASIL: Total bayar sesuai (55000)."
    exit 0
else
    echo "❌ TES GAGAL: Total bayar salah! Seharusnya 55000."
    exit 1
fi
