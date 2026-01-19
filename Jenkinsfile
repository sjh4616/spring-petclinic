pipeline {
  agent any

  tools {
    maven "M3"
    jdk "JDK17"
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
      }
    }

     
      
  }  
}




