pipeline {
    agent any 

    stages {
        stage('Checkout') {
            steps {
                echo 'Mengambil kode dari GitHub...'
                checkout scm
            }
        }
        
        stage('Deploy ke Kubernetes') {
            steps {
                echo 'Menerbitkan aplikasi ke dalam Klaster...'
                sh 'kubectl apply -f deployment.yaml'
            }
        }
    }
}
