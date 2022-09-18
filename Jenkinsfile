pipeline {
    options {
        timestamps()
    }
    agent any

    environment {
        STATUS = "Initial STATUS env value"
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
                echo "Checkout complete!"
                updateGitlabCommitStatus name: 'Checkout', state: 'success'
            }
        }

        stage('Build') {
            steps {
                sh "echo ${Version}"
            }
        }
        
    }

}