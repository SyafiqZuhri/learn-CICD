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
    }

    stages {
        stage('1. Setup Tools') {
            steps {
                sh '''
                    # Instalasi gcloud di dalam workspace saja (aman dari Git)
                    if [ ! -d "google-cloud-sdk" ]; then
                        echo "Menginstal Google Cloud SDK..."
                        curl -sSL https://sdk.cloud.google.com | bash -s -- --install-dir=$WORKSPACE --disable-prompts
                    fi
                '''
            }
        }

        stage('2. Build & Push (GAR)') {
            steps {
                // gcloud akan menggunakan identitas bawaan GKE secara otomatis
                sh "gcloud builds submit --tag ${FULL_IMAGE_PATH} --project ${PROJECT_ID} ."
            }
        }

        stage('3. Deploy ke GKE') {
            steps {
                script {
                    // Update tag image di deployment.yaml
                    sh "sed -i 's|logistik-app:.*|logistik-app:${IMAGE_TAG}|g' deployment.yaml"
                    
                    // Deploy ke klaster
                    sh "gcloud container clusters get-credentials jenkins-cluster --region ${REGION} --project ${PROJECT_ID}"
                    sh "kubectl apply -f deployment.yaml"
                }
            }
        }
    }

    post {
        success {
            echo "CI/CD Sukses! Aplikasi ${IMAGE_TAG} sudah dideploy."
        }
        failure {
            echo "Pipeline gagal. Periksa log di atas."
        }
    }
}
