pipeline {
    agent any
tools {nodejs "nodejs"}
    environment {
        // Configuración de la máquina remota
        remoteHost = '192.168.0.31'
        remoteUser = 'lucas'
        privateKey = credentials('key_infra')
        dbname = 'joomla_db'
        dockerImage = 'lucasvazz/app_flask_joomla'
        dockerHubCredentials = credentials('passw-docker-hub')  // El ID de tus credenciales de Docker Hub en Jenkins
    }

    stages {
        stage('Construir imagen Docker') {
            steps {
                script {
                    // Construir imagen Docker con un nombre específico
                    def appImagen = docker.build("${env.dockerImage}", '.')
                }
            }
        }

        stage('SonarQube Scanner') {
            steps {
                script {
                    def scannerHome = tool 'sonarscanner';
                    withSonarQubeEnv("SonarServer") {
                    sh "${tool("sonarscanner")}/bin/sonar-scanner"
                    }
                }
            }
        }
      stage('Construir y ejecutar contenedor Docker') {
            steps {
                sshagent(['key_infra']) {
                    // Establecer túnel SSH a la máquina de producción
                    sh "ssh -L 3307:localhost:3306 -N -f -o StrictHostKeyChecking=no ${remoteUser}@${remoteHost}"
                }
                script {
                    // Ejecutar el contenedor Docker
                    sh "docker run -d -p 5000:5000 --name flask_app  ${env.dockerImage}"
                    // Esperar 10 segundos
                    sh "sleep 10"
                    // Ejecutar test_app.py
                    sh "docker exec flask_app python3 test_app.py"
                }
            }
        }


        stage('Push a Docker Hub y limpiar') {
            steps {
                script {
                    // Hacer login en Docker Hub               
                    docker.withRegistry('https://registry.hub.docker.com', 'passw-docker-hub') {
                        // Hacer push de la imagen a Docker Hub    
                        docker.image("${env.dockerImage}").push()
                    }
                }
            }
        }

stage('Actualizar imagen en minikube') {
    steps {
        sshagent(['key_infra']) {
            script {
                sh """
                    echo 'kubectl config use-context minikube' | ssh -o StrictHostKeyChecking=no ${remoteUser}@${remoteHost}
                    echo 'kubectl set image deployment/lista-de-articulos app-container=${env.dockerImage}' | ssh -o StrictHostKeyChecking=no ${remoteUser}@${remoteHost}
                    echo 'kubectl rollout restart deployment/lista-de-articulos' | ssh -o StrictHostKeyChecking=no ${remoteUser}@${remoteHost}
                """
            }
        }
    }
}
    }

    post {
        always {
            sh 'docker logout'
            // Detener y eliminar el contenedor            
            sh "docker stop flask_app && docker rm flask_app"           
            // Eliminar la imagen
            sh "docker rmi ${env.dockerImage}"            
        }
    }
}
