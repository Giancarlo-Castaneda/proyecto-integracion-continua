pipeline {
    agent any

    environment {
        DOCKERHUB_USER = "karlsitle3"
        IMAGE_NAME     = "backend-python"
        VERSION        = "${env.BUILD_NUMBER}"
        FULL_IMAGE     = "${DOCKERHUB_USER}/${IMAGE_NAME}:${VERSION}"

        TEST_REPORT = "ci-docker-mongo-flutter/backend/pytest-report.xml"
    }

    stages {

        /* --------------------------
         * CHECKOUT
         * -------------------------- */
        stage('Checkout') {
            steps {
                echo "📥 Clonando repositorio..."
                checkout scm
            }
        }

        /* --------------------------
         * BUILD BACKEND IMAGE
         * -------------------------- */
        stage('Build Backend Image') {
            agent {
                docker {
                    image 'docker:24.0.5-dind'
                    args  '--privileged -v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                echo "⚙️ Construyendo imagen Docker del backend..."

                sh """
                docker build -t ${FULL_IMAGE} ci-docker-mongo-flutter/backend
                """
            }
        }

        /* --------------------------
         * RUN UNIT TESTS
         * -------------------------- */
        stage('Run Unit Tests') {
            agent {
                docker {
                    image 'python:3.11-slim'
                }
            }
            steps {
                echo "🧪 Ejecutando pruebas unitarias..."

                sh """
                pip install --upgrade pip
                pip install -r ci-docker-mongo-flutter/backend/requirements.txt
                pytest ci-docker-mongo-flutter/backend/tests \
                    --junitxml=${TEST_REPORT} || true
                """
            }
        }

        /* --------------------------
         * LOGIN & PUSH DOCKER HUB
         * -------------------------- */
        stage('Docker Hub Login & Push') {
            agent {
                docker {
                    image 'docker:24.0.5-dind'
                    args '--privileged -v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                echo "📦 Subiendo imagen a Docker Hub..."

                script {
                    docker.withRegistry("https://registry.hub.docker.com", "dockerhub-credentials") {
                        sh "docker push ${FULL_IMAGE}"
                    }
                }
            }
        }

        /* --------------------------
         * DEPLOY WITH DOCKER COMPOSE
         * -------------------------- */
        stage('Deploy with Docker Compose') {
            agent {
                docker {
                    image 'docker:24.0.5-dind'
                    args '--privileged -v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                echo "🚀 Desplegando aplicación con docker-compose..."

                dir('ci-docker-mongo-flutter') {
                    sh """
                    docker compose down || true
                    docker compose pull || true
                    docker compose up -d backend
                    """
                }
            }
        }

        /* --------------------------
         * MONITOR
         * -------------------------- */
        stage('Monitor') {
            agent {
                docker {
                    image 'docker:24.0.5-dind'
                    args '--privileged -v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                echo "📊 Monitorizando contenedores..."
                sh "docker ps"
                sh "docker stats --no-stream || true"
            }
        }
    }

    /* --------------------------
     * POST ACTIONS
     * -------------------------- */
    post {
        always {
            echo "📁 Guardando artefactos..."
            archiveArtifacts artifacts: "${TEST_REPORT}", allowEmptyArchive: true
        }

        success {
            echo "✅ Publicando resultados de pruebas..."
            junit "${TEST_REPORT}"
        }

        failure {
            echo "❌ Fallo detectado: Publicando reporte..."
            junit "${TEST_REPORT}"
        }
    }
}