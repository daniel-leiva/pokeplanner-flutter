import 'package:flutter/material.dart';
import 'package:proyecto_final_progra3/datos/servicios/servicio_auth_firebase.dart';
import 'package:proyecto_final_progra3/dominio/entidades/usuario_app.dart';
import 'package:proyecto_final_progra3/presentacion/pantallas/autenticacion/pantalla_login.dart';
import 'package:proyecto_final_progra3/presentacion/pantallas/autenticacion/pantalla_registro.dart';
import 'package:proyecto_final_progra3/presentacion/pantallas/pantalla_inicio.dart';

class PantallaControlAutenticacion extends StatefulWidget {
  const PantallaControlAutenticacion({super.key});

  @override
  State<PantallaControlAutenticacion> createState() =>
      _PantallaControlAutenticacionState();
}

class _PantallaControlAutenticacionState
    extends State<PantallaControlAutenticacion> {
  final ServicioAuthFirebase _servicioAuth = ServicioAuthFirebase();
  bool _mostrarRegistro = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UsuarioApp?>(
      stream: _servicioAuth.observarEstadoAutenticacion(),
      builder: (BuildContext context, AsyncSnapshot<UsuarioApp?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const PantallaInicio();
        }

        if (_mostrarRegistro) {
          return PantallaRegistro(
            repositorioAutenticacion: _servicioAuth,
            onIrALogin: () {
              setState(() {
                _mostrarRegistro = false;
              });
            },
          );
        }

        return PantallaLogin(
          repositorioAutenticacion: _servicioAuth,
          onIrARegistro: () {
            setState(() {
              _mostrarRegistro = true;
            });
          },
        );
      },
    );
  }
}
