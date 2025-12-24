pipeline {
    agent any

    environment {
        // Docker Hub
        DOCKERHUB_CREDENTIALS = 'dockerhub-credentials'
        DOCKERHUB_USER        = 'karlitos13'

        // Imágenes
        BACKEND_IMAGE = 'backend-python:ci'
        BACKEND_PATH  = 'ci-docker-mongo-flutter/backend'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Backend Image') {
            steps {
                sh '''
                docker build \
                  -t ${BACKEND_IMAGE} \
                  ${BACKEND_PATH}
                '''
            }
        }

        stage('Run Unit Tests (Docker)') {
            steps {
                sh '''
                docker run --rm \
                  -v $PWD/${BACKEND_PATH}:/app \
                  -w /app \
                  ${BACKEND_IMAGE} \
                  pytest tests --junitxml=pytest-report.xml
                '''
            }
        }

        stage('Docker Hub Login & Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: "${DOCKERHUB_CREDENTIALS}",
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                    docker login -u "$DOCKER_USER" -p "$DOCKER_PASS"
                    docker tag ${BACKEND_IMAGE} ${DOCKERHUB_USER}/${BACKEND_IMAGE}
                    docker push ${DOCKERHUB_USER}/${BACKEND_IMAGE}
                    '''
                }
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                sh '''
                docker compose \
                  -f docker-compose.yml \
                  up -d --build
                '''
            }
        }

        stage('Monitor') {
            steps {
                sh '''
                docker ps
                '''
            }
        }
    }

    post {
        always {
            junit 'ci-docker-mongo-flutter/backend/pytest-report.xml'
        }
        cleanup {
            sh '''
            docker image prune -f
            '''
        }
    }
}