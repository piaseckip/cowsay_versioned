pipeline {
    options {
        timestamps()
    }
    agent any

    environment {
        STATUS = "Initial STATUS env value"
        BRANCH_NAME = "${GIT_BRANCH.split("/")[1]}"
        VER = 'True'
    }

  

    stages {
        stage("Checkout the SCM") {
            steps {
                updateGitlabCommitStatus name: 'Checkout', state: 'pending'
                script {
                    STATUS = "Checkout"
                }
                echo "Starting the checkout"
                echo " "
                deleteDir()
                checkout scm
                echo " "
                sh 'echo "$(cat version.txt)"'
                script{
                        if ("$Version" != ""){
                            try {
                                echo "lolek"
                                sh "git checkout release/$Version"
                                sh 'echo "$Version.$(($(tail -1 version.txt | cut -d "." -f3 | cut -d " " -f1) + 1)) NOT FOR RELEASE" > version.txt'
                            }
                            catch (Exception e) {
                                sh "git checkout main"
                                sh "git checkout -b release/$Version"
                                sh "echo $Version.0 NOT FOR RELEASE > version.txt"
                            }
                            sh "git add ."
                            sh 'git commit -am "$(tail version.txt)"'

                            withCredentials([string(credentialsId: 'api_token', variable: 'TOKEN')]) { 
                                sh "git push http://jenkins:$TOKEN@35.178.81.143/piaseckip/cowsay_versioned"
                            }
                        }
                        else{
                            script{
                                LOG = sh(returnStdout: true, script: 'git log --all --graph --oneline --decorate | head -1').trim()
                                echo "tutaj"
                                echo "${LOG}"
                                if ( "${LOG}".contains('main')) {
                                    echo "lama"
                                    VER = 'FALSE'
                                }
                                else {
                                    echo "nie tu"
                                    BRANCH = sh(returnStdout: true, script: 'git log --all --graph --oneline --decorate | head -1 | cut -d "/" -f3 | cut -d ")" -f1').trim()
                                    echo "${BRANCH}"
                                    sh "git checkout release/'${BRANCH}'"
                                    CURRENT_BRANCH = sh(returnStdout: true, script: 'git rev-parse --abbrev-ref HEAD').trim()
                                    echo "${CURRENT_BRANCH}"
                                    sh "cat version.txt"
                                    echo "${BRANCH}"
                                    sh "echo -n '${BRANCH}' > version.txt"
                                    sh "echo -n '.' >> version.txt"
                                    sh 'echo -n "$(($(tail -1 version.txt | cut -d "." -f3 | cut -d " " -f1) + 1)) NOT FOR RELEASE" >> version.txt'
                                    sh "cat version.txt"
                                    // echo "'${BRANCH}'.$(($(tail -1 version.txt | cut -d "." -f3 | cut -d " " -f1) + 1)) NOT FOR RELEASE > version.txt"
                                    //sh 'echo "'${BRANCH}'.$(($(tail -1 version.txt | cut -d "." -f3 | cut -d " " -f1) + 1)) NOT FOR RELEASE" > version.txt'
                                    sh ""
                                    sh "git add ."
                                    sh 'git commit -am "$(tail version.txt)"'
                                    withCredentials([string(credentialsId: 'api_token', variable: 'TOKEN')]) { 
                                        sh "git push http://jenkins:$TOKEN@35.178.81.143/piaseckip/cowsay_versioned"
                                    }
                                    Version = "${BRANCH}"

                                }
                            }   
                        }
                    
                }
                    
                    echo "Checkout complete!"
                    updateGitlabCommitStatus name: 'Checkout', state: 'success'
            }
        }
    
        stage('Build') {
            steps {
                updateGitlabCommitStatus name: 'Build', state: 'pending'
                script {
                    STATUS = "Build"
                }
                echo "Starting the build"
                echo " "
                
                echo 'Building..'
                sleep 5 
                sh "docker build --build-arg PORT=8081 -t cow ."
                echo " "
                updateGitlabCommitStatus name: 'Build', state: 'success'
            }
        }


        stage('Test') {
            when{
                expression { "${VER}" == "True"}
            }
            steps {
                updateGitlabCommitStatus name: 'Test', state: 'pending'
                script {
                    STATUS = "Test"
                }
                echo "Starting the local test"
                echo " "
                sh "docker rm -f house_cow"
                sh "docker run -d -p 4001:8081 --name house_cow cow"
                sleep 10
                sh "curl -i http://35.178.81.143:4001 | grep 200"
                updateGitlabCommitStatus name: 'Test', state: 'success'
            }
        }  

        stage('Git deploy') {
            when{
                expression { "${VER}" == "True"}
            }
            steps {
                updateGitlabCommitStatus name: 'Git deploy', state: 'pending'
                script {
                    STATUS = "Git deploy"
                    sh "git log --all --graph --oneline --decorate | head -1"
                    
                    BRANCH = sh(returnStdout: true, script: 'git log --all --graph --oneline --decorate | head -1 | cut -d ")" -f2 | cut -d " " -f2').trim()
                    echo "${BRANCH}"
                    Version = "${BRANCH}"
                    echo "$Version"

                sh "echo -n '${Version}' > version.txt"
                sh "echo -n '.' >> version.txt"
                sh 'echo -n "$(($(tail -1 version.txt | cut -d "." -f3 | cut -d " " -f1))) FOR RELEASE" >> version.txt'

                //sh "echo '$Version.$(($(tail -1 version.txt | cut -d "." -f3 | cut -d " " -f1))) FOR RELEASE' > version.txt"
                sh "git add ."
                sh 'git commit -am "$(tail version.txt)"'
                sh "git tag $Version.$(($(tail -1 version.txt | cut -d "." -f3 | cut -d " " -f1)))"

                withCredentials([string(credentialsId: 'api_token', variable: 'TOKEN')]) { 
                    sh 'git push http://jenkins:$TOKEN@35.178.81.143/piaseckip/cowsay_versioned'
                    sh "git push http://jenkins:$TOKEN@35.178.81.143/piaseckip/cowsay_versioned $Version.$(($(tail -1 version.txt | cut -d "." -f3 | cut -d " " -f1)))"
                }
                }
                updateGitlabCommitStatus name: 'Git deploy', state: 'success'
            }
        }

        stage('Ecr deploy') {
            when{
                expression { "${VER}" == "True"}
            }
            steps {
                updateGitlabCommitStatus name: 'Ecr deploy', state: 'pending'
                script {
                    STATUS = "Ecr deploy"
                }
                echo 'Preparing to push to ECR'
                echo " "
                sh "aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 644435390668.dkr.ecr.eu-west-2.amazonaws.com"
                sh 'docker tag cow:latest 644435390668.dkr.ecr.eu-west-2.amazonaws.com/piotrekcowsay:$Version.$(($(tail -1 version.txt | cut -d "." -f3 | cut -d " " -f1)))'
                sh 'docker push 644435390668.dkr.ecr.eu-west-2.amazonaws.com/piotrekcowsay:$Version.$(($(tail -1 version.txt | cut -d "." -f3 | cut -d " " -f1)))'
                echo " "
                echo " Pushing to ECR success"
                updateGitlabCommitStatus name: 'Ecr deploy', state: 'success'
            }
        }
               
            
        
        stage ("Deploy to prod") {
            when{
                expression { "${VER}" == "True"}
            }
            steps {
                updateGitlabCommitStatus name: 'Deploy to prod', state: 'pending'
                echo 'Preparing to deploy Cowsay on EC2'
                echo " "
                sh 'ssh -i /home/jenkins/Piotrek_pair.pem ubuntu@ec2-3-9-175-50.eu-west-2.compute.amazonaws.com "aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 644435390668.dkr.ecr.eu-west-2.amazonaws.com"'
                sh 'ssh -i /home/jenkins/Piotrek_pair.pem ubuntu@ec2-3-9-175-50.eu-west-2.compute.amazonaws.com "docker rm -f krowa"'
                sh 'ssh -i /home/jenkins/Piotrek_pair.pem ubuntu@ec2-3-9-175-50.eu-west-2.compute.amazonaws.com "docker pull 644435390668.dkr.ecr.eu-west-2.amazonaws.com/piotrekcowsay:$Version.$(($(tail -1 version.txt | cut -d "." -f3 | cut -d " " -f1)))"'
                sh 'ssh -i /home/jenkins/Piotrek_pair.pem ubuntu@ec2-3-9-175-50.eu-west-2.compute.amazonaws.com "docker run --name krowa -d -p 80:8081 644435390668.dkr.ecr.eu-west-2.amazonaws.com/piotrekcowsay:latest"'
                echo " "
                echo "Deploy complete!"
                updateGitlabCommitStatus name: 'Deploy to prod', state: 'success'
            }
        }
        

    }

    post {
        failure {
            script {
            updateGitlabCommitStatus name: "${STATUS}" , state: 'failed'
            }
        }
        
        always {
        emailext recipientProviders: [culprits()],
                 subject: '$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS!', body: '$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS',
                 attachLog: true
        }
    }
}
