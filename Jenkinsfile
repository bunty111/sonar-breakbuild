//test
node() {
    def mvnHome
    stage('Preparation') { 
        
        git 'https://github.com/vytec-app/vytecapp.git'
        
        mvnHome = tool 'maven'
    }
     
    stage("sonar"){
      withSonarQubeEnv('sonarqube-rec') {
              withEnv(["MVN_HOME=$mvnHome"]) {      
               
               sh '"$MVN_HOME/bin/mvn" sonar:sonar'
            
		      }
          }   
    } 
    stage("sonar-qualitygate"){
	    withCredentials([string(credentialsId: 'sonar_token', variable: 'sonar_token')]) {
	    sh 'sh breakbuild.sh http://ip-172-31-47-61.us-east-2.compute.internal:9000 52b5b0610360297f8ad77eabda67fba79c0f06c6'
               
	    }
    }
    stage('Build') {
        withEnv(["MVN_HOME=$mvnHome"]) {       
            if (isUnix()) {
                sh '"$MVN_HOME/bin/mvn" -Dmaven.test.failure.ignore -P vytecapp-deploy clean deploy'
            } else {
                bat(/"%MVN_HOME%\bin\mvn" -Dmaven.test.failure.ignore clean package/)
            }
          
        }
    }
    stage('Results') {
        junit '**/target/surefire-reports/TEST-*.xml'
        archiveArtifacts 'target/*.jar'
    }
}

