pipeline {
    environment {
        imagename = "piwi3910/sabnzbd"
        registryCredential = 'docker_reg'
        alpine_dockerImage = ''
        version = ''

    }
    agent {
        kubernetes {
        yamlFile 'buildpod.yaml'
        }
    }
    stages {
        stage('Check Github releases') {
            steps {
                container('ubuntu-base') {
                    script {
                        version = sh (
                            script: '$(curl --silent "https://api.github.com/repos/sabnzbd/sabnzbd/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')',
                            returnStdout: true
                        ).trim()    
                    }
                }
            }    
        }
        stage('Build image based on latest base image with dind') {
            steps {
                container('docker') {
                    script {
                        alpine_dockerImage = docker.build("${env.imagename}:${BUILD_ID}", "${WORKSPACE}" ) 
                    }
                }
            }    
        }
        stage('Push build image to DockerHub') {
            steps {
                container('docker') {
                    script {
                        docker.withRegistry( '', registryCredential ) {
                        alpine_dockerImage.push("${env.version}")
                        alpine_dockerImage.push('latest')
                        }
                    }
                }
            }    
        }  
    }
}

