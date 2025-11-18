pipeline {
    agent any

    environment {
        // Nombre que le daremos a la imagen
        IMAGE_NAME = "mi-backend-python"
    }

    stages {
        stage('Checkout') {
            steps {
                // Jenkins descarga el código automáticamente aquí
                echo '--- Descargando código del repositorio ---'
                checkout scm
            }
        }

        stage('Construir Backend') {
            steps {
                echo '--- Construyendo imagen Docker del Backend ---'
                // Entramos a la carpeta backend y construimos usando el Dockerfile que tienes ahí
                dir('backend') {
                    script {
                        // Nota: Asegúrate de que tu Jenkins tenga permisos de Docker
                        sh "docker build -t ${IMAGE_NAME}:latest ."
                    }
                }
            }
        }

        stage('Pruebas') {
            steps {
                echo '--- Ejecutando Pruebas (Simulación) ---'
                // Aquí puedes poner comandos reales más adelante
                echo 'Tests pasados correctamente.'
            }
        }
    }

    post {
        always {
            echo 'Limpiando espacio de trabajo...'
            cleanWs()
        }
        success {
            echo '¡El Pipeline finalizó con éxito!'
        }
        failure {
            echo 'Hubo un error en el proceso.'
        }
    }
}