pipeline {
    agent any

    environment {
        PROJECT_ID = 'tab-dev-playground'
        REGION = 'asia-southeast2'
        REPO_NAME = 'logistik-repo'
        IMAGE_NAME = 'logistik-app'
        IMAGE_TAG = "v${BUILD_NUMBER}"
        FULL_IMAGE_PATH = "${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}"
        
        // Memasukkan folder tools lokal ke dalam sistem PATH Jenkins
        PATH = "${env.WORKSPACE}/google-cloud-sdk/bin:${env.WORKSPACE}:${env.PATH}"
    }

    stages {
        stage('1. Checkout Code') {
            steps {
                echo 'Mengambil kode terbaru dari GitHub...'
                checkout scm
            }
        }

        stage('2. Persiapan Tools') {
            steps {
                echo 'Memastikan gcloud dan kubectl tersedia...'
                sh '''
                    cd $WORKSPACE
                    
                    # Install gcloud jika belum ada
                    if [ ! -d "google-cloud-sdk" ]; then
                        echo "Mengunduh Google Cloud SDK..."
                        curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
                        tar -xzf google-cloud-cli-linux-x86_64.tar.gz
                        ./google-cloud-sdk/install.sh --quiet
                    fi
                    
                    # Install kubectl jika belum ada
                    if [ ! -f "kubectl" ]; then
                        echo "Mengunduh Kubectl..."
                        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                        chmod +x kubectl
                    fi
                '''
            }
        }

        stage('3. Build & Push') {
            steps {
                echo 'Mengirim instruksi ke Google Cloud Build...'
                sh '''
                    cd $WORKSPACE
                    # Eksekusi build (menggunakan identitas bawaan klaster GKE)
                    gcloud builds submit --tag ${FULL_IMAGE_PATH} --project ${PROJECT_ID}
                '''
            }
        }

        stage('4. Deploy ke GKE') {
            steps {
                echo 'Memperbarui aplikasi di Kubernetes...'
                sh '''
                    cd $WORKSPACE
                    
                    # 1. Update tag versi di dalam file deployment.yaml
                    sed -i "s|logistik-app:.*|logistik-app:${IMAGE_TAG}|g" deployment.yaml
                    
                    # 2. Hubungkan gcloud ke klaster GKE
                    gcloud container clusters get-credentials jenkins-cluster --region ${REGION} --project ${PROJECT_ID}
                    
                    # 3. Terapkan perubahan menggunakan kubectl lokal
                    kubectl apply -f deployment.yaml
                '''
            }
        }
    }

    post {
        success {
            echo "Mantap! CI/CD Pipeline berhasil untuk versi ${IMAGE_TAG}!"
        }
        failure {
            echo "Pipeline gagal. Periksa log di atas untuk detail error."
        }
    }
}
