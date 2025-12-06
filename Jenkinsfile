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
                dir('ci-docker-mongo-flutter/backend') {
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
        docker {
          image "${FULL_IMAGE_NAME}"
          args '-u root'
        }
      }
      steps {
        echo '--- Ejecutando pytest ---'
        // ejecutar dentro del workspace / backend; asegurar que pytest esté instalado en la imagen o se instale antes
        dir('ci-docker-mongo-flutter/backend') {
          sh '''
            python -m pip install --upgrade pip
            pip install -r requirements.txt
            pytest --junitxml=pytest-report.xml -q --disable-warnings --maxfail=1
          '''
        }
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
                    // CAMBIO 1: Usamos la imagen que ya sabemos que funciona y tiene la CLI de Docker
                    image 'docker:20.10.16-cli'
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                echo '--- 4. Despliegue: Levantando la Aplicación con Docker Compose (V2) ---'
                dir('.') {
                    // CAMBIO 2: Usamos la sintaxis V2 de Docker Compose (docker compose con espacio)
                    sh "docker compose down || true"
                    sh "docker compose up -d backend"
                    sh "echo 'Aplicación desplegada en http://localhost:8000. Revisar logs de Compose.'"
                }
            }
        }

        stage('Monitoreo') {
      steps {
        echo '--- Estado de contenedores ---'
        sh 'docker ps'
        sh 'docker stats --no-stream || true'
      }
    }
  } // stages

  post {
    always {
      echo '--- Limpieza workspace ---'
      cleanWs()
      // publicar resultado JUnit (ruta relativa desde workspace)
      junit 'ci-docker-mongo-flutter/backend/pytest-report.xml'
      archiveArtifacts artifacts: 'ci-docker-mongo-flutter/backend/pytest-report.xml', fingerprint: true
    }
    
    success {
        echo "✔ ¡Pipeline ejecutado con ÉXITO! Imagen ${FULL_IMAGE_NAME} desplegada."
        junit 'pytest-report.xml'
        archiveArtifacts artifacts: '*.xml', fingerprint: true
    }
    failure {
        echo '❌ El Pipeline ha FALLADO. Revisar los logs para más detalles.'
        junit 'pytest-report.xml'
        archiveArtifacts artifacts: '*.xml', fingerprint: true
    }
}