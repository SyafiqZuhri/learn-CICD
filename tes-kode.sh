#!/bin/bash
echo "🔍 [CI STEP] Memulai Pengujian Otomatis Fitur Cek Resi Anteraja..."

# Simulasikan robot memeriksa apakah ada fungsi pelacakan resi di dalam kode
if grep -q "cek-resi" server.js; then
    echo "✅ [SUCCESS] Fitur Cek Resi ditemukan dan lolos uji standardisasi!"
    exit 0
else
    echo "❌ [FAILED] EROR CRITICAL: Fungsi 'cek-resi' tidak ditemukan di server.js!"
    echo "🚨 [ALERT] Menghentikan otomatis seluruh proses! Pembaruan ditolak demi keamanan operasional Gudang Anteraja!"
    exit 1
fi
