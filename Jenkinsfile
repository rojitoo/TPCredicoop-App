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

        stage('Construir y ejecutar contenedor Docker') {
            steps {
                 sshagent(['key_infra']) {
                    // Establecer túnel SSH a la máquina de producción
                    sh "ssh -L 3306:localhost:3306 -N -f -o StrictHostKeyChecking=no ${remoteUser}@${remoteHost}"
                 }
                script {
                    appImagen.inside {
                    sh "python app.py ${env.DB_URL}"
                }
                }
            }
        }
    }
}
