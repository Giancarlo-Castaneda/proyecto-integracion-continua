pipeline {
    agent any

    // Opciones globales para evitar que el proceso se cuelgue infinitamente
    options {
        timeout(time: 10, unit: 'MINUTES') // Esperar máximo 10 minutos
        disableConcurrentBuilds() // No permitir dos ejecuciones al mismo tiempo
    }

    environment {
        IMAGE_NAME = "mi-backend-python"
        // Aseguramos que Docker use el socket correcto
        DOCKER_HOST = "unix:///var/run/docker.sock"
    }

    stages {
        stage('Checkout') {
            steps {
                echo '--- 1. Descargando código (Versión optimizada) ---'
                // La configuración de "Shallow Clone" que hiciste en el Paso 1 aplica aquí
                checkout scm
            }
        }

        stage('Construir Backend') {
            steps {
                echo '--- 2. Construyendo Imagen Docker ---'
                dir('backend') {
                    script {
                        // Verificamos primero si docker responde
                        sh 'docker --version'
                        echo "Construyendo imagen: ${IMAGE_NAME}"
                        // Comando de construcción
                        sh "docker build -t ${IMAGE_NAME}:latest ."
                    }
                }
            }
        }

        stage('Pruebas') {
            steps {
                echo '--- 3. Ejecutando Pruebas ---'
                // Aquí simulamos las pruebas. 
                // Si tuvieras un script real sería: sh 'python -m pytest'
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