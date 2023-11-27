from flask import Flask, render_template
import pymysql

app = Flask(__name__, template_folder='template')

# Configuración de la base de datos
db_config = {
    'host': 'joomladb',  # Cambia esto según tu configuración
    'user': 'root',
    'password': 'admin123',
    'database': 'joomla_db',
    'charset': 'utf8mb4',
    'cursorclass': pymysql.cursors.DictCursor,
}

# Ruta para mostrar la lista de artículos
@app.route('/lista_articulos')
def mostrar_articulos():
    # Conectar a la base de datos
    connection = pymysql.connect(**db_config)

    try:
        with connection.cursor() as cursor:
            # Consulta para obtener la cantidad de artículos y sus nombres
            sql = "SELECT COUNT(id) as total_articulos, GROUP_CONCAT(title) as nombres_articulos FROM e62pu_content"
            cursor.execute(sql)
            resultado = cursor.fetchone()

            # Renderizar la plantilla con la información
            return render_template('articulos.html', total_articulos=resultado['total_articulos'], nombres_articulos=resultado['nombres_articulos'])
    finally:
        connection.close()

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
