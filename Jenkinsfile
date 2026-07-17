pipeline {
    agent any
    environment {
        GOOGLE_APPLICATION_CREDENTIALS = credentials('gcp-service-account-key')
    }
    stages {
        // ... (Tahap Init, Plan, Approval, Apply kamu tetap sama) ...
    }
    
    // Blok ini akan mengirim Email Notifikasi otomatis
    post {
        success {
            script {
                mail to: 'email-tujuan-kamu@gmail.com',
                     subject: "SUCCESS: Jenkins Pipeline ${currentBuild.fullDisplayName}",
                     body: "Halo,\n\nPipeline untuk infrastruktur Terraform telah berhasil dieksekusi.\n\nCek log lengkapnya di sini: ${env.BUILD_URL}"
            }
        }
        failure {
            script {
                mail to: 'email-tujuan-kamu@gmail.com',
                     subject: "FAILED: Jenkins Pipeline ${currentBuild.fullDisplayName}",
                     body: "Peringatan!\n\nPipeline infrastruktur GAGAL dieksekusi. Segera periksa log error di Jenkins:\n\n${env.BUILD_URL}"
            }
        }
    }
}
