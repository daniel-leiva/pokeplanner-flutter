import 'package:proyecto_final_progra3/dominio/entidades/usuario_app.dart';

abstract class RepositorioAutenticacion {
  Future<UsuarioApp> iniciarSesion({
    required String correo,
    required String contrasena,
  });

  Future<UsuarioApp> registrar({
    required String correo,
    required String contrasena,
  });

  Future<void> cerrarSesion();

  UsuarioApp? obtenerUsuarioActual();

  Stream<UsuarioApp?> observarEstadoAutenticacion();
}
