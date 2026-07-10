pipeline {
    agent any

    environment {
        PROJECT_ID = 'tab-dev-playground'
        REGION = 'asia-southeast2'
        CLUSTER_NAME = 'jenkins-cluster'
        IMAGE_TAG = "v${BUILD_NUMBER}"
        FULL_IMAGE_PATH = "${REGION}-docker.pkg.dev/${PROJECT_ID}/logistik-repo/logistik-app:${IMAGE_TAG}"
    }

    stages {
        stage('1. Ambil Kode') {
            steps {
                checkout scm
            }
        }

        stage('2. Build & Push Image (Pakai Kaniko via Docker)') {
            steps {
                withCredentials([file(credentialsId: 'gcp-credentials', variable: 'GCP_KEY')]) {
                    sh '''
                        # Login ke GCP pakai file JSON
                        gcloud auth activate-service-account --key-file=$GCP_KEY

                        # Jalankan Kaniko di dalam Docker (build image tanpa Docker daemon)
                        docker run -v $(pwd):/workspace \
                            -e GOOGLE_APPLICATION_CREDENTIALS=$GCP_KEY \
                            gcr.io/kaniko-project/executor:v1.18.0 \
                            --context=/workspace \
                            --dockerfile=/workspace/Dockerfile \
                            --destination=$FULL_IMAGE_PATH
                    '''
                }
            }
        }

        stage('3. Deploy ke GKE') {
            steps {
                withCredentials([file(credentialsId: 'gcp-credentials', variable: 'GCP_KEY')]) {
                    sh '''
                        # Login ke GCP
                        gcloud auth activate-service-account --key-file=$GCP_KEY

                        # Sambungkan kubectl ke cluster GKE
                        gcloud container clusters get-credentials $CLUSTER_NAME --zone ${REGION}-a --project $PROJECT_ID

                        # Update tag image di file deployment
                        sed -i "s|logistik-app:v1|logistik-app:${IMAGE_TAG}|g" deployment.yaml

                        # Deploy ke GKE
                        kubectl apply -f deployment.yaml
                    '''
                }
            }
        }
    }
}
