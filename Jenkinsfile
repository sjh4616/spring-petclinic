pipeline {
  agent any

  tools {
    maven "M3"
    jdk "JDK17"
  }

  stages {
    stage('Git Clone') {
      steps {
        git url: 'https://github.com/sjh4616/spring-petclinic.git/', branch: 'main'
      }
    }
    
  }  
}




