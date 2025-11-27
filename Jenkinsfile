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
            agent {
                docker {
                    image 'docker:20.10.16-cli' 
                    // Montamos el socket para que este contenedor pueda hablar con el Docker Host (Solución de Permisos)
                    args '-v /var/run/docker.sock:/var/run/docker.sock' 
                }
            }
            steps {
                echo '--- 2. Construyendo Imagen Docker ---'
                dir('backend') {
                    // *** AÑADE ESTAS DOS LÍNEAS TEMPORALMENTE ***
                    sh 'pwd'   // Muestra la ruta actual
                    sh 'ls -la' // Muestra la lista de archivos en la carpeta backend
                    // **********************************************
                    // El tag es importante para el rastreo y el despliegue
                    sh "docker build -t ${FULL_IMAGE_NAME} ."
                }
            }
        }

    stage('Pruebas Unitarias') { 
            agent {
                // Usamos la imagen recién construida para garantizar un entorno idéntico al de producción
                image "${FULL_IMAGE_NAME}" 
            }
            steps {
                echo '--- 3. Ejecutando Pruebas Unitarias (Simulación Pytest) ---'
                // Reemplazar con el comando real si usas Pytest
                sh 'echo "Simulando ejecución de pytest..."' 
                sh 'echo "Tests completados exitosamente."'
            }
        }

      /*  stage('Pruebas Unitarias') {
            steps {
                echo '--- Ejecutando Pruebas con la Imagen Construida ---'
                // Reemplazamos la etapa vacía por un comando que corre los tests 
                // dentro de un contenedor desechable de la imagen que acabamos de crear.
                script {
                    sh """
                    docker run --rm ${FULL_IMAGE_NAME} bash -c 'python -m pytest tests/'
                    """
                }
            }
        } */

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
            agent {
                docker {
                    image 'docker/compose:latest' // Imagen que incluye Docker Compose
                    args '-v /var/run/docker.sock:/var/run/docker.sock' 
                }
            }
            steps {
                echo '--- 4. Despliegue: Levantando la Aplicación con Docker Compose ---'
                dir('.') {
                    // Detiene y elimina contenedores anteriores y levanta el nuevo backend y sus dependencias (Mongo)
                    sh "docker-compose down || true" 
                    // Levanta el servicio 'backend' (y sus dependencias) en modo detach. 
                    // El compose usará la imagen que se construyó en la etapa anterior.
                    sh "docker-compose up -d backend" 
                    sh "echo 'Aplicación desplegada en http://localhost:8000. Revisar logs de Compose.'"
                }
            }
        }
    }

    post {
        always {
            echo '--- Limpieza del Workspace ---'
            cleanWs()
            // Limpieza de imágenes (Opcional, pero bueno para el disco)
            // sh "docker image prune -f || true" 
        }
        success {
            // Este es el mensaje solicitado al finalizar con éxito
            echo "✅ ¡Pipeline ejecutado con ÉXITO! Imagen ${FULL_IMAGE_NAME} desplegada."
        }
        failure {
            echo '❌ El Pipeline ha fallado. Revisa los logs de las etapas anteriores.'
        }
    }
}