pipeline {
  agent any

  tools {
    maven "M3"
    jdk "JDK21"
  }
  environment {
    REGION = "ap-northeast-2"
    DOCKERHUB_CREDENTIALS = credentials('DockerCredentials')
    AWS_CREDENTIALS_NAME = credentials('AWSCredentials')
  }

  stages {
    // Git Clone
    stage('Git Clone') {
      steps {
        git url: 'https://github.com/sjh4616/spring-petclinic.git/', branch: 'main'
      }
    }
    // Maven을 이용해 Build 한다.
    stage('Maven Build') {
      steps {
        sh 'mvn -Dmaven.test.failure.ignore=true clean package'
      }
      post {
        success {
          echo 'Maven Build Success'
        }
        failure {
          echo 'Maven Build Failed'
        }
      }
    }
    // Docker Image 생성
    stage('Docker Image Build') {
      steps {
        echo 'Docker Image Build'
        dir("${env.WORKSPACE}") {
          sh """
          docker build -t spring-petclinic:$BUILD_NUMBER .
          docker tag spring-petclinic:$BUILD_NUMBER s4616/spring-petclinic:latest
          """
        }
      }
    }

    // Docker Image Upload
    stage('Docker Image Upload') {
      steps {
        echo 'Docker Image Upload'
        sh """
           echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
           docker push s4616/spring-petclinic:latest
           """
      }
    }

    // Docker Image Remove
    stage('Docker Image Remove') {
      steps {
        echo 'Docker Image Remove'
        sh 'docker rmi -f spring-petclinic:$BUILD_NUMBER'
      }
    }

    // Upload to S3
    stage('Upload to S3') {
      steps {
        echo 'Upload to S3'
        dir("$(env.WORKSPACE)") {
            sh 'zip -r scripts.zip ./scripts appspec.yml'
            withAWS(region:"${REGION}", credentials:"${AWS_CREDENTIALS_NAME}") {
              s3Upload(file:"scripts.zip", bucket:"user00-codedeploy-bucket")
            }
            sh 'rm -rf ./scripts.zip'
        }
      }
    }

    // Code Deploy
    stage('Codedeploy Workload') {
      steps {
        sh '''
           aws deploy create-deployment-group \
           --application-name user00-code-deploy \
           --auto-scaling-groups USER00-ASG-TARGET \
           --deployment-group-name user00-code-deploy-${BUILD_NUMBER} \
           --deployment-config-name CodeDeployDefault.OneAtATime \
           --service-role-arn arn:aws:iam::491085389788:role/user00-code-deploy-service-role
           '''
        sh '''
           aws deploy create-deployment --application-name user00-code-deploy \
           --deployment-config-name CodeDeployDefault.OneAtATime \
           --deployment-group-name user00-code-deploy-${BUILD_NUMBER} \
           --s3-location bucket=user00-codedeploy-bucket,bundleType=zip,key=scripts.zip
           '''
        sleep(10) // sleep 10s
      }
    }
  }  
}
