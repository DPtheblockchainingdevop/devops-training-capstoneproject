pipeline {
  agent any
  stages {
    stage('Linting') {
      steps {
        echo 'Linting HTML files'
        sh 'tidy -q -e *.html'
        echo 'Linting Dockerfile'
        sh 'hadolint Dockerfile'
      }
    }

    stage('Build Docker Image') {
      steps {
        echo 'Building docker Image'
        sh 'docker build -f Dockerfile -t capstone/ngix-project:latest .'
        echo 'Validating Build'
        sh 'docker images capstone/ngix-project:latest'
      }
    }

  }
}