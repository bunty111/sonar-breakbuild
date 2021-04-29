//test
node() {
    def mvnHome
    stage('Preparation') { 
        
       checkout scm
        
        mvnHome = tool 'maven'
    }
     
    stage("sonar"){
      withSonarQubeEnv('sonarqube-rec') {
              withEnv(["MVN_HOME=$mvnHome"]) {      
               
               sh '"$MVN_HOME/bin/mvn" sonar:sonar -D sonar.login=52b5b0610360297f8ad77eabda67fba79c0f06c6'
		      }
          }   
    } 
    stage("sonar-qualitygate"){
	    withCredentials([string(credentialsId: 'sonar_token', variable: 'sonar_token')]) {
		    sh 'sh breakbuild.sh http://3.14.110.70:9000/ ${sonar_token}'
               
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

