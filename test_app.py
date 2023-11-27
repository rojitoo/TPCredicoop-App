import unittest
from app import app

class TestApp(unittest.TestCase):
    def setUp(self):
        # Configura el cliente de prueba
        self.app = app.test_client()

    def test_lista_articulos_contiene_prueba1_y_prueba2(self):
        # Realiza una solicitud GET a la ruta /lista_articulos
        response = self.app.get('/lista_articulos')

        # Verifica que la respuesta sea exitosa (código 200)
        self.assertEqual(response.status_code, 200)

        # Obtén el contenido HTML de la respuesta
        html_content = response.get_data(as_text=True)

        # Verifica que 'Prueba1' y 'Prueba2' estén en el contenido HTML
        self.assertIn('Prueba 1', html_content)
        self.assertIn('Prueba 2', html_content)

if __name__ == '__main__':
    unittest.main()
