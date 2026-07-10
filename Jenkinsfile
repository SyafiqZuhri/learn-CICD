pipeline {
    agent any

    environment {
        PROJECT_ID = 'tab-dev-playground'
        REGION = 'asia-southeast2'
        REPO_NAME = 'logistik-repo'
        IMAGE_NAME = 'logistik-app'
        IMAGE_TAG = "v${BUILD_NUMBER}"
        FULL_IMAGE_PATH = "${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}"
        
        // Memastikan folder SDK masuk ke PATH agar gcloud bisa dipanggil
        PATH = "${env.WORKSPACE}/google-cloud-sdk/bin:${env.PATH}"
        
        // Memaksa gcloud untuk menggunakan Python 3 bawaan sistem
        CLOUDSDK_PYTHON = 'python3'
    }

    stages {
        stage('1. Setup Tools') {
            steps {
                sh '''
                    # Mengunduh gcloud versi 478.0.0 (Support Python 3.9) agar tidak error
                    if [ ! -d "google-cloud-sdk" ]; then
                        echo "Menginstal Google Cloud SDK versi kompatibel..."
                        curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-478.0.0-linux-x86_64.tar.gz
                        tar -xf google-cloud-cli-478.0.0-linux-x86_64.tar.gz
                        ./google-cloud-sdk/install.sh --quiet
                    fi
                '''
            }
        }

        stage('2. Build & Push (GAR)') {
            steps {
                // Proses build akan berjalan normal tanpa komplain versi Python
                sh "gcloud builds submit --tag ${FULL_IMAGE_PATH} --project ${PROJECT_ID} ."
            }
        }

        stage('3. Deploy ke GKE') {
            steps {
                script {
                    // Mengubah tag versi aplikasi di file deployment
                    sh "sed -i 's|logistik-app:.*|logistik-app:${IMAGE_TAG}|g' deployment.yaml"
                    
                    // Mengakses klaster dan melakukan update pod
                    sh "gcloud container clusters get-credentials jenkins-cluster --region ${REGION} --project ${PROJECT_ID}"
                    sh "kubectl apply -f deployment.yaml"
                }
            }
        }
    }

    post {
        success {
            echo "CI/CD Sukses! Aplikasi ${IMAGE_TAG} berhasil di-deploy."
        }
        failure {
            echo "Pipeline gagal di tengah jalan. Cek log untuk detailnya."
        }
    }
}
