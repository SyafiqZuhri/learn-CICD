pipeline {
    // Memanggil "Pasukan Sementara" di dalam Kubernetes
    agent {
        kubernetes {
            yaml '''
            apiVersion: v1
            kind: Pod
            spec:
              containers:
              - name: kaniko
                image: gcr.io/kaniko-project/executor:debug
                command: ["sleep", "9999999"]
              - name: gcloud
                image: google/cloud-sdk:alpine
                command: ["sleep", "9999999"]
            '''
        }
    }
    
    // Variabel lingkungan agar kode rapi dan mudah diubah
    environment {
        PROJECT_ID = 'tab-dev-playground'
        REGION = 'asia-southeast2'
        CLUSTER_NAME = 'jenkins-cluster'
        // Nama image dinamis. Contoh: v1, v2, v3 (mengikuti nomor urut build Jenkins)
        IMAGE_TAG = "v${BUILD_NUMBER}" 
        FULL_IMAGE_PATH = "${REGION}-docker.pkg.dev/${PROJECT_ID}/logistik-repo/logistik-app:${IMAGE_TAG}"
    }

    stages {
        stage('1. Mengambil Kode') {
            steps {
                echo 'Mengunduh kode terbaru dari GitHub...'
                checkout scm
            }
        }
        
        stage('2. Build & Push (via Kaniko)') {
            steps {
                echo 'Merakit Docker Image dan mengirim ke Google Artifact Registry...'
                // Memanggil Kunci Akses yang tadi kita simpan dengan ID 'gcp-credentials'
                withCredentials([file(credentialsId: 'gcp-credentials', variable: 'GCP_KEY')]) {
                    container('kaniko') {
                        sh '''
                            export GOOGLE_APPLICATION_CREDENTIALS=$GCP_KEY
                            /kaniko/executor \
                              --context `pwd` \
                              --dockerfile `pwd`/Dockerfile \
                              --destination $FULL_IMAGE_PATH
                        '''
                    }
                }
            }
        }
        
        stage('3. Deploy ke GKE') {
            steps {
                echo 'Memerintahkan Kubernetes untuk menggunakan versi terbaru...'
                withCredentials([file(credentialsId: 'gcp-credentials', variable: 'GCP_KEY')]) {
                    container('gcloud') {
                        sh '''
                            # a. Login ke Google Cloud menggunakan kunci JSON
                            gcloud auth activate-service-account --key-file=$GCP_KEY
                            
                            # b. Sambungkan kubectl ke Klaster GKE
                            gcloud container clusters get-credentials $CLUSTER_NAME --zone ${REGION}-a --project $PROJECT_ID
                            
                            # c. Ubah tag ":v1" di file deployment.yaml menjadi versi terbaru (misal ":v15")
                            sed -i "s|logistik-app:v1|logistik-app:${IMAGE_TAG}|g" deployment.yaml
                            
                            # d. Terapkan pembaruan ke Kubernetes!
                            kubectl apply -f deployment.yaml
                        '''
                    }
                }
            }
        }
    }
}
