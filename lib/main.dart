import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:proyecto_final_progra3/aplicacion/aplicacion_principal.dart';
import 'package:proyecto_final_progra3/firebase_options.dart';
import 'package:proyecto_final_progra3/nucleo/configuracion/configuracion_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ConfiguracionApi.validar();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AplicacionPrincipal());
}
