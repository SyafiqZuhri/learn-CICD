pipeline {
    agent any

    environment {
        PROJECT_ID = 'tab-dev-playground'
        REGION = 'asia-southeast2'
        REPO_NAME = 'logistik-repo'
        IMAGE_NAME = 'logistik-app'
        IMAGE_TAG = "v${BUILD_NUMBER}"
        FULL_IMAGE_PATH = "${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}"
    }

    stages {
        stage('1. Instal Tools') {
            steps {
                sh '''
                    # Instalasi gcloud secara dinamis jika belum ada
                    if ! command -v gcloud &> /dev/null; then
                        echo "Menginstal Google Cloud SDK..."
                        curl -sSL https://sdk.cloud.google.com | bash
                        export PATH=$PATH:$HOME/google-cloud-sdk/bin
                    fi
                '''
            }
        }

        stage('2. Build & Push (GAR)') {
            steps {
                sh "/root/google-cloud-sdk/bin/gcloud builds submit --tag ${FULL_IMAGE_PATH} --project ${PROJECT_ID}"
            }
        }

        stage('3. Deploy ke GKE') {
            steps {
                sh """
                    sed -i 's|logistik-app:.*|logistik-app:${IMAGE_TAG}|g' deployment.yaml
                    /root/google-cloud-sdk/bin/gcloud container clusters get-credentials jenkins-cluster --region ${REGION} --project ${PROJECT_ID}
                    kubectl apply -f deployment.yaml
                """
            }
        }
    }
}
