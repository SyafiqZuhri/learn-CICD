pipeline {
    // Jenkins akan otomatis menggunakan sumber daya klaster GKE
    agent any

    environment {
        PROJECT_ID = 'tab-dev-playground'
        REGION = 'asia-southeast2'
        REPO_NAME = 'logistik-repo'
        IMAGE_NAME = 'logistik-app'
        // Tag menggunakan nomor build untuk memastikan setiap versi unik
        IMAGE_TAG = "v${BUILD_NUMBER}"
        FULL_IMAGE_PATH = "${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}"
    }

    stages {
        stage('1. Checkout Code') {
            steps {
                echo 'Mengambil kode terbaru dari GitHub...'
                checkout scm
            }
        }

        stage('2. Build & Push (via Google Cloud Build)') {
            steps {
                echo 'Mengirim instruksi build ke Google Cloud Build...'
                // Perintah ini dijalankan tanpa perlu instal SDK atau pakai kunci JSON
                // karena Jenkins sudah dikenali oleh klaster GKE
                sh """
                    gcloud builds submit \
                        --tag ${FULL_IMAGE_PATH} \
                        --project ${PROJECT_ID}
                """
            }
        }

        stage('3. Deploy ke GKE') {
            steps {
                echo 'Memperbarui aplikasi di Kubernetes...'
                script {
                    // Update file YAML secara otomatis dengan tag versi baru
                    sh "sed -i 's|logistik-app:.*|logistik-app:${IMAGE_TAG}|g' deployment.yaml"
                    
                    // Deploy ke GKE
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
            echo "CI/CD Pipeline berhasil diselesaikan untuk versi ${IMAGE_TAG}!"
        }
        failure {
            echo "Pipeline gagal. Periksa log di atas untuk detail error."
        }
    }
}
