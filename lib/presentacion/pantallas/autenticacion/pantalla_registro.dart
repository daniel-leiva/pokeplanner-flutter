import 'package:flutter/material.dart';
import 'package:proyecto_final_progra3/datos/servicios/servicio_auth_firebase.dart';
import 'package:proyecto_final_progra3/dominio/repositorios/repositorio_autenticacion.dart';
import 'package:proyecto_final_progra3/nucleo/tema/colores_app.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({
    super.key,
    required this.repositorioAutenticacion,
    required this.onIrALogin,
  });

  final RepositorioAutenticacion repositorioAutenticacion;
  final VoidCallback onIrALogin;

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
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

  Future<void> _registrar() async {
    final FormState? estadoFormulario = _formKey.currentState;
    if (estadoFormulario == null || !estadoFormulario.validate()) {
      return;
    }

    setState(() {
      _cargando = true;
    });

    try {
      await widget.repositorioAutenticacion.registrar(
        correo: _controladorCorreo.text.trim(),
        contrasena: _controladorContrasena.text,
      );

      _mostrarMensaje('Registro exitoso. Bienvenido a PokePlanner.');
    } on ExcepcionAutenticacion catch (error) {
      _mostrarMensaje(error.mensaje, esError: true);
    } catch (_) {
      _mostrarMensaje(
        'No se pudo completar el registro. Intentalo de nuevo.',
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
    final String contrasena = valor ?? '';
    if (contrasena.isEmpty) {
      return 'Ingresa una contrasena.';
    }
    if (contrasena.length < 6) {
      return 'La contrasena debe tener al menos 6 caracteres.';
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
                              color: ColoresApp.primario.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person_add_alt_1_rounded,
                                  size: 18,
                                  color: ColoresApp.primario,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Nuevo entrenador',
                                  style: TextStyle(
                                    color: ColoresApp.primario,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Crear cuenta',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Registra tu correo para guardar tu avance en PokéPlanner.',
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
                              'Registro',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _controladorCorreo,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.newUsername],
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
                              autofillHints: const [AutofillHints.newPassword],
                              textInputAction: TextInputAction.done,
                              decoration: const InputDecoration(
                                labelText: 'Contrasena',
                                hintText: 'Minimo 6 caracteres',
                                prefixIcon: Icon(Icons.lock_outline_rounded),
                              ),
                              onFieldSubmitted: (_) => _registrar(),
                              validator: _validarContrasena,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _cargando ? null : _registrar,
                              icon: _cargando
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.how_to_reg_rounded),
                              label: Text(
                                _cargando ? 'Registrando...' : 'Crear cuenta',
                              ),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: _cargando ? null : widget.onIrALogin,
                              icon: const Icon(Icons.arrow_back_rounded),
                              label: const Text('Volver a iniciar sesion'),
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
