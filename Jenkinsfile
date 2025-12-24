pipeline {
    agent any

    environment {
        DOCKERHUB_USER = 'karlsite13'
        IMAGE_NAME     = 'backend-python'
        VERSION        = "${BUILD_NUMBER}"
        FULL_IMAGE     = "${DOCKERHUB_USER}/${IMAGE_NAME}:${VERSION}"
        TEST_REPORT    = 'pytest-report.xml'
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

        stage('Run Unit Tests (Docker)') {
    steps {
        sh '''
        docker run --rm \
          -v $PWD/ci-docker-mongo-flutter/backend:/app \
          -w /app \
          backend-python:latest \
          pytest tests --junitxml=pytest-report.xml
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
                  docker stats --no-stream || true
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
