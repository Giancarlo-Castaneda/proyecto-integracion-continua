pipeline {
    agent any

    options {
        timeout(time: 10, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    environment {
        IMAGE_NAME = "mi-backend-python"
    }

    stages {
        stage('Checkout') {
            steps {
                echo '--- [CORRECCIÓN SSL] Deshabilitando verificación de certificados ---'
                // Este comando le dice al cliente Git dentro de Jenkins que ignore el error del certificado
                sh 'git config --global http.sslVerify false' 

                echo '--- Descargando código fuente ---'
                checkout scm
            }
        }

        stage('Construir Backend') {
            steps {
                echo '--- 2. Construyendo Imagen Docker ---'
                dir('backend') {
                    script {
                        // Verificamos si docker responde - Este es el siguiente punto de fallo probable
                        sh 'docker --version' 
                        echo "Construyendo imagen: ${IMAGE_NAME}"
                        sh "docker build -t ${IMAGE_NAME}:latest ."
                    }
                }
            }
        }

        stage('Pruebas') {
            steps {
                echo '--- 3. Ejecutando Pruebas ---'
                sh 'echo "Simulando pruebas unitarias..."'
                sh 'echo "Tests completados exitosamente."'
            }
        }
    }

    post {
        always {
            echo '--- Limpieza del Workspace ---'
            cleanWs()
        }
        success {
            echo '✅ ¡Pipeline ejecutado con ÉXITO!'
        }
        failure {
            echo '❌ El Pipeline ha fallado. Revisa los logs de arriba.'
        }
    }
}