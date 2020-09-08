pipeline {
  environment {
    registry = '833142362823.dkr.ecr.us-east-2.amazonaws.com'
    registryCredential = 'aws-cred'
    dockerImage = ''
  }
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
      docker.withRegistry("https://" + registry, "ecr:us-east-2:"+ registryCredential){
        docker.image('capstone').push('latest')
      }
    }

  }
}