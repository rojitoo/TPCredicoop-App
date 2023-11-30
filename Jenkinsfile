pipeline {
  agent {dockerfile true}
  
  environment {
        // Configuración de la máquina remota
    remoteHost = '192.168.0.31'
    remoteUser = 'lucas'
    privateKey = credentials('key_infra')
    dbname = 'joomla_db'
    }
  
  stages {
        stage('Construir y ejecutar contenedor Docker') {
            steps {
                script {
                    // Establecer túnel SSH a la máquina de producción
                    sh "ssh -i $privateKey ${remoteUser}@${remoteHost} -L 3306:localhost:3306 -N -f -o StrictHostKeyChecking=no"
                    
                }
              docker.image('mi-app').inside {
                        sh "python app.py ${env.DB_URL}"
            }
        }
}
}
