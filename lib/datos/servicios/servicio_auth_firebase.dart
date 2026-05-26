import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_final_progra3/datos/modelos/modelo_usuario_firebase.dart';
import 'package:proyecto_final_progra3/dominio/entidades/usuario_app.dart';
import 'package:proyecto_final_progra3/dominio/repositorios/repositorio_autenticacion.dart';

class ExcepcionAutenticacion implements Exception {
  const ExcepcionAutenticacion(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

class ServicioAuthFirebase implements RepositorioAutenticacion {
  ServicioAuthFirebase({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  @override
  Future<UsuarioApp> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final UserCredential credencial = await _firebaseAuth
          .signInWithEmailAndPassword(
            email: correo.trim(),
            password: contrasena,
          );

      final UsuarioApp? usuario = ModeloUsuarioFirebase.desdeFirebase(
        credencial.user,
      );

      if (usuario == null) {
        throw const ExcepcionAutenticacion(
          'No se pudo iniciar sesion. Intentalo de nuevo.',
        );
      }

      return usuario;
    } on FirebaseAuthException catch (error) {
      throw ExcepcionAutenticacion(_mapearMensajeError(error));
    }
  }

  @override
  Future<UsuarioApp> registrar({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final UserCredential credencial = await _firebaseAuth
          .createUserWithEmailAndPassword(
            email: correo.trim(),
            password: contrasena,
          );

      final UsuarioApp? usuario = ModeloUsuarioFirebase.desdeFirebase(
        credencial.user,
      );

      if (usuario == null) {
        throw const ExcepcionAutenticacion(
          'No se pudo completar el registro. Intentalo de nuevo.',
        );
      }

      return usuario;
    } on FirebaseAuthException catch (error) {
      throw ExcepcionAutenticacion(_mapearMensajeError(error));
    }
  }

  @override
  Future<void> cerrarSesion() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (error) {
      throw ExcepcionAutenticacion(_mapearMensajeError(error));
    }
  }

  @override
  UsuarioApp? obtenerUsuarioActual() {
    return ModeloUsuarioFirebase.desdeFirebase(_firebaseAuth.currentUser);
  }

  @override
  Stream<UsuarioApp?> observarEstadoAutenticacion() {
    return _firebaseAuth.authStateChanges().map(
      ModeloUsuarioFirebase.desdeFirebase,
    );
  }

  String _mapearMensajeError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'El correo ingresado no es valido.';
      case 'user-disabled':
        return 'Esta cuenta fue deshabilitada.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contrasena incorrectos.';
      case 'email-already-in-use':
        return 'Ese correo ya esta registrado.';
      case 'weak-password':
        return 'La contrasena es demasiado debil.';
      case 'operation-not-allowed':
        return 'El metodo de autenticacion no esta habilitado.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta mas tarde.';
      case 'network-request-failed':
        return 'Sin conexion. Revisa tu internet e intenta de nuevo.';
      default:
        return 'Ocurrio un error de autenticacion. Intentalo de nuevo.';
    }
  }
}
