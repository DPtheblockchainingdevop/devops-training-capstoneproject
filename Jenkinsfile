pipeline {
  agent any
  stages {
    stage('Linting') {
      steps {
        echo 'Linting HTML files'
        sh 'tidy -q -e index.html'
        echo 'Linting Dockerfile'
        sh 'ls -al'
        sh 'hadolint --ignore DL3009 --ignore DL3015 Dockerfile'
      }
    }

    stage('Build Docker Image') {
      docker.build('capstone')
    }

    stage('Push Image to ECR') {
      docker.withRegistry('https://833142362823.dkr.ecr.us-east-2.amazonaws.com', 'ecr:us-east-2:aws-cred'){
        docker.image('capstone').push('latest')
      }
    }

  }
}