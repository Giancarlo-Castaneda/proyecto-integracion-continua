pipeline {
    agent any

    environment {
        DOCKERHUB_USER = "karlsite13"
        IMAGE_NAME = "backend-python"
        VERSION = "${env.BUILD_NUMBER}"
        FULL_IMAGE = "${DOCKERHUB_USER}/${IMAGE_NAME}:${VERSION}"

        TEST_REPORT = "ci-docker-mongo-flutter/backend/pytest-report.xml"
    }

    stages {

        stage('Checkout') {
            steps {
                echo "📥 Clonando repositorio..."
                checkout scm
            }
        }

        stage('Build Backend Image') {
            steps {
                echo "🔧 Construyendo imagen Docker desde backend..."
                script {
                    docker.build(env.FULL_IMAGE, "ci-docker-mongo-flutter/backend")
                }
            }
        }

        stage('Run Unit Tests') {
            steps {
                echo "🧪 Ejecutando pytest dentro de contenedor Python..."
                script {
                    docker.image("python:3.11-slim").inside('-u 0') {
                        sh """
                            pip install --upgrade pip
                            pip install -r ci-docker-mongo-flutter/backend/requirements.txt
                            pytest ci-docker-mongo-flutter/backend/tests/test_message.py \
                                --junitxml=${TEST_REPORT}
                        """
                    }
                }
            }
        }

        stage('Docker Hub Login & Push') {
            steps {
                echo "📤 Subiendo imagen a Docker Hub..."
                script {
                    docker.withRegistry("https://registry.hub.docker.com", "dockerhub-credentials") {
                        docker.image(env.FULL_IMAGE).push()
                    }
                }
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                echo "🚀 Desplegando con docker compose..."
                dir('ci-docker-mongo-flutter') {
                    sh """
                        docker compose down || true
                        docker compose pull || true
                        docker compose up -d
                    """
                }
            }
        }

        stage('Monitor') {
            steps {
                sh "docker ps"
                sh "docker stats --no-stream || true"
            }
        }
    }

    post {
        always {
            echo "📦 Guardando reportes..."
            archiveArtifacts artifacts: "${TEST_REPORT}", allowEmptyArchive: true
        }
        success {
            echo "✔ Publicando resultados de pruebas"
            junit "${TEST_REPORT}"
        }
    }
}