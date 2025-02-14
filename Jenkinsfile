pipeline {
    agent any
        environment {
        USER_CREDENTIALS = credentials('dw_ad')
        GITHUB_TOKEN = credentials('Jenkins-GitHub-Token')
        DEV_HOST = "dev-app-1.internallifestance.com"
        QA_HOST = "qa-app-1.internallifestance.com"
    }
    options {
      disableConcurrentBuilds()  
    }
    stages {
         stage('Build') {
            when {
               changeRequest()
            }
            steps {
                echo "Installing packages"
                sh 'bundle install'
            }
        }
        stage('Unit Test') {
          when {
            changeRequest()
          }
          steps {
              catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                echo "Running Unit Tests"     
                sh "cp -f /lfs/secrets/test.key config/credentials/"
                sh "cp -f /lfs/secrets/wicked_pdf.rb config/initializers/"
                sh "cp -f /lfs/secrets/database.yml config/"
                sh "cp -f /lfs/certs/private.key ./"
                sh "cp -f /lfs/certs/advancedmd-pub-cert.pem ./"
                sh '''
                   sed -i "s/polaris_test/polaris_temp_$RANDOM/g" config/database.yml 
                   sed -i "s/polaris_dw_test/polaris_dw_temp_$RANDOM/g" config/database.yml 
                '''
                sh "cp -f /lfs/secrets/redis.yml config/"
                sh 'bin/rails db:migrate:reset RAILS_ENV=test'
                sh '''
                    EXIT_CODE=0
                    RAILS_ENV='test' bundle exec rspec || EXIT_CODE=$?  
                    if [ $EXIT_CODE -eq 0 ]; then 
                      echo "Unit Tests Successfull"
                      curl -i -u jenkins-lfs:$GITHUB_TOKEN \
                      -X POST \
                      -H "Accept: application/vnd.github.v3+json" \
                       https://api.GitHub.com/repos/LifeStanceHealth/polaris/statuses/$GIT_COMMIT \
                       -d '{"state":"success", "context":"Unit-Test"}'
                     else
                       echo "Tests Failed"
                       curl -i -u jenkins-lfs:$GITHUB_TOKEN \
                       -X POST \
                       -H "Accept: application/vnd.github.v3+json" \
                        https://api.GitHub.com/repos/LifeStanceHealth/polaris/statuses/$GIT_COMMIT \
                        -d '{"state":"failure", "context":"Unit-Test"}'
                      fi
                    bin/rails db:drop RAILS_ENV=test
                '''              
            }
          }
        }
        stage('Packaging Application') {
            when {
               changeRequest()
            }
            steps {
                sh 'rm -f ror-*.zip'
                sh 'zip -r ror-$CHANGE_ID-$BUILD_ID.zip * -x Jenkinsfile'
                sh 'curl -u $USER_CREDENTIALS_USR:$USER_CREDENTIALS_PSW -T ror-$CHANGE_ID-$BUILD_ID.zip http://mgmt-artifactory-1.internallifestance.com:8081/artifactory/lfs-local-repo/lfs/ror/$CHANGE_ID-$BUILD_ID/'
            }
        }
        stage('Select Env to Deploy'){
            when {
               beforeInput true
               changeRequest()
            }
            steps{
              script {
                  try {
                    timeout(time: 5, unit: 'MINUTES') {
                      script{
                          def environment = input message: "Select an Environment to Deploy?", ok: "Select", parameters: [
                          choice(name: 'environment', choices: ['Nothing','Dev','QA'], description: 'Please select the environment to deploy')
                          ]
                          env.environment = environment
                          echo "Environment selected: $environment"
                          }
                       }
                    }
                    catch(Exception err){
                        env.environment = "Nothing"
                    }
                }
            }
        }

        stage ('ENV Selected') {
          when {
            beforeInput true
            changeRequest()
          }
          parallel {
            stage('Dev') {
              when {
                equals expected: 'Dev', actual: environment
              }
              steps {
                script {
                catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                  echo 'Deploying to DEV Environment'
                  sh 'ssh -tt -o StrictHostKeyChecking=no $DEV_HOST "/lfs/scripts/deploy.sh $USER_CREDENTIALS_USR $USER_CREDENTIALS_PSW $CHANGE_ID $BUILD_ID"'
                  def JiraId = sh (script: 'echo ${CHANGE_BRANCH} | cut -d "/" -f 2' , returnStdout: true).trim()
                  echo "${JiraId}"
                  response = jiraGetIssue idOrKey: JiraId, site: 'Lifestance'
                  def statusResponse = response.data.fields.status.name.toString()
                      if (statusResponse == "Dev Complete" || statusResponse == "In QA Testing") {
                        echo "No Jira transition Needed"
                      }
                      else {
                        def transitionInput = [ transition: [ id: 121 ] ]
                        jiraTransitionIssue idOrKey: JiraId , input: transitionInput, site: 'Lifestance'
                      }
                  }
                }
              }
            }
            stage('QA') {
              when {
                equals expected: 'QA', actual: environment
              }
              steps {
                script {
                catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                  echo 'Deploying to QA Environment'
                  sh 'ssh -tt -o StrictHostKeyChecking=no $QA_HOST "/lfs/scripts/deploy.sh $USER_CREDENTIALS_USR $USER_CREDENTIALS_PSW $CHANGE_ID $BUILD_ID"'
                  def JiraId = sh (script: 'echo ${CHANGE_BRANCH} | cut -d "/" -f 2' , returnStdout: true).trim()
                  echo "${JiraId}"
                  response = jiraGetIssue idOrKey: JiraId, site: 'Lifestance'
                  def statusResponse = response.data.fields.status.name.toString()
                      if (statusResponse == "In QA Testing") {
                        echo "No Jira transition Needed"
                      }
                      else {
                        def transitionInput = [ transition: [ id: 141 ] ]
                        jiraTransitionIssue idOrKey: JiraId , input: transitionInput, site: 'Lifestance'
                      }
                 }
                }
              }
            }
          }
        }
        stage('Alert'){
          when {
            not { changeRequest() }
          }

            steps {
                echo 'Please build from Pull requests'
            }
        }
    }

 post{
    success{
        script{
          if (env.environment == "Dev" || env.environment == "QA" ){
                slackSend (
                color: 'good',
                message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} Build-${env.BUILD_NUMBER} Deployment to $environment \n SUCCESS: More info at: ${env.BUILD_URL}" )
               // environmentDashboard(addColumns: false, buildJob: "$JOB_NAME", buildNumber: "$BUILD_ID", componentName: 'Rails', data: [], nameOfEnv: environment, packageName: "$CHANGE_ID-$BUILD_ID") {
               //    echo 'Deployment Successfull'
               // }
           }
           else{
               echo "Environment Not Selected"
           }
           publishHTML(target: [allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'coverage', reportFiles: 'index.html', reportName: 'Rspec Test Results'])
        }
    }
        unstable{
        script{
          if (env.environment == "Dev" || env.environment == "QA" ){
                slackSend (
                color: 'warning',
                message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} Build-${env.BUILD_NUMBER} Deployment to $environment \n UNSTABLE: More info at: ${env.BUILD_URL}" )
           }
           else{
               echo "Environment Not Selected"
           }
              publishHTML(target: [allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'coverage', reportFiles: 'index.html', reportName: 'Rspec Test Results'])
                }
        }
        failure{
        script{
          if (env.environment == "Dev" || env.environment == "QA" ){
                slackSend (
                color: 'danger',
                message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} Build-${env.BUILD_NUMBER} Deployment to $environment \n FAILURE: More info at: ${env.BUILD_URL}" )
           }
           else{
               echo "Environment Not Selected"
           }
              publishHTML(target: [allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'coverage', reportFiles: 'index.html', reportName: 'Rspec Test Results'])
                }
        }
      }
}
