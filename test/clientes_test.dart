import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Validar datos de registro de cliente', () {

    final clienteNombre = "Jonathan Sanchez";
    final clienteTelefono = "5512345678";


    expect(clienteNombre, isNotEmpty);
    expect(clienteTelefono.length, greaterThanOrEqualTo(10));
  });
}