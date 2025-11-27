pipeline {
    agent any

    options {
        timeout(time: 15, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    environment {
        // Variables principales
        IMAGE_NAME = "mi-backend-python"
        DOCKERHUB_USERNAME = "karlsite13" // Reemplaza con tu usuario de Docker Hub
        VERSION = "${env.BUILD_NUMBER}" 
        FULL_IMAGE_NAME = "${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${VERSION}"
    }

    stages {
        // ... Etapas Checkout, Construir Backend, Pruebas Unitarias (como ya las tenías)

        stage('Checkout') {
            steps {
                echo '--- [CORRECCIÓN SSL] Deshabilitando verificación de certificados ---'
                sh 'git config --global http.sslVerify false' 
                echo '--- Descargando código fuente ---'
                checkout scm
            }
        }

        stage('Construir Backend') {
            agent { // <--- Sintaxis correcta
                docker {
                    image 'docker:20.10.16-cli' 
                    args '-v /var/run/docker.sock:/var/run/docker.sock' 
                }
            }
            steps {
                echo '--- 2. Construyendo Imagen Docker ---'
                dir('backend') {
                    // El tag es importante para el push
                    sh "docker build -t ${FULL_IMAGE_NAME} ." 
                }
            }
        }

        stage('Pruebas Unitarias') {
            // Usamos un agente Python para que las pruebas sean limpias y aisladas
            agent {
                docker {
                    image 'python:3.12-slim' 
                }
            }
            steps {
                echo '--- 3. Ejecutando Pruebas Unitarias ---'
                dir('backend') {
                    // Instalamos las dependencias para ejecutar pytest
                    sh 'pip install -r requirements.txt'
                    // Comando real de pytest (asumiendo que tienes una carpeta 'tests')
                    sh 'python -m pytest tests/' 
                }
            }
        }

        // ------------------------------------------------------------------------
        // ETAPAS DE DESPLIEGUE CONTINUO (CD)
        // ------------------------------------------------------------------------

        stage('Login y Push a Docker Hub') {
            agent { 
                docker {
                    image 'docker:20.10.16-cli' 
                    args '-v /var/run/docker.sock:/var/run/docker.sock' 
                }
            }
            steps {
                echo '--- 4. Login en Docker Hub ---'
                // Usamos la credencial ID: dockerhub-credentials
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                    sh "docker login -u ${USER} -p ${PASS}"
                }
                echo "--- 5. Subiendo imagen ${FULL_IMAGE_NAME} ---"
                sh "docker push ${FULL_IMAGE_NAME}"
            }
        }

        stage('Deployment (Compose)') {
            agent {
                docker {
                    image 'docker/compose:latest' // Usamos Docker Compose
                    args '-v /var/run/docker.sock:/var/run/docker.sock' 
                }
            }
            steps {
                echo '--- 6. Despliegue: Levantando la Aplicación con Docker Compose ---'
                // Mapeo: El workspace de Jenkins al repo dentro del contenedor compose
                dir('.') {
                    // Usamos --build para que re-construya la imagen con el nuevo código y -d para background
                    sh "docker compose up -d --build backend" 
                }
            }
        }
    }

    post {
        always {
            echo '--- Limpieza del Workspace y Logout ---'
            sh 'docker logout || true'
            cleanWs()
        }
        success {
            echo '✅ ¡Pipeline ejecutado con ÉXITO! La aplicación fue desplegada via Docker Compose.'
        }
        failure {
            echo '❌ El Pipeline ha fallado.'
        }
    }
}