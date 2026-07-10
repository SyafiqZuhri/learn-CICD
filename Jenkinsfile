pipeline {
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
    volumeMounts:
    - name: gcr-cred-volume        # 👈 1. Kita pasang harddisk virtual berisi kunci
      mountPath: /secret           # 👈 Harddisk akan terlihat di folder /secret
  - name: gcloud
    image: google/cloud-sdk:alpine
    command: ["sleep", "9999999"]
    volumeMounts:
    - name: gcr-cred-volume        # 👈 2. Kita pasang harddisk yang sama ke gcloud
      mountPath: /secret
  volumes:
  - name: gcr-cred-volume          # 👈 3. Kita ambil isi harddisk dari Secret bernama gcr-compute-key
    secret:
      secretName: gcr-compute-key  # 👈 Nama Secret yang berhasil kita buat tadi!
'''
        }
    }

    environment {
        PROJECT_ID = 'tab-dev-playground'
        REGION = 'asia-southeast2'
        CLUSTER_NAME = 'jenkins-cluster'
        IMAGE_TAG = "v${BUILD_NUMBER}"
        // Hati-hati: di sini Anda pakai Artifact Registry (pkg.dev), BUKAN GCR (gcr.io)
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
                container('kaniko') {
                    sh '''
                        # Kasih tahu Kaniko di mana letak file kunci JSON-nya
                        export GOOGLE_APPLICATION_CREDENTIALS=/secret/gcr-key.json

                        # Jalankan Kaniko (path workspace sudah benar otomatis di /workspace)
                        /kaniko/executor \
                          --context=/workspace \
                          --dockerfile=/workspace/Dockerfile \
                          --destination=$FULL_IMAGE_PATH
                    '''
                }
            }
        }

        stage('3. Deploy ke GKE') {
            steps {
                echo 'Memerintahkan Kubernetes untuk menggunakan versi terbaru...'
                container('gcloud') {
                    sh '''
                        # Login ke GCP pakai kunci JSON yang sama
                        gcloud auth activate-service-account --key-file=/secret/gcr-key.json

                        # Hubungkan kubectl ke cluster GKE
                        gcloud container clusters get-credentials $CLUSTER_NAME --zone ${REGION}-a --project $PROJECT_ID

                        # Ganti tag gambar di file deployment.yaml dari "v1" menjadi versi terbaru
                        sed -i "s|logistik-app:v1|logistik-app:${IMAGE_TAG}|g" /workspace/deployment.yaml

                        # Terapkan perubahan ke GKE
                        kubectl apply -f /workspace/deployment.yaml
                    '''
                }
            }
        }
    }
}
