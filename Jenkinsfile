pipeline {
    agent any  
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        TF_IN_AUTOMATION      = '1'
    }
    stages {
        stage('terraform init') {
            steps {
                script {
                sh 'terraform init'
                }    
            }
        stage('terraform plan') {
            steps {
                script {
                sh 'terraform plan'
                }    
            }
        stage('terraform apply') {
        input{
            message "Do you want to apply for production deployment?"
        }
            steps {
                script {
                sh 'terraform apply -auto --approve'
                }    
            }
        }
        
    }
}
