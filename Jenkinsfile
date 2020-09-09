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
          docker.withRegistry('https://833142362823.dkr.ecr.us-east-2.amazonaws.com', 'ecr:us-east-2:aws-creds') {
            docker.image('capstone').push('latest')
          }
        }
      }
    }

    stage('Deploy on Dev') {
      steps {
        withEnv(["KUBECONFIG=${JENKINS_HOME}/.kube/config",'AWS_PROFILE=default',"AWS_SHARED_CREDENTIALS_FILE=${JENKINS_HOME}/.aws/credentials",'IMAGE=833142362823.dkr.ecr.us-east-2.amazonaws.com/capstone:latest']){
          sh "sed -i 's|IMAGE|${IMAGE}|g' capstone-k8s/dev/deployment.yaml"
          sh "sed -i 's|ENVIRONMENT|dev|g' capstone-k8s/dev/*.yaml"
          // echo "Using kube config from: ${KUBECONFIG}"
          // echo "Using aws shared file : ${AWS_SHARED_CREDENTIALS_FILE}"
          // echo "Using aws profile: ${AWS_PROFILE}"
          // sh "printenv"
          sh "kubectl apply -f capstone-k8s/dev/deployment.yaml"
          script {
            DEPLOYMENT = sh (
              script: "cat capstone-k8s/dev/deployment.yaml | grep -m 1 name | awk '{print \$2}'",
              returnStdout: true
            ).trim()
            echo "Creating kubernetes resources..."
            sleep 60
            echo "Deployment: $DEPLOYMENT"
            CURRENT = sh (
              script: "kubectl get deployment/$DEPLOYMENT | awk '{print \$3}' | grep -v UP-TO-DATE",
              returnStdout: true
            ).trim()
            DESIRED = sh (
              script: "kubectl get deployment/$DEPLOYMENT | awk '{print \$4}' | grep -v AVAILABLE",
              returnStdout: true
            ).trim()
            // echo "CURRENT: $CURRENT"
            // echo "DESIRED: $DESIRED"
            if (DESIRED.equals(CURRENT)) {
              echo "SUCCESS"
              sh "kubectl apply -f capstone-k8s/dev/service.yaml"
            }
            else {
              echo "FAILURE"
            }
          }
        }
      }
    }

    stage('Deploy to Prod'){
      steps {
        withEnv(["KUBECONFIG=${JENKINS_HOME}/.kube/config",'AWS_PROFILE=default',"AWS_SHARED_CREDENTIALS_FILE=${JENKINS_HOME}/.aws/credentials",'IMAGE=833142362823.dkr.ecr.us-east-2.amazonaws.com/capstone:latest']){
          sh "sed -i 's|IMAGE|${IMAGE}|g' capstone-k8s/prod/deployment.yaml"
          sh "sed -i 's|ENVIRONMENT|prod|g' capstone-k8s/prod/*.yaml"
          sh "kubectl apply -f capstone-k8s/prod/deployment.yaml"
          script {
            echo "Deploying to Production..."
            DEPLOYMENT = sh (
              script: "cat capstone-k8s/prod/deployment.yaml | grep -m 1 name | awk '{print \$2}'",
              returnStdout: true
            ).trim()
            echo "Creating kubernetes resources..."
            sleep 60
            echo "Deployment: $DEPLOYMENT"
            CURRENT = sh (
              script: "kubectl get deployment/$DEPLOYMENT | awk '{print \$3}' | grep -v UP-TO-DATE",
              returnStdout: true
            ).trim()
            DESIRED = sh (
              script: "kubectl get deployment/$DEPLOYMENT | awk '{print \$4}' | grep -v AVAILABLE",
              returnStdout: true
            ).trim()
            // echo "CURRENT: $CURRENT"
            // echo "DESIRED: $DESIRED"
            if (DESIRED.equals(CURRENT)) {
              echo "SUCCESS"
              sh "kubectl apply -f capstone-k8s/prod/service.yaml"
              sleep 60
              PROD_URL = sh (
                script: "kubectl get svc ${DEPLOYMENT} -o jsonpath=\"{.status.loadBalancer.ingress[*].hostname}\"",
                returnStdout: true
              ).trim()
              echo "Production URL: ${PROD_URL}"
              RESPONSE = sh (
                script: "curl -s -o /dev/null -w \"%{http_code}\" http://${PROD_URL}",
                returnStdout: true
              ).trim()
              echo "RESPONSE:${RESPONSE}"
            }
            else {
              echo "FAILURE"
            }
            if (RESPONSE == "200"){
              echo "Application is working fine"
            }
            else{
              echo "Application did not pass the test case."
              echo "Production application deployment FAILURE"
            }
          }
        }
      }
    }
  }
}