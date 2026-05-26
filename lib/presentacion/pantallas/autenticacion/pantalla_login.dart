import 'package:flutter/material.dart';
import 'package:proyecto_final_progra3/datos/servicios/servicio_auth_firebase.dart';
import 'package:proyecto_final_progra3/dominio/repositorios/repositorio_autenticacion.dart';
import 'package:proyecto_final_progra3/nucleo/tema/colores_app.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({
    super.key,
    required this.repositorioAutenticacion,
    required this.onIrARegistro,
  });

  final RepositorioAutenticacion repositorioAutenticacion;
  final VoidCallback onIrARegistro;

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _controladorCorreo = TextEditingController();
  final TextEditingController _controladorContrasena = TextEditingController();

  bool _cargando = false;

  @override
  void dispose() {
    _controladorCorreo.dispose();
    _controladorContrasena.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    final FormState? estadoFormulario = _formKey.currentState;
    if (estadoFormulario == null || !estadoFormulario.validate()) {
      return;
    }

    setState(() {
      _cargando = true;
    });

    try {
      await widget.repositorioAutenticacion.iniciarSesion(
        correo: _controladorCorreo.text.trim(),
        contrasena: _controladorContrasena.text,
      );
    } on ExcepcionAutenticacion catch (error) {
      _mostrarMensaje(error.mensaje, esError: true);
    } catch (_) {
      _mostrarMensaje(
        'Ocurrio un error al iniciar sesion. Intentalo de nuevo.',
        esError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  void _mostrarMensaje(String mensaje, {bool esError = false}) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  String? _validarCorreo(String? valor) {
    final String correo = (valor ?? '').trim();
    if (correo.isEmpty) {
      return 'Ingresa tu correo.';
    }
    if (!correo.contains('@') || !correo.contains('.')) {
      return 'Ingresa un correo valido.';
    }
    return null;
  }

  String? _validarContrasena(String? valor) {
    if ((valor ?? '').isEmpty) {
      return 'Ingresa tu contrasena.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: ColoresApp.secundario.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.login_rounded,
                                  size: 18,
                                  color: ColoresApp.secundario,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Acceso a tu espacio',
                                  style: TextStyle(
                                    color: ColoresApp.secundario,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'PokePlanner',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(fontSize: 28),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Inicia sesion para organizar y analizar tus Pokemon.',
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Iniciar sesion',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _controladorCorreo,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Correo',
                                hintText: 'ejemplo@correo.com',
                                prefixIcon: Icon(Icons.mail_outline_rounded),
                              ),
                              validator: _validarCorreo,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _controladorContrasena,
                              obscureText: true,
                              autofillHints: const [AutofillHints.password],
                              textInputAction: TextInputAction.done,
                              decoration: const InputDecoration(
                                labelText: 'Contrasena',
                                hintText: 'Ingresa tu contrasena',
                                prefixIcon: Icon(Icons.lock_outline_rounded),
                              ),
                              onFieldSubmitted: (_) => _iniciarSesion(),
                              validator: _validarContrasena,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _cargando ? null : _iniciarSesion,
                              icon: _cargando
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.login_rounded),
                              label: Text(
                                _cargando ? 'Ingresando...' : 'Iniciar sesion',
                              ),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: _cargando
                                  ? null
                                  : widget.onIrARegistro,
                              icon: const Icon(Icons.person_add_alt_1_rounded),
                              label: const Text('Crear cuenta'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
