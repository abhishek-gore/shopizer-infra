pipeline {
    agent any
    
    environment {
        IMAGE_TAG = "${env.GIT_COMMIT}"
    }
    
    stages {
        stage('Build Artifacts') {
            parallel {
                stage('Backend') {
                    steps {
                        dir('../shopizer') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Admin') {
                    steps {
                        dir('../shopizer-admin') {
                            sh 'npm ci'
                            sh 'npm run build -- --configuration production'
                        }
                    }
                }
                stage('Shop') {
                    steps {
                        dir('../shopizer-shop-reactjs') {
                            sh 'npm ci'
                            sh 'npm run build'
                        }
                    }
                }
            }
        }
        
        stage('Build Images') {
            steps {
                dir('infra') {
                    sh './scripts/build-images.sh'
                }
            }
        }
        
        stage('Load to Colima') {
            steps {
                dir('infra') {
                    sh './scripts/load-images.sh'
                }
            }
        }
        
        stage('Deploy') {
            steps {
                dir('infra') {
                    sh './scripts/deploy.sh'
                }
            }
        }
        
        stage('Verify') {
            steps {
                sh 'kubectl get pods -n shopizer-local'
                sh 'kubectl get ingress -n shopizer-local'
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline completed'
        }
    }
}
