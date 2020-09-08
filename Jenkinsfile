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
      steps {
        echo 'Building docker Image'
        sh 'docker build -f Dockerfile -t capstone .'
        echo 'Validating Build'
        sh 'docker images capstone'
      }
    }

    stage('Tag File to Latest') {
      steps {
        echo 'Retrieve Auth Token'
        sh 'aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 833142362823.dkr.ecr.us-east-2.amazonaws.com'
        echo 'Tagging Image'
        sh 'docker tag capstone:latest 833142362823.dkr.ecr.us-east-2.amazonaws.com/capstone:latest'
      }
    }

    stage('Push Image to ECR') {
      steps {
        sh 'docker push 833142362823.dkr.ecr.us-east-2.amazonaws.com/capstone:latest'
      }
    }

  }
}