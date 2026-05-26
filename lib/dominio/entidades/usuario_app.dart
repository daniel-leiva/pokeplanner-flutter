class UsuarioApp {
  const UsuarioApp({
    required this.uid,
    required this.correo,
    required this.correoVerificado,
  });

  final String uid;
  final String? correo;
  final bool correoVerificado;
}
