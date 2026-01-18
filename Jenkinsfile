pipeline {

    agent any

    environment {
        IMAGE_NAME      = "backend-python-ci"
        DOCKER_REPO     = "karlslite13/backend-python-ci"
        BACKEND_PATH    = "ci-docker-mongo-flutter/backend"

        // Variables para Telegram
        TELEGRAM_TOKEN = credentials('telegram-token')
        TELEGRAM_CHAT  = "-100XXXXXXXXXX"   // <-- tu grupo
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

        stage('Run Unit Tests') {
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
                junit allowEmptyResults: true, testResults: "**/pytest-report.xml"
            }
        }

        stage('Push Image to DockerHub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-user',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    docker tag ${IMAGE_NAME}:latest ${DOCKER_REPO}:latest
                    docker push ${DOCKER_REPO}:latest
                    """
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'aws-ec2-key',
                    keyFileVariable: 'SSH_KEY',
                    usernameVariable: 'SSH_USER'
                )]) {
                    sh """
                    ssh -o StrictHostKeyChecking=no -i $SSH_KEY $SSH_USER@${IP_PUBLICA_EC2} \
                        "docker pull ${DOCKER_REPO}:latest &&
                         docker compose -f docker-compose.prod.yml up -d"
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completado correctamente"

            // -------- TELEGRAM ----------
            sh """
            curl -s -X POST https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage \
                -d chat_id=${TELEGRAM_CHAT} \
                -d text="✔ Pipeline completado con éxito en EC2"
            """
        }

        failure {
            echo "Pipeline falló"

            sh """
            curl -s -X POST https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage \
                -d chat_id=${TELEGRAM_CHAT} \
                -d text="❌ Pipeline falló. Revisar Jenkins."
            """
        }

        always {
            sh "docker image prune -f || true"
        }
    }
}
