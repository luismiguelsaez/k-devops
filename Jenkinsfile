
pipeline{
    agent{
        label "docker"
    }
    environment {
      LITECOIN_VERS = "0.18.1"
      AWS_DEFAULT_REGION = "eu-central-1"
      K8S_CLUSTER_NAME = "test"
    }
    stages{
        stage("Build docker image"){
            steps{
                sh "docker build --build-arg PKG_VERS=${env.LITECOIN_VERS} -t litecoind:${env.LITECOIN_VERS} ."
            }
        }
        stage("Scan docker image"){
            steps{
                sh "trivy image -s critical,high --exit-code 1 litecoind:${env.LITECOIN_VERS}"
            }
        }
        stage("Publish docker image"){
            steps{
                withCredentials([
                  string(credentialsId: 'DOCKERHUB_USER', variable: 'DOCKERHUB_USER'),
                  string(credentialsId: 'DOCKERHUB_PASS', variable: 'DOCKERHUB_PASS')
                ]) {
                    sh "docker login -u ${DOCKERHUB_USER} -p ${DOCKERHUB_PASS}"
                    sh "docker tag  litecoind:${env.LITECOIN_VERS} ${DOCKERHUB_USER}/litecoind:${env.LITECOIN_VERS}"
                    sh "docker push ${DOCKERHUB_USER}/litecoind:${env.LITECOIN_VERS}"
                }
            }
        }
        stage("Deploy"){
            steps {
                withCredentials([
                  string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                  string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh "aws eks --region ${env.AWS_REGION} update-kubeconfig --name ${env.K8S_CLUSTER_NAME}"
                    sh "kubectl apply -f k8s/statefulset.yaml"
                }
            }
        }
    }
    post{
        always{
          slackSend(
            channel: "deploy-notifications",
            message: "#${env.BUILD_NUMBER} ${currentBuild.result} (<${env.BUILD_URL}|Open>)"
          )
        }
    }
}