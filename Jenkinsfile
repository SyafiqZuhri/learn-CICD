pipeline {
    agent any

    environment {
        PROJECT_ID = 'tab-dev-playground'
        REGION = 'asia-southeast2'
        REPO_NAME = 'logistik-repo'
        IMAGE_NAME = 'logistik-app'
        IMAGE_TAG = "v${BUILD_NUMBER}"
        FULL_IMAGE_PATH = "${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}"
        
        // Memastikan folder SDK masuk ke PATH
        PATH = "${env.WORKSPACE}/google-cloud-sdk/bin:${env.PATH}"
        
        // Menggunakan nama 'python' (bukan python3) sesuai bawaan Jenkins
        CLOUDSDK_PYTHON = 'python'
    }

    stages {
        stage('1. Setup Tools') {
            steps {
                sh '''
                    echo "Membersihkan sisa gcloud versi lama..."
                    rm -rf google-cloud-sdk
                    rm -f google-cloud-cli-*.tar.gz
                    
                    echo "Menginstal Google Cloud SDK versi 478.0.0 (Support Python 3.9)..."
                    curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-478.0.0-linux-x86_64.tar.gz
                    tar -xf google-cloud-cli-478.0.0-linux-x86_64.tar.gz
                    ./google-cloud-sdk/install.sh --quiet
                '''
            }
        }

        stage('2. Build & Push (GAR)') {
            steps {
                sh "gcloud builds submit --tag ${FULL_IMAGE_PATH} --project ${PROJECT_ID} ."
            }
        }

        stage('3. Deploy ke GKE') {
            steps {
                script {
                    sh "sed -i 's|logistik-app:.*|logistik-app:${IMAGE_TAG}|g' deployment.yaml"
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
