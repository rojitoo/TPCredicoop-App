pipeline {
  agent any
  
  environment {
        // Configuración de la máquina remota
    remoteHost = '192.168.0.31'
    remoteUser = 'lucas'
    privateKey = credentials('key_infra')
    dbname = 'joomla_db'
    }

      stages {
        stage('Construir imagen Docker') {
            steps {
                script {
                    // Construir imagen Docker con un nombre específico
                    appImagen = docker.build('app-imagen', '.')
                }
            }
        }
  
  stages {
        stage('Construir y ejecutar contenedor Docker') {
            steps {
                script {
                    // Establecer túnel SSH a la máquina de producción
                    sh "ssh -i $privateKey ${remoteUser}@${remoteHost} -L 3306:localhost:3306 -N -f -o StrictHostKeyChecking=no"
                    
                }
              docker.image('app-imagen').inside {
                        sh "python app.py ${env.DB_URL}"
            }
        }
}
  }
}
}
