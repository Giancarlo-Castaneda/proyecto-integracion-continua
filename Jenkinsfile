pipeline {
    agent any

    options {
        timeout(time: 15, unit: 'MINUTES') // Aumentamos el tiempo por el push
        disableConcurrentBuilds()
    }

    environment {
        // Variables principales
        IMAGE_NAME = "mi-backend-python"
        DOCKERHUB_USERNAME = "giancarlocastaneda" // REEMPLAZAR con tu usuario de Docker Hub
        VERSION = "${env.BUILD_NUMBER}" // Usamos el número de build de Jenkins como versión
        
        // Variable para la imagen final con tag
        FULL_IMAGE_NAME = "${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${VERSION}"
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
                    image 'docker:20.10.16-cli' 
                    args '-v /var/run/docker.sock:/var/run/docker.sock' 
                }
            }
            steps {
                echo '--- 2. Construyendo Imagen Docker ---'
                dir('backend') {
                    // El build crea la imagen base sin tag de Docker Hub
                    sh "docker build -t ${IMAGE_NAME}:${VERSION} ."
                }
            }
        }

        stage('Pruebas Unitarias') {
            // Esta etapa debería fallar si hay errores en el código.
            steps {
                echo '--- 3. Ejecutando Pruebas (Simulación) ---'
                // Aquí deberías colocar la ejecución de tu script de pruebas, por ejemplo:
                // sh 'python -m pytest backend/tests/'
                sh 'echo "Tests completados exitosamente (Simulado)." '
            }
        }
        
        // =========================================================================
        // === ETAPAS DE DESPLIEGUE CONTINUO (CD) ===
        // =========================================================================

        stage('Tagging y Login Docker Hub') {
            agent {
                docker {
                    image 'docker:20.10.16-cli' 
                    args '-v /var/run/docker.sock:/var/run/docker.sock' 
                }
            }
            steps {
                echo '--- 4. Etiquetando la imagen ---'
                // Etiquetamos la imagen local con el formato requerido por Docker Hub
                sh "docker tag ${IMAGE_NAME}:${VERSION} ${FULL_IMAGE_NAME}"
                
                echo '--- 5. Login en Docker Hub ---'
                // Usamos las credenciales ID: dockerhub-credentials que creamos
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                    sh "docker login -u ${USER} -p ${PASS}"
                }
            }
        }

        stage('Push a Docker Hub') {
            agent {
                docker {
                    image 'docker:20.10.16-cli' 
                    args '-v /var/run/docker.sock:/var/run/docker.sock' 
                }
            }
            steps {
                echo "--- 6. Subiendo imagen ${FULL_IMAGE_NAME} a Docker Hub ---"
                // Subimos la imagen etiquetada
                sh "docker push ${FULL_IMAGE_NAME}"
            }
        }

        stage('Deployment (Local)') {
            agent {
                docker {
                    image 'docker:20.10.16-cli' 
                    args '-v /var/run/docker.sock:/var/run/docker.sock' 
                }
            }
            steps {
                echo '--- 7. Despliegue: Deteniendo y Eliminando Contenedor Anterior ---'
                // Detener contenedor si existe
                sh "docker stop ${IMAGE_NAME} || true"
                // Eliminar contenedor si existe
                sh "docker rm ${IMAGE_NAME} || true"

                echo '--- 8. Iniciando Nuevo Contenedor ---'
                // Iniciar el nuevo contenedor usando la imagen recién creada
                sh "docker run -d --name ${IMAGE_NAME} -p 8000:8000 ${FULL_IMAGE_NAME}"
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
            echo '✅ ¡Pipeline ejecutado con ÉXITO! La aplicación está desplegada en el puerto 8000.'
        }
        failure {
            echo '❌ El Pipeline ha fallado. Revisa los logs de la última etapa.'
        }
    }
}