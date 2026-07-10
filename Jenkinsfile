pipeline {
    agent any

    environment {
        PROJECT_ID = 'tab-dev-playground'
        REGION = 'asia-southeast2'
        REPO_NAME = 'logistik-repo'
        IMAGE_NAME = 'logistik-app'
        IMAGE_TAG = "v${BUILD_NUMBER}"
        FULL_IMAGE_PATH = "${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}"
        
        // Memasukkan folder gcloud ke dalam PATH sistem Jenkins
        PATH = "${env.WORKSPACE}/google-cloud-sdk/bin:${env.PATH}"
    }

    stages {
        stage('1. Reset & Setup Environment') {
            steps {
                sh '''
                    echo "=== 1. Membersihkan Sisa Instalan Lama ==="
                    rm -rf google-cloud-sdk
                    rm -f google-cloud-cli-*.tar.gz

                    echo "=== 2. Menginstal Python 3 & Dependencies ==="
                    # Karena Jenkins berjalan sebagai 'root', kita instal Python langsung di sini
                    apt-get update && apt-get install -y python3 curl tar

                    echo "=== 3. Mengunduh & Menginstal Google Cloud SDK ==="
                    curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-478.0.0-linux-x86_64.tar.gz
                    tar -xf google-cloud-cli-478.0.0-linux-x86_64.tar.gz
                    ./google-cloud-sdk/install.sh --quiet
                '''
            }
        }

        stage('2. Build & Push (GAR)') {
            steps {
                // Sekarang gcloud sudah punya Python 3 untuk mengeksekusi perintah
                sh "gcloud builds submit --tag ${FULL_IMAGE_PATH} --project ${PROJECT_ID} ."
            }
        }

        stage('3. Deploy ke GKE') {
            steps {
                script {
                    // Memperbarui file konfigurasi deployment dengan tag baru
                    sh "sed -i 's|logistik-app:.*|logistik-app:${IMAGE_TAG}|g' deployment.yaml"
                    
                    // Menghubungkan ke klaster GKE perusahaan
                    sh "gcloud container clusters get-credentials jenkins-cluster --region ${REGION} --project ${PROJECT_ID}"
                    sh "kubectl apply -f deployment.yaml"
                }
            }
        }
    }

    post {
        success {
            echo "CI/CD Berhasil! Aplikasi versi ${IMAGE_TAG} sudah tayang."
        }
        failure {
            echo "Pipeline gagal. Periksa log logistik di atas untuk melihat kendala izin."
        }
    }
}
