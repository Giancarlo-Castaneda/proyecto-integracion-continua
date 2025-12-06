pipeline {
    agent any

    options {
        timeout(time: 20, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    environment {
        IMAGE_NAME = "mi-backend-python"
        DOCKERHUB_USERNAME = "karlsite13"
        VERSION = "${env.BUILD_NUMBER}"
        FULL_IMAGE_NAME = "${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${VERSION}"
    }

    stages {

        stage('Checkout') {
            steps {
                echo "--- Checkout del repositorio ---"
                sh 'git config --global http.sslVerify false'
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
                echo "--- Construyendo imagen Docker ---"
                dir('ci-docker-mongo-flutter/backend') {
                    sh """
                        pwd
                        ls -la
                        docker build -t ${FULL_IMAGE_NAME} .
                    """
                }
            }
        }

        stage('Pruebas Unitarias') {
            steps {
                echo "--- Ejecutando pytest ---"

                dir('ci-docker-mongo-flutter/backend') {
                    sh """
                        pip install --upgrade pip
                        pip install -r requirements.txt
                        pytest --junitxml=pytest-report.xml -q --disable-warnings --maxfail=1
                    """
                }
            }
        }

        stage('Login y Push') {
            steps {
                echo "--- Subiendo a DockerHub ---"
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS'
                )]) {
                    sh "docker login -u ${USER} -p ${PASS}"
                }
                sh "docker push ${FULL_IMAGE_NAME}"
            }
        }

        stage('Despliegue (Compose)') {
            agent {
                docker {
                    image 'docker:20.10.16-cli'
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                echo "--- Despliegue con docker compose ---"
                dir('.') {
                    sh "docker compose down || true"
                    sh "docker compose up -d backend"
                    sh "echo Aplicación desplegada en http://localhost:8000"
                }
            }
        }

        stage('Monitoreo') {
            steps {
                echo "--- Estado de contenedores ---"
                sh "docker ps"
                sh "docker stats --no-stream || true"
            }
        }
    }

    post {

        always {
            echo "--- Archivando artefactos ---"
            archiveArtifacts artifacts: 'ci-docker-mongo-flutter/backend/pytest-report.xml', fingerprint: true

            echo "--- Publicando resultados JUnit ---"
            junit 'ci-docker-mongo-flutter/backend/pytest-report.xml'

            echo "--- Limpieza Workspace ---"
            cleanWs()
        }

        success {
            echo "✓ Pipeline ejecutado con ÉXITO. Imagen ${FULL_IMAGE_NAME} creada y desplegada."
        }

        failure {
            echo "✗ El Pipeline ha fallado. Revisar logs en consola."
        }
    }
}