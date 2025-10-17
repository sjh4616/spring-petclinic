pipeline {
  agent any

  tools {
    maven 'M3'
    jdk 'JDK21'
  }
  environment {
    DOCKERHUB_CREDENTIALS = credentials('dockerCredential')
  }

  stages {
    // GitHub Clone
    stage('Git Clone') {
      steps {
        git url: 'https://github.com/sjh4616/spring-petclinic.git/', branch: 'main'
      }
    }

    // Maven Build
    stage('Maven Build') {
      steps {
        sh 'mvn -Dmaven.test.failure.ignore=true clean package'
      }
    }

    // Docker Image 생성
    stage('Docker Image Build') {
      steps {
        dir("${env.WORKSPACE}") {
          sh """
          docker build -t spring-petclinic:$BUILD_NUMBER .  
          docker tag spring-petclinic:$BUILD_NUMBER s4616/spring-petclinic:latest
          """
        }
      }
    }

    // Docker Login and Push
    stage ('Docker Login and Push') {
      steps {
        sh """
        echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
        docker push s4616/spring-petclinic:latest
        """
      }
    }

    // Docker Image Remove
    stage ('Docker Image Remove') {
      steps {
      sh """
      docker rmi spring-petclinic:$BUILD_NUMBER
      docker rmi s4616/spring-petclinic:latest
      """
      }
    }

    // Target Server Docker Container
    stage ('Docker Container') {
      steps {
        sshPublisher(publishers: [sshPublisherDesc(configName: 'target', 
        transfers: [sshTransfer(cleanRemote: false, 
        excludes: '', 
        execCommand: '''
        docker rm -f $(docker ps -aq)
        docker rmi $(docker images -q)
        docker run -itd -p 80:8080 --name=spring-petclinic s4616/spring-petclinic:latest
        ''', 
        execTimeout: 120000, 
        flatten: false, 
        makeEmptyDirs: false, 
        noDefaultExcludes: false, 
        patternSeparator: '[, ]+', 
        remoteDirectory: '', 
        remoteDirectorySDF: false, 
        removePrefix: 'target', sourceFiles: '')], 
        usePromotionTimestamp: false, 
        useWorkspaceInPromotion: false, 
        verbose: false)])
      }
    }    
  }
}












