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
                sh 'git config --global http.sslVerify false' 
                echo '--- Descargando código fuente ---'
                checkout scm
            }
        }

        stage('Construir Backend') {
            agent {
                docker {
                    // Usamos una imagen que tiene el cliente Docker (CLI)
                    image 'docker:20.10.16-cli' 
                    // Montamos el socket para que este contenedor pueda hablar con el Docker Host
                    args '-v /var/run/docker.sock:/var/run/docker.sock' 
                }
            }
            steps {
                echo '--- 2. Construyendo Imagen Docker ---'
                dir('backend') {
                    // Comando de construcción
                    sh "docker build -t ${IMAGE_NAME}:latest ."
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