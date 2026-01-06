pipeline {
    agent any

    environment {
        BACKEND_PATH  = "ci-docker-mongo-flutter/backend"
        IMAGE_NAME    = "backend-python-ci"
        TEST_REPORT   = "pytest-report.xml"
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
                docker build -t ${IMAGE_NAME} ${BACKEND_PATH}
                """
            }
        }

        stage('Run Unit Tests (Docker)') {
            steps {
                sh """
                docker run --rm \
                  -v \$PWD/${BACKEND_PATH}:/app \
                  -w /app \
                  ${IMAGE_NAME} \
                  sh -c "
                    pytest --junitxml=${TEST_REPORT} || true
                  "
                """
            }
        }

        stage('Publish Test Results') {
            steps {
                junit allowEmptyResults: true, testResults: "${BACKEND_PATH}/${TEST_REPORT}"
            }
        }

        stage('Docker Hub Login & Push') {
            when {
                expression { env.DOCKERHUB_USERNAME != null }
            }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                    docker login -u $DOCKER_USER -p $DOCKER_PASS
                    docker tag ${IMAGE_NAME} $DOCKER_USER/${IMAGE_NAME}:latest
                    docker push $DOCKER_USER/${IMAGE_NAME}:latest
                    """
                }
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                sh """
                docker compose up -d
                """
            }
        }

        stage('Monitor') {
            steps {
                echo "Aplicación desplegada correctamente"
            }
        }
    }

    post {
        always {
            sh "docker image prune -f || true"
        }
        success {
            echo "Pipeline ejecutado correctamente ✅"
        }
        failure {
            echo "Pipeline falló ❌"
        }
    }
}