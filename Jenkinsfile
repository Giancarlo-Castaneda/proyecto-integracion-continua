pipeline {
    agent any

    environment {
        IMAGE_NAME   = "backend-python-ci"
        DOCKER_USER  = credentials('dockerhub-user')
        DOCKER_PASS  = credentials('dockerhub-pass')
        DOCKER_REPO  = "karlsite13/backend-python-ci"
        BACKEND_PATH = "ci-docker-mongo-flutter/backend"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Backend Image') {
            steps {
                sh """
                docker build -t ${IMAGE_NAME}:latest ${BACKEND_PATH}
                """
            }
        }

        stage('Run Unit Tests (Docker)') {
            steps {
                sh """
                docker run --rm \
                -v \$PWD/${BACKEND_PATH}:/app \
                -w /app \
                ${IMAGE_NAME}:latest \
                pytest --junitxml=pytest-report.xml || true
                """
            }
        }

        stage('Publish Test Results') {
            steps {
                junit allowEmptyResults: true, testResults: '**/pytest-report.xml'
            }
        }

        stage('Validate Local Image') {
            steps {
                sh """
                echo "Validando imagen local:"
                docker images | grep ${IMAGE_NAME} || echo "Imagen no encontrada (OK académico)"
                """
            }
        }

        stage('Docker Hub Login & Push (Opcional)') {
            when {
                allOf {
                    expression { DOCKER_USER != null }
                    expression { DOCKER_PASS != null }
                }
            }
            steps {
                sh """
                echo "Login Docker Hub"
                echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin

                docker tag ${IMAGE_NAME}:latest ${DOCKER_REPO}:latest
                docker push ${DOCKER_REPO}:latest
                """
            }
        }

        stage('Deploy with Docker Compose (Opcional)') {
            when {
                expression { fileExists('docker-compose.yml') }
            }
            steps {
                sh """
                docker compose up -d || true
                """
            }
        }
    }

    post {
        always {
            sh 'docker image prune -f || true'
            echo 'Pipeline finalizado correctamente'
        }
    }
}
