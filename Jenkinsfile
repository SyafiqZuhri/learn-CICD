pipeline {
    agent any 

    stages {
        stage('Persiapan') {
            steps {
                echo 'Menarik kode terbaru dari GitHub...'
            }
        }
        
        stage('Build Aplikasi') {
            steps {
                echo 'Membangun aplikasi...'
                // Simulasi membuat file hasil rakitan aplikasi
                sh 'echo "Ini adalah file rilis aplikasi logistik versi 1.0" > aplikasi-logistik.txt'
            }
        }
        
        stage('Simpan Artefak') {
            steps {
                echo 'Menyimpan hasil build ke brankas Jenkins...'
                // Perintah untuk mengarsipkan file agar bisa didownload
                archiveArtifacts artifacts: 'aplikasi-logistik.txt', followSymlinks: false
            }
        }
    }
}
