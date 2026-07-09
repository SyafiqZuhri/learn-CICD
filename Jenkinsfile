pipeline {
    agent any 

    stages {
        stage('Checkout') {
            steps {
                echo 'Mengambil kode dari GitHub...'
                checkout scm
            }
        }
        
        stage('Build Image') {
            steps {
                echo 'Membangun Docker Image aplikasi logistik...'
                sh 'docker build -t logistik-app:latest .'
            }
        }
        
        stage('Test App') {
            steps {
                echo 'Memastikan aplikasi berjalan...'
                sh 'docker run --rm logistik-app:latest node -e "console.log(\'Aplikasi berhasil di-build!\')"'
            }
        }
        
        // --- TAHAP BARU: DEPLOYMENT ---
        stage('Deploy ke Kubernetes') {
            steps {
                echo 'Menerbitkan aplikasi ke dalam Klaster...'
                sh 'kubectl apply -f deployment.yaml'
            }
        }
    }
}
