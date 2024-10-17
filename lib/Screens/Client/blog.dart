import 'package:flutter/material.dart';

class BlogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blog Nutricional'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido a tu Blog Nutricional',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'En este espacio encontrarás artículos sobre la importancia de una buena alimentación y consejos prácticos para mantener una dieta equilibrada.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 30),
            _buildBlogPost(
              title: 'La importancia de los macronutrientes',
              content:
                  'Los macronutrientes (proteínas, carbohidratos y grasas) son esenciales para el funcionamiento del cuerpo. Las proteínas ayudan en la reparación muscular, los carbohidratos proporcionan energía y las grasas saludables son vitales para el funcionamiento del cerebro.',
            ),
            SizedBox(height: 20),
            _buildBlogPost(
              title: 'Los micronutrientes y su papel en la salud',
              content:
                  'Vitaminas y minerales como el hierro, el calcio y las vitaminas A, C y D, juegan un papel fundamental en nuestro bienestar. Ayudan al sistema inmunológico, fortalecen los huesos y mejoran la salud cardiovascular.',
            ),
            SizedBox(height: 20),
            _buildBlogPost(
              title: 'El equilibrio entre calorías y actividad física',
              content:
                  'Para mantener un peso saludable, es importante equilibrar las calorías consumidas con las calorías gastadas. Una alimentación balanceada combinada con actividad física regular es clave para una buena salud.',
            ),
            SizedBox(height: 20),
            _buildBlogPost(
              title: 'Consejos para una hidratación adecuada',
              content:
                  'El agua es esencial para todas las funciones corporales. Se recomienda consumir al menos 2 litros de agua al día para mantenerse bien hidratado, especialmente en climas cálidos o durante el ejercicio físico.',
            ),
            SizedBox(height: 20),
            _buildBlogPost(
              title: 'Mitos comunes sobre la alimentación',
              content:
                  'Existen muchos mitos sobre la alimentación, como la idea de que "todos los carbohidratos son malos" o que "las grasas siempre te hacen engordar". La clave es el equilibrio y la calidad de los alimentos que consumimos.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlogPost({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          content,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 15),
        Divider(),
      ],
    );
  }
}
