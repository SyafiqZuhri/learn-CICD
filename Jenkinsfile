pipeline {
    agent any

    environment {
        PROJECT_ID = 'tab-dev-playground'
        REGION = 'asia-southeast2'
        REPO_NAME = 'logistik-repo'
        IMAGE_NAME = 'logistik-app'
        IMAGE_TAG = "v${BUILD_NUMBER}"
        FULL_IMAGE_PATH = "${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}"
        // Menambahkan folder gcloud ke PATH
        PATH = "${env.WORKSPACE}/google-cloud-sdk/bin:${env.PATH}"
    }

    stages {
        stage('Persiapan Tools') {
            steps {
                sh '''
                    if [ ! -d "google-cloud-sdk" ]; then
                        curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
                        tar -xzf google-cloud-cli-linux-x86_64.tar.gz
                        ./google-cloud-sdk/install.sh --quiet
                    fi
                '''
            }
        }

        stage('Build & Push (GAR)') {
            steps {
                // Tanpa gcloud auth (karena kita pakai identitas bawaan GKE)
                sh "gcloud builds submit --tag ${FULL_IMAGE_PATH} --project ${PROJECT_ID}"
            }
        }

        stage('Deploy ke GKE') {
            steps {
                script {
                    sh "sed -i 's|logistik-app:.*|logistik-app:${IMAGE_TAG}|g' deployment.yaml"
                    sh "gcloud container clusters get-credentials jenkins-cluster --region ${REGION} --project ${PROJECT_ID}"
                    sh "kubectl apply -f deployment.yaml"
                }
            }
        }
    }
}
