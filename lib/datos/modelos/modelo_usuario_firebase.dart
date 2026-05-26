import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_final_progra3/dominio/entidades/usuario_app.dart';

class ModeloUsuarioFirebase {
  const ModeloUsuarioFirebase._();

  static UsuarioApp? desdeFirebase(User? usuario) {
    if (usuario == null) {
      return null;
    }

    return UsuarioApp(
      uid: usuario.uid,
      correo: usuario.email?.trim(),
      correoVerificado: usuario.emailVerified,
    );
  }
}
