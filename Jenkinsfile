pipeline {
    agent any

    environment {
        PROJECT_ID = 'tab-dev-playground'
        REGION = 'asia-southeast2'
        REPO_NAME = 'logistik-repo'
        IMAGE_NAME = 'logistik-app'
        // Menggunakan nomor build untuk versioning yang rapi
        IMAGE_TAG = "v${BUILD_NUMBER}"
        FULL_IMAGE_PATH = "${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}"
    }

    stages {
        stage('1. Build & Push (GAR)') {
            steps {
                echo "Membangun image dengan tag: ${IMAGE_TAG}"
                // Tanpa kunci JSON, karena sudah mengandalkan identitas GKE
                sh """
                    gcloud builds submit --tag ${FULL_IMAGE_PATH} --project ${PROJECT_ID}
                """
            }
        }

        stage('2. Deploy ke GKE') {
            steps {
                echo 'Memperbarui aplikasi di Kubernetes...'
                script {
                    // Update image di deployment.yaml secara dinamis
                    sh "sed -i 's|logistik-app:.*|logistik-app:${IMAGE_TAG}|g' deployment.yaml"
                    
                    // Deploy menggunakan identitas klaster
                    sh """
                        gcloud container clusters get-credentials jenkins-cluster \
                            --region ${REGION} \
                            --project ${PROJECT_ID}
                        
                        kubectl apply -f deployment.yaml
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline berhasil! Aplikasi ${IMAGE_TAG} sudah live."
        }
        failure {
            echo "Pipeline gagal. Periksa log untuk detail akses IAM."
        }
    }
}
