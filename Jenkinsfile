pipeline {
    agent any
    
    tools {
        maven "M3"
        jdk "JDK17"
    }

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerCredential')
    }
    
    stages {
        stage('Git Clone') {
            steps {
                echo 'Git Clone'
                git url: 'https://github.com/sjh4616/spring-petclinic.git',
                    branch: 'main'
            }
            post {
                success {
                    echo 'Git Clone Success'
                }
                failure {
                    echo 'Git Clone Fail'
                }
            }
        }
        // Maven build 작업
        stage('Maven Build') {
            steps {
                echo 'Maven Build' 
                sh 'mvn -Dmaven.test.failure.ignore=true clean package' // Test error 무시
            }            
        }

        // Docker Image 생성
        stage('Docker Image Build') {
            steps {
                echo 'Docker Image Build'
                dir("${env.WORKSPACE}") {
                   sh '''
                      docker build -t spring-petclinic:$BUILD_NUMBER .
                      docker tag spring-petclinic:$BUILD_NUMBER s4616/spring-petclinic:latest
                      '''
                }
            }
        }

        // Docker Image Push
        stage('Docker Image Push') {
            steps { 
                sh '''
                echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                docker push s4616/spring-petclinic:latest
                '''
            }
        }


        
        stage('SSH Publish') {
            steps {
                echo 'SSH Publish'
                sshPublisher(publishers: [sshPublisherDesc(configName: 'target', 
                transfers: [sshTransfer(cleanRemote: false, excludes: '', 
                execCommand: '''fuser -k 8080/tcp
                export BUILD_ID=PetClinic
                nohup java -jar spring-petclinic-3.4.0-SNAPSHOT.jar >> nohup.out 2>&1 &''',
                execTimeout: 120000, 
                flatten: false, 
                makeEmptyDirs: false, 
                noDefaultExcludes: false, 
                patternSeparator: '[, ]+', 
                remoteDirectory: '', 
                remoteDirectorySDF: false, 
                removePrefix: 'target', 
                sourceFiles: 'target/*.jar')], 
                usePromotionTimestamp: false, 
                useWorkspaceInPromotion: false, verbose: false)])
            }
        }
    }
}
