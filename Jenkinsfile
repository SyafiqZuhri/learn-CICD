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
	stage('1. Build & Push via Google Cloud Build') {
    		steps {
        	withCredentials([file(credentialsId: 'gcp-credentials', variable: 'GCP_KEY')]) {
            		sh '''
                		# 1. Tidak perlu instal ulang SDK, gunakan yang sudah ada di environment
                # Pastikan gcloud sudah terinstal di server Jenkins kamu (bukan di Workspace)
                
                # 2. Login
                gcloud auth activate-service-account --key-file=$GCP_KEY
                
                # 3. Build langsung! (Pastikan ada Dockerfile di folder utama)
                gcloud builds submit --tag ${FULL_IMAGE_PATH} --project ${PROJECT_ID}
            '''
        	}
    	   }
	}
        stage('2. Deploy ke GKE') {
            steps {
                unstash 'source-code'
                withCredentials([file(credentialsId: 'gcp-credentials', variable: 'GCP_KEY')]) {
                    sh '''
                        cd $WORKSPACE
                        export PATH=$PATH:$WORKSPACE/google-cloud-sdk/bin

                        # Install kubectl
                        if [ ! -f "kubectl" ]; then
                            curl -LO "https://dl.k8s.io/release/v1.28.0/bin/linux/amd64/kubectl"
                            chmod +x kubectl
                        fi

                        gcloud auth activate-service-account --key-file=$GCP_KEY
                        gcloud container clusters get-credentials $CLUSTER_NAME --zone ${REGION}-a --project $PROJECT_ID

                        sed -i "s|logistik-app:v1|logistik-app:${IMAGE_TAG}|g" deployment.yaml
                        ./kubectl apply -f deployment.yaml
                    '''
                }
            }
        }
    }
}
