pipeline {
    options {
        timestamps()
    }
    agent any

    stages {
        stage("Checkout the SCM") {
            steps {
                echo "Starting the checkout"
                deleteDir()
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh 'echo $Version'
                script{
                    try {
                        sh "git checkout release/$Version" 
                    }
                    catch (Exception e) {
                        sh "git remote set-url origin gitlab/piaseckip/cowsay_versioned.git"
                        sh "git checkout main"
                        sh "git checkout -b release/$Version"
                        sh "echo $Version.0 NOT FOR RELEASE > version.txt"
                        sh "git add ."
                        sh "git commit -am 'Initial commit for branch'"
                        sh "git push --set-upstream origin release/$Version"
                    }
                }
            }
        }
        
    }

}