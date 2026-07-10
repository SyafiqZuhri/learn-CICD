pipeline {
    // Stage 1 akan jalan di container Kaniko, Stage 2 di container gcloud
    agent none

    environment {
        PROJECT_ID = 'tab-dev-playground'
        REGION = 'asia-southeast2'
        CLUSTER_NAME = 'jenkins-cluster'
        IMAGE_TAG = "v${BUILD_NUMBER}"
        FULL_IMAGE_PATH = "${REGION}-docker.pkg.dev/${PROJECT_ID}/logistik-repo/logistik-app:${IMAGE_TAG}"
    }

    stages {
        stage('1. Build & Push Image (Pakai Kaniko)') {
            agent {
                docker {
                    image 'gcr.io/kaniko-project/executor:debug'
                    args '-u root' // Biar bisa akses file
                }
            }
            steps {
                // Ambil kode dari GitHub
                checkout scm
                
                // Ambil file JSON dari brankas Jenkins
                withCredentials([file(credentialsId: 'gcp-credentials', variable: 'GCP_KEY')]) {
                    sh '''
                        # Copy file JSON ke dalam container
                        cp $GCP_KEY /root/key.json
                        export GOOGLE_APPLICATION_CREDENTIALS=/root/key.json

                        # Jalankan Kaniko untuk build dan push
                        /kaniko/executor \
                            --context=/workspace \
                            --dockerfile=/workspace/Dockerfile \
                            --destination=$FULL_IMAGE_PATH
                    '''
                }
                
                // Simpan semua file (termasuk deployment.yaml) untuk stage berikutnya
                stash name: 'source-code', includes: '**'
            }
        }

        stage('2. Deploy ke GKE') {
            agent {
                docker {
                    image 'google/cloud-sdk:alpine'
                    args '-u root'
                }
            }
            steps {
                // Ambil kembali file yang di-stash di stage 1
                unstash 'source-code'
                
                withCredentials([file(credentialsId: 'gcp-credentials', variable: 'GCP_KEY')]) {
                    sh '''
                        # Install kubectl di dalam container
                        gcloud components install kubectl --quiet

                        # Login ke GCP
                        gcloud auth activate-service-account --key-file=$GCP_KEY

                        # Sambungkan ke cluster GKE
                        gcloud container clusters get-credentials $CLUSTER_NAME --zone ${REGION}-a --project $PROJECT_ID

                        # Update tag image di deployment.yaml
                        sed -i "s|logistik-app:v1|logistik-app:${IMAGE_TAG}|g" deployment.yaml

                        # Deploy ke GKE
                        kubectl apply -f deployment.yaml
                    '''
                }
            }
        }
    }
}
