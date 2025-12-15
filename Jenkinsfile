pipeline {
    agent any

    environment {
        DOCKERHUB_USER = "karlsite13"
        IMAGE_NAME = "backend-python"
        VERSION = "${BUILD_NUMBER}"
        FULL_IMAGE = "${DOCKERHUB_USER}/${IMAGE_NAME}:${VERSION}"
        TEST_REPORT = "ci-docker-mongo-flutter/backend/pytest-report.xml"
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
                  docker version
                  docker build -t $FULL_IMAGE ci-docker-mongo-flutter/backend
                '''
            }
        }

        stage('Run Unit Tests') {
            steps {
                sh '''
                  docker run --rm \
                    -v $PWD:/app \
                    -w /app/ci-docker-mongo-flutter/backend \
                    python:3.11-slim \
                    sh -c "pip install -r requirements.txt && pytest --junitxml=pytest-report.xml"
                '''
            }
        }

        stage('Docker Hub Login & Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                      echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                      docker push $FULL_IMAGE
                    '''
                }
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                dir('ci-docker-mongo-flutter') {
                    sh '''
                      docker compose down || true
                      docker compose up -d --build
                    '''
                }
            }
        }

        stage('Monitor') {
            steps {
                sh '''
                  docker ps
                  docker stats --no-stream
                '''
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: "${TEST_REPORT}", allowEmptyArchive: true
        }
        success {
            junit "${TEST_REPORT}"
        }
    }
}