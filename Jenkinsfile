pipeline {
    agent any 

    stages {
        stage('Persiapan') {
            steps {
                echo 'Memulai pipeline...'
            }
        }
        
        // --- INI PEMBARUAN KECIL KITA (SIMULASI ERROR) ---
        stage('Unit Testing') {
            steps {
                echo 'Menjalankan pengetesan kode...' 
            }
        }
        // -------------------------------------------------
        
        stage('Deploy ke Server') {
            steps {
                echo 'Langkah ini tidak akan pernah dijalankan karena tahap sebelumnya gagal!'
            }
        }
    }
}
