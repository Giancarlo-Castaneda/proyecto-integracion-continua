pipeline {
    agent any // Usamos el contenedor principal de Jenkins

    options {
        timeout(time: 20, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    environment {
        IMAGE_NAME = "mi-backend-python"
        DOCKERHUB_USERNAME = "karlsite13" // Tu usuario real
        VERSION = "${env.BUILD_NUMBER}" 
        FULL_IMAGE_NAME = "${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${VERSION}"
    }

    stages {
        stage('Checkout') {
            steps {
                echo '--- Deshabilitando verificación SSL ---'
                sh 'git config --global http.sslVerify false' 
                echo '--- Descargando código ---'
                checkout scm
            }
        }

        stage('Construir Backend') {
            steps {
                echo '--- Construyendo Imagen Docker ---'
                dir('backend') {
                    // *** AÑADE ESTAS DOS LÍNEAS TEMPORALMENTE ***
                    sh 'pwd'   // Muestra la ruta actual
                    sh 'ls -la' // Muestra la lista de archivos en la carpeta backend
                    // **********************************************
                    sh "docker build -t ${FULL_IMAGE_NAME} ."
                }
            }
        }

        stage('Pruebas Unitarias') {
            steps {
                echo '--- Ejecutando Pruebas (En contenedor efímero) ---'
                // Truco Pro: Usamos la imagen que acabamos de construir para correr los tests.
                // Así no tenemos problemas de montar volúmenes ni rutas.
                script {
                    sh """
                    docker run --rm ${FULL_IMAGE_NAME} bash -c "pip install pytest && python -m pytest tests/"
                    """
                }
            }
        }

        stage('Login y Push') {
            steps {
                echo '--- Subiendo a Docker Hub ---'
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                    sh "docker login -u ${USER} -p ${PASS}"
                }
                sh "docker push ${FULL_IMAGE_NAME}"
            }
        }

        stage('Despliegue (Compose)') {
            steps {
                echo '--- Desplegando con Docker Compose ---'
                // Usamos la carpeta /app/repo que montamos en el paso anterior (tu código local)
                dir('/app/repo') {
                    // Validamos que exista el archivo antes de ejecutar
                    sh 'ls -la' 
                    sh "docker compose up -d --build backend"
                }
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
            cleanWs()
        }
        success {
            echo '✅ ¡Pipeline completado con ÉXITO!'
        }
        failure {
            echo '❌ Falló el Pipeline.'
        }
    }
}