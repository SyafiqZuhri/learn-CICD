pipeline {
    agent any

    environment {
        PROJECT_ID = 'tab-dev-playground'
        REGION = 'asia-southeast2'
        CLUSTER_NAME = 'jenkins-cluster'
        IMAGE_TAG = "v${BUILD_NUMBER}"
        FULL_IMAGE_PATH = "${REGION}-docker.pkg.dev/${PROJECT_ID}/logistik-repo/logistik-app:${IMAGE_TAG}"
        GCLOUD_VERSION = '448.0.0'
        WORKSPACE = "${env.WORKSPACE}"
    }

    stages {
        stage('1. Build & Push Image (Pakai Kaniko)') {
            steps {
                checkout scm
                withCredentials([file(credentialsId: 'gcp-credentials', variable: 'GCP_KEY')]) {
                    sh '''
                        # 1. Setup Google Cloud SDK (agar bisa autentikasi)
                        cd $WORKSPACE
                        if [ ! -d "google-cloud-sdk" ]; then
                            curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz
                            tar -xzf google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz
                            ./google-cloud-sdk/install.sh --quiet --usage-reporting=false
                        fi
                        export PATH=$PATH:$WORKSPACE/google-cloud-sdk/bin

                        # 2. Download binary Kaniko (untuk build image tanpa Docker)
                        curl -LO https://github.com/GoogleContainerTools/kaniko/releases/download/v1.18.0/kaniko-executor
                        chmod +x kaniko-executor

                        # 3. Login ke GCP pake file JSON
                        gcloud auth activate-service-account --key-file=$GCP_KEY

                        # 4. Jalankan Kaniko untuk build & push ke Artifact Registry
                        export GOOGLE_APPLICATION_CREDENTIALS=$GCP_KEY
                        ./kaniko-executor \
                            --context=$WORKSPACE \
                            --dockerfile=$WORKSPACE/Dockerfile \
                            --destination=$FULL_IMAGE_PATH
                    '''
                }
                stash name: 'source-code', includes: '**'
            }
        }

        stage('2. Deploy ke GKE') {
            steps {
                unstash 'source-code'
                withCredentials([file(credentialsId: 'gcp-credentials', variable: 'GCP_KEY')]) {
                    sh '''
                        # 1. Setup Google Cloud SDK (jika belum di-stage1, ini akan install)
                        export PATH=$PATH:$WORKSPACE/google-cloud-sdk/bin
                        cd $WORKSPACE
                        if [ ! -d "google-cloud-sdk" ]; then
                            curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz
                            tar -xzf google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz
                            ./google-cloud-sdk/install.sh --quiet --usage-reporting=false
                        fi

                        # 2. Download kubectl
                        curl -LO "https://dl.k8s.io/release/v1.28.0/bin/linux/amd64/kubectl"
                        chmod +x kubectl

                        # 3. Login ke GCP
                        gcloud auth activate-service-account --key-file=$GCP_KEY

                        # 4. Hubungkan kubectl ke cluster GKE (ini akan generate kubeconfig otomatis)
                        gcloud container clusters get-credentials $CLUSTER_NAME --zone ${REGION}-a --project $PROJECT_ID

                        # 5. Update tag image di deployment.yaml
                        sed -i "s|logistik-app:v1|logistik-app:${IMAGE_TAG}|g" deployment.yaml

                        # 6. Deploy ke GKE!
                        ./kubectl apply -f deployment.yaml
                    '''
                }
            }
        }
    }
}
