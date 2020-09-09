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
        echo 'Tagging Image'
        sh 'docker tag capstone:latest 833142362823.dkr.ecr.us-east-2.amazonaws.com/capstone:latest'
      }
    }

    stage('Push Image to ECR') {
      steps {   
        script {
          docker.withRegistry('https://833142362823.dkr.ecr.us-east-2.amazonaws.com', 'ecr:us-east-2:aws-creds'){
            docker.image('capstone').push('latest')
          }
        }
      }
    }

    stage('Deploy on Dev') {
      steps {
        withEnv(['IMAGE=833142362823.dkr.ecr.us-east-2.amazonaws.com/capstone:latest']){
          sh "sed -i 's|IMAGE|${IMAGE}|g' capstone-k8s/deployment.yaml"
          sh "sed -i 's|ENVIRONMENT|dev|g' capstone-k8s/*.yaml"
          sh "kubectl apply -f capstone-k8s"
          DEPLOYMENT = sh (
            script: 'cat capstone-k8s/deployment.yaml | grep -m 1 name | awk \'{print \$2}\'',
            returnStdout: true
          ).trim()
          echo "Creating kubernetes resources..."
          sleep 180
          sh (
            script: 'kubectl get deployment/$DEPLOYMENT',
            returnStdout:true
          )
        }
      }
    }
  }
}