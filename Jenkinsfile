pipeline {
    agent any 

    stages {
        stage('Persiapan') {
            steps {
                echo 'Halo Bos Zuhri! Jenkins berhasil membaca instruksi dari GitHub.'
            }
        }
        
        stage('Cek File Repositori') {
            steps {
                echo 'Mengecek isi repositori learn-CICD...'
                sh 'ls -al'
            }
        }
        
        stage('Simulasi Build') {
            steps {
                echo 'Sistem berhasil diuji dan siap untuk tahapan selanjutnya!'
            }
        }
    }
}
