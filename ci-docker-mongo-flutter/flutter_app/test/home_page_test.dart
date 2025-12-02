import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:app/main.dart';

void main() {
  tearDown(() {
    // deja el cliente en un estado limpio después de cada test
    httpClient = http.Client();
  });

  group('HomePage', () {
    testWidgets('muestra "Cargando..." y luego el mensaje del backend',
        (WidgetTester tester) async {
      httpClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/message');

        return http.Response(
          json.encode({'message': 'Hola desde test'}),
          200,
        );
      });

      await tester.pumpWidget(const MyApp());

      // Estado inicial
      expect(find.text('Cargando...'), findsOneWidget);

      // Deja que complete el Future + setState
      await tester.pumpAndSettle();

      expect(find.text('Hola desde test'), findsOneWidget);
    });

    testWidgets('muestra mensaje de error cuando el backend responde 500',
        (WidgetTester tester) async {
      httpClient = MockClient((request) async {
        return http.Response('Error interno', 500);
      });

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(
        find.text('Error al consultar el backend (500)'),
        findsOneWidget,
      );
    });

    testWidgets('guardar mensaje hace POST y refresca el mensaje',
        (WidgetTester tester) async {
      var getCount = 0;

      httpClient = MockClient((request) async {
        if (request.method == 'GET' && request.url.path == '/api/message') {
          getCount++;
          return http.Response(
            json.encode({'message': 'Mensaje $getCount'}),
            200,
          );
        }

        if (request.method == 'POST' && request.url.path == '/api/message') {
          final body = json.decode(request.body) as Map<String, dynamic>;
          expect(body['text'], 'Nuevo mensaje desde test');

          // simulamos guardado OK
          return http.Response('{}', 200);
        }

        return http.Response('Not found', 404);
      });

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Mensaje inicial proveniente del GET
      expect(find.text('Mensaje 1'), findsOneWidget);

      // Escribimos en el TextField
      await tester.enterText(
        find.byType(TextField),
        'Nuevo mensaje desde test',
      );

      // Tap en "Guardar en MongoDB"
      await tester.tap(find.text('Guardar en MongoDB'));
      await tester.pumpAndSettle();

      // Debe haberse disparado un nuevo GET y mostrar el nuevo mensaje
      expect(find.text('Mensaje 2'), findsOneWidget);

      // El TextField debe estar vacío
      final textField =
          tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, isEmpty);
    });

    testWidgets('botón "Refrescar" vuelve a llamar a _fetchMessage',
        (WidgetTester tester) async {
      var getCount = 0;

      httpClient = MockClient((request) async {
        if (request.method == 'GET' && request.url.path == '/api/message') {
          getCount++;
          return http.Response(
            json.encode({'message': 'Mensaje $getCount'}),
            200,
          );
        }
        return http.Response('{}', 200);
      });

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.text('Mensaje 1'), findsOneWidget);
      expect(getCount, 1);

      // Tap en "Refrescar"
      await tester.tap(find.text('Refrescar'));
      await tester.pumpAndSettle();

      expect(find.text('Mensaje 2'), findsOneWidget);
      expect(getCount, 2);
    });
  });
}
