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
        dir('ci-docker-mongo-flutter/backend') {
            sh '''
                echo ">>> Construyendo backend..."
                docker build -t ${FULL_IMAGE_NAME} .
            '''
        }
    }
}

        stage('Pruebas Unitarias') {
    steps {
        dir('ci-docker-mongo-flutter/backend') {
            sh '''
                pip install -r requirements.txt
                pytest --junitxml=pytest-report.xml
            '''
        }
    }
}
            post {
                always {
                    junit 'backend/pytest-report.xml'
                }
            }
        }

        stage('Login y Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials',                    usernameVariable: 'USER',
                passwordVariable: 'PASS')]) {
                    sh "docker login -u ${USER} -p ${PASS}"
                }
                sh "docker push ${FULL_IMAGE_NAME}"
            }
        }

        stage('Despliegue (Compose)') {
            agent {
                docker {
                    image 'docker:24.0.5-dind'
                    args '--privileged -v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                dir('.') {
                    sh '''
                        echo "Redeploying app..."
                        docker compose down || true
                        docker compose up -d backend
                    '''
                }
            }
        }

        stage('Monitoreo') {
            steps {
                sh 'docker ps'
                sh 'docker stats --no-stream || true'
            }
        }
    }

    post {
    always {
        archiveArtifacts artifacts: 'ci-docker-mongo-flutter/backend/pytest-report.xml', fingerprint: true
    }
    success {
        junit 'ci-docker-mongo-flutter/backend/pytest-report.xml'
    }
    failure {
        junit 'ci-docker-mongo-flutter/backend/pytest-report.xml'
    }
}

}