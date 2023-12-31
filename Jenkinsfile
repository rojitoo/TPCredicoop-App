pipeline {
    agent any
    environment {
        // Configuración de la máquina remota
        remoteHost = '192.168.64.128'
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



        stage('Construir y ejecutar contenedor Docker') {
            steps {
                sshagent(['key_infra']) {
                    // Establecer túnel SSH a la máquina de producción
                    sh "ssh -L 3307:localhost:3306 -N -f -o StrictHostKeyChecking=no ${remoteUser}@${remoteHost}"
                }
                script {
                    // Ejecutar el contenedor Docker
                    sh "docker run -d -p 5000:5000 --name flask_app ${env.dockerImage}"
                    sh "sleep 5"
                    sh "docker cp flask_app:/app /var/lib/jenkins/pruebaSonar"
                    sh "sleep 5"
                    // Ejecutar test_app.py
                }
            }
        }

        stage("Testear app en contenedor") {
        steps{
            sh "docker exec flask_app python3 /app/app-python/test_app.py"
        }
        }

                  stage('Análisis SonarQube') {
        steps {
            withCredentials([string(credentialsId: 'sonar_token', variable: 'SONAR_TOKEN')]) {
                sh """
                    docker exec -e SONAR_TOKEN=$SONAR_TOKEN tp-credicoop-sonarqube-1 sonar-scanner \
                        -Dsonar.projectKey=Tp_Credicoop \
                        -Dsonar.sources=/opt/sonarqube/archivos-app \
                        -Dsonar.host.url=http://localhost:9000 \
                        -Dsonar.login=admin \
                        -Dsonar.password=admin123
                """
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
            sh "docker rmi registry.hub.docker.com/lucasvazz/app_flask_joomla"
        }
    }
}
