import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const String baseUrl = 'https://web-production-b4b0c8.up.railway.app';

final FlutterLocalNotificationsPlugin notificacionesPlugin = FlutterLocalNotificationsPlugin();

void inicializarNotificaciones() async {
  const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings = InitializationSettings(android: androidInit);
  await notificacionesPlugin.initialize(initSettings);
}

void mostrarNotificacion(String titulo, String mensaje) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'canal_restaurante_id',
    'Notificaciones Restaurante',
    importance: Importance.max,
    priority: Priority.high,
  );
  const NotificationDetails generalDetails = NotificationDetails(android: androidDetails);
  await notificacionesPlugin.show(0, titulo, mensaje, generalDetails);
}

// Variables globales
List<Map<String, dynamic>> carritoGlobal = [];
int? usuarioIdLogueado;
String? rolUsuarioLogueado;
String? nombreUsuarioLogueado;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  inicializarNotificaciones();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'UMAMI Restaurante',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFD35400),
        primary: const Color(0xFFE65100),
        secondary: const Color(0xFFFFB74D),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFFAF9F6),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 3,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    ),
    initialRoute: '/login',
    routes: {
      '/login': (context) => LoginScreen(),
      '/': (context) => RegistroPlatillo(),
      '/lista': (context) => ListaPlatillos(),
      '/calculos': (context) => CamposCalculados(),
      '/operaciones': (context) => ListaOperaciones(),
      '/reportes': (context) => ReportesRestaurante(),
      '/graficas': (context) => GraficasRestaurante(),
      '/panel': (context) => PanelAdministrativo(),
      '/carrito': (context) => CarritoCompras(carrito: carritoGlobal),
      '/historial': (context) => HistorialOrdenes(),
      '/ordenes_mesero': (context) => OrdenesMeseroScreen(),
      '/ordenes_cliente': (context) => OrdenesClienteScreen(),
      '/reportes_mesero': (context) => ReportesMesero(),
      '/reportes_cliente': (context) => ReportesCliente(),
      '/admin_reporte_meseros': (context) => AdminReporteMeseros(),
      '/admin_reporte_clientes': (context) => AdminReporteClientes(),
      '/estadisticas_meseros': (context) => EstadisticasMeserosScreen(),
      '/estadisticas_clientes': (context) => EstadisticasClientesScreen(),
      '/exportar': (context) => ExportarReportesScreen(),
    },
  ));
}

// ==========================================
// PANTALLA DE LOGIN (ESTILO PROFESIONAL Y GLASSMORPHISM)
// ==========================================
class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final usuarioController = TextEditingController();
  final claveController = TextEditingController();
  bool _ocultarClave = true;
  bool _cargando = false;

  void login() async {
    setState(() => _cargando = true);
    try {
      final url = Uri.parse("$baseUrl/login");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "usuario": usuarioController.text,
          "clave": claveController.text,
        }),
      );

      final data = jsonDecode(response.body);
      if (data["status"] == "ok") {
        usuarioIdLogueado = data["id"];
        rolUsuarioLogueado = data["rol"];
        nombreUsuarioLogueado = data["usuario"];

        mostrarNotificacion("Bienvenido", "Sesión iniciada como $nombreUsuarioLogueado ($rolUsuarioLogueado)");

        if (rolUsuarioLogueado == "Administrador") {
          Navigator.pushReplacementNamed(context, '/panel');
        } else if (rolUsuarioLogueado == "Mesero") {
          Navigator.pushReplacementNamed(context, '/ordenes_mesero');
        } else if (rolUsuarioLogueado == "Cliente") {
          Navigator.pushReplacementNamed(context, '/lista');
        }
      } else {
        _mostrarSnackBar(data["mensaje"] ?? "Error de inicio de sesión");
      }
    } catch (e) {
      _mostrarSnackBar("Error al conectar con el servidor");
    } finally {
      setState(() => _cargando = false);
    }
  }

  void _mostrarSnackBar(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void saltarLogin() {
    // Permitir ver la app en modo visitante / cliente por defecto
    usuarioIdLogueado = null;
    rolUsuarioLogueado = "Invitado";
    nombreUsuarioLogueado = "Invitado";
    Navigator.pushReplacementNamed(context, '/lista');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo full pantalla (fondoR.png)
          Positioned.fill(
            child: Image.asset(
              'assets/icon/fondoR.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF1E1E1E),
              ),
            ),
          ),
          // Capa oscura translúcida
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.45),
            ),
          ),
          // Formulario Glassmorphic
          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Logo UMAMI transparente
                  Image.asset(
                    'assets/icon/UMAMI_Logo_transparente.png',
                    height: 110,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.restaurant,
                      size: 80,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "GESTIÓN DE RESTAURANTES",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Tarjeta con efecto Glassmorphism
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24.0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                      child: Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(24.0),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Campo Usuario
                            TextField(
                              controller: usuarioController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person_outline, color: Colors.white70),
                                labelText: "Usuario",
                                labelStyle: const TextStyle(color: Colors.white70),
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.2),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: Colors.amber),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Campo Contraseña
                            TextField(
                              controller: claveController,
                              obscureText: _ocultarClave,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _ocultarClave ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    setState(() => _ocultarClave = !_ocultarClave);
                                  },
                                ),
                                labelText: "Contraseña",
                                labelStyle: const TextStyle(color: Colors.white70),
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.2),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: Colors.amber),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Botón de Inicio de Sesión
                            Container(
                              height: 52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFE65100), Color(0xFFF57C00)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _cargando ? null : login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _cargando
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(
                                        "Iniciar Sesión",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Opción para saltar login
                            TextButton(
                              onPressed: saltarLogin,
                              child: const Text(
                                "Explorar Menú sin Iniciar Sesión →",
                                style: TextStyle(
                                  color: Colors.amberAccent,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Powered by Flutter",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// REGISTRO Y EDICIÓN DE PLATILLOS (DISEÑO MEJORADO)
// ==========================================
class RegistroPlatillo extends StatefulWidget {
  final String? id;
  final String? nombre;
  final String? precio;
  final String? categoria;

  RegistroPlatillo({this.id, this.nombre, this.precio, this.categoria});

  @override
  RegistroPlatilloState createState() => RegistroPlatilloState();
}

class RegistroPlatilloState extends State<RegistroPlatillo> {
  final _formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final precioController = TextEditingController();

  final List<String> categoriasDisponibles = ["Postres", "Platos Fuertes", "Bebidas"];
  String? categoriaSeleccionada = "Platos Fuertes";
  File? imagen;

  Future<void> seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagen = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      nombreController.text = widget.nombre ?? "";
      precioController.text = widget.precio ?? "";
      if (widget.categoria != null && categoriasDisponibles.contains(widget.categoria)) {
        categoriaSeleccionada = widget.categoria;
      }
    }
  }

  Future<void> registrarPlatillo() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse("$baseUrl/platillos");
      var request = http.MultipartRequest("POST", url);
      request.fields["nombre"] = nombreController.text;
      request.fields["precio"] = precioController.text;
      request.fields["categoria"] = categoriaSeleccionada ?? "Platos Fuertes";

      if (imagen != null) {
        request.files.add(await http.MultipartFile.fromPath("imagen", imagen!.path));
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        mostrarNotificacion("Nuevo Platillo", "Se ha registrado '${nombreController.text}' en el menú.");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Respuesta servidor: ${response.statusCode}")),
      );
    }
  }

  Future<void> actualizarPlatillo() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse("$baseUrl/platillos/${widget.id}");
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nombre": nombreController.text,
          "precio": double.tryParse(precioController.text) ?? 0,
          "categoria": categoriaSeleccionada,
        }),
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Actualizado correctamente")));
      Navigator.pushReplacementNamed(context, '/lista');
    }
  }

  Future<void> eliminarPlatillo() async {
    final url = Uri.parse("$baseUrl/platillos/${widget.id}");
    await http.delete(url);
    mostrarNotificacion("Platillo Removido", "El platillo ha sido borrado.");
    Navigator.pushReplacementNamed(context, '/lista');
  }

  Widget _crearBotonAccion(String texto, IconData icono, Color color, VoidCallback accion) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      ),
      onPressed: accion,
      icon: Icon(icono, size: 18),
      label: Text(texto, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.id != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? "Editar Platillo" : "Gestión de Platillos"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        esEdicion ? "Modificar Datos" : "Registrar Nuevo Platillo",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD35400)),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nombreController,
                        decoration: InputDecoration(
                          labelText: "Nombre del platillo",
                          prefixIcon: const Icon(Icons.restaurant_menu),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "El nombre es obligatorio";
                          if (value.length < 3) return "Mínimo 3 caracteres";
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: precioController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Precio (\$)",
                          prefixIcon: const Icon(Icons.attach_money),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "El precio es obligatorio";
                          final precio = double.tryParse(value);
                          if (precio == null || precio <= 0) return "Precio inválido";
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: categoriaSeleccionada,
                        decoration: InputDecoration(
                          labelText: "Categoría",
                          prefixIcon: const Icon(Icons.category),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: categoriasDisponibles.map((cat) {
                          return DropdownMenuItem<String>(
                            value: cat,
                            child: Text(cat),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => categoriaSeleccionada = val),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Column(
                          children: [
                            imagen == null
                                ? Container(
                                    height: 100,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.image, size: 50, color: Colors.grey),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(imagen!, height: 120, width: double.infinity, fit: BoxFit.cover),
                                  ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: seleccionarImagen,
                              icon: const Icon(Icons.photo_library),
                              label: const Text("Seleccionar Imagen"),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!esEdicion)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE65100)),
                            onPressed: registrarPlatillo,
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: const Text("Guardar Platillo", style: TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      if (esEdicion) ...[
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                onPressed: actualizarPlatillo,
                                icon: const Icon(Icons.update, color: Colors.white),
                                label: const Text("Actualizar", style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: eliminarPlatillo,
                                icon: const Icon(Icons.delete, color: Colors.white),
                                label: const Text("Eliminar", style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ]
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (!esEdicion) ...[
                const Text("Navegación Rápida", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2.8,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _crearBotonAccion("Ver Menú", Icons.restaurant, Colors.teal, () => Navigator.pushNamed(context, '/lista')),
                    _crearBotonAccion("Calcular Cuenta", Icons.calculate, Colors.indigo, () => Navigator.pushNamed(context, '/calculos')),
                    _crearBotonAccion("Operaciones", Icons.receipt_long, Colors.brown, () => Navigator.pushNamed(context, '/operaciones')),
                    _crearBotonAccion("Ver Gráficas", Icons.bar_chart, Colors.deepOrange, () => Navigator.pushNamed(context, '/graficas')),
                    _crearBotonAccion("Ver Reportes", Icons.analytics, Colors.purple, () => Navigator.pushNamed(context, '/reportes')),
                    _crearBotonAccion("Historial Órdenes", Icons.history, Colors.blueGrey, () => Navigator.pushNamed(context, '/historial')),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// LISTA DE PLATILLOS (CARD DESIGN MODERNO)
// ==========================================
class ListaPlatillos extends StatefulWidget {
  @override
  ListaPlatillosState createState() => ListaPlatillosState();
}

class ListaPlatillosState extends State<ListaPlatillos> {
  Future<List> obtenerPlatillos() async {
    final url = Uri.parse("$baseUrl/platillos");
    final response = await http.get(url);
    return jsonDecode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menú Umami"),
        actions: [
          if (rolUsuarioLogueado == "Cliente")
            IconButton(
              icon: const Icon(Icons.receipt),
              onPressed: () => Navigator.pushNamed(context, '/ordenes_cliente'),
            ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, '/carrito'),
          )
        ],
      ),
      body: FutureBuilder<List>(
        future: obtenerPlatillos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error al conectar con el backend"));
          } else {
            final platillos = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: platillos.length,
              itemBuilder: (context, index) {
                final p = platillos[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: p["imagen"] != null && p["imagen"].toString().isNotEmpty
                            ? Image.network(
                                "$baseUrl/uploads/${p["imagen"]}",
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(color: Colors.orange.shade100, width: 60, height: 60, child: const Icon(Icons.fastfood, color: Colors.orange)),
                              )
                            : Container(color: Colors.orange.shade100, width: 60, height: 60, child: const Icon(Icons.fastfood, color: Colors.orange)),
                      ),
                      title: Text(
                        "${p["nombre"]}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text("Categoría: ${p["categoria"] ?? "Sin categoría"}"),
                          Text("\$${p["precio"]}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                      trailing: rolUsuarioLogueado == "Administrador"
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RegistroPlatillo(
                                          id: p["id"].toString(),
                                          nombre: p["nombre"],
                                          precio: p["precio"].toString(),
                                          categoria: p["categoria"]?.toString(),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final url = Uri.parse("$baseUrl/platillos/${p["id"]}");
                                    await http.delete(url);
                                    mostrarNotificacion("Platillo Removido", "Se ha eliminado ${p["nombre"]}");
                                    setState(() {});
                                  },
                                ),
                              ],
                            )
                          : IconButton(
                              icon: const Icon(Icons.add_shopping_cart, color: Colors.orange),
                              onPressed: () {
                                carritoGlobal.add({
                                  "platillo_id": p["id"],
                                  "nombre": p["nombre"],
                                  "precio": double.tryParse(p["precio"].toString()) ?? 0.0,
                                  "cantidad": 1,
                                  "subtotal": double.tryParse(p["precio"].toString()) ?? 0.0,
                                  "imagen": p["imagen"]
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("${p["nombre"]} agregado al carrito")),
                                );
                              },
                            ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

// ==========================================
// CÁLCULO DE CUENTA
// ==========================================
class CamposCalculados extends StatefulWidget {
  @override
  CamposCalculadosState createState() => CamposCalculadosState();
}

class CamposCalculadosState extends State<CamposCalculados> {
  final cantidadController = TextEditingController();
  final precioController = TextEditingController();

  List platillos = [];
  Map<String, dynamic>? platilloSeleccionado;
  String resultado = '';
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    obtenerPlatillos();
  }

  Future<void> obtenerPlatillos() async {
    try {
      final url = Uri.parse("$baseUrl/platillos");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          platillos = jsonDecode(response.body);
          cargando = false;
        });
      }
    } catch (e) {
      setState(() => cargando = false);
    }
  }

  void calcularTotal() async {
    if (platilloSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Seleccione un platillo")));
      return;
    }

    int cantidad = int.tryParse(cantidadController.text) ?? 0;
    double precio = double.tryParse(precioController.text) ?? 0;
    double total = cantidad * precio;

    setState(() {
      resultado = 'Total a pagar: \$$total';
    });

    final url = Uri.parse("$baseUrl/operaciones");
    await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "platillo_id": platilloSeleccionado!["id"],
        "cantidad": cantidad,
        "precio": precio,
        "total": total,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cálculo de Cuenta")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                cargando
                    ? const CircularProgressIndicator()
                    : DropdownButtonFormField<Map<String, dynamic>>(
                        decoration: InputDecoration(
                          labelText: "Seleccionar platillo",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        value: platilloSeleccionado,
                        items: platillos.map<DropdownMenuItem<Map<String, dynamic>>>((p) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: p,
                            child: Text("${p["nombre"]} - \$${p["precio"]}"),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            platilloSeleccionado = val;
                            if (val != null) {
                              precioController.text = val["precio"].toString();
                            }
                          });
                        },
                      ),
                const SizedBox(height: 16),
                TextField(
                  controller: cantidadController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Cantidad de platillos",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: precioController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Precio unitario",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE65100)),
                    onPressed: calcularTotal,
                    child: const Text("Calcular Total", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  resultado,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// OPERACIONES
// ==========================================
class ListaOperaciones extends StatefulWidget {
  @override
  ListaOperacionesState createState() => ListaOperacionesState();
}

class ListaOperacionesState extends State<ListaOperaciones> {
  Future<List> obtenerOperaciones() async {
    final url = Uri.parse("$baseUrl/operaciones");
    final response = await http.get(url);
    return jsonDecode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Operaciones del Restaurante")),
      body: FutureBuilder<List>(
        future: obtenerOperaciones(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar datos"));
          } else {
            final operaciones = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: operaciones.length,
              itemBuilder: (context, index) {
                final op = operaciones[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.receipt_long, color: Colors.white),
                    ),
                    title: Text("${op["nombre"]}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Cantidad: ${op["cantidad"]} | Precio: \$${op["precio"]}"),
                    trailing: Text("\$${op["total"]}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

// ==========================================
// REPORTES RESTAURANTE
// ==========================================
class ReportesRestaurante extends StatefulWidget {
  @override
  ReportesRestauranteState createState() => ReportesRestauranteState();
}

class ReportesRestauranteState extends State<ReportesRestaurante> {
  Future<Map<String, dynamic>> obtenerReportes() async {
    final totalUrl = Uri.parse("$baseUrl/reportes/total");
    final promedioUrl = Uri.parse("$baseUrl/reportes/promedio");
    final masVendidoUrl = Uri.parse("$baseUrl/reportes/masvendido");

    final totalResp = await http.get(totalUrl);
    final promedioResp = await http.get(promedioUrl);
    final masVendidoResp = await http.get(masVendidoUrl);

    return {
      "total": jsonDecode(totalResp.body)["total_ventas"] ?? 0,
      "promedio": jsonDecode(promedioResp.body)["promedio_precio"] ?? 0,
      "masvendido": jsonDecode(masVendidoResp.body)["nombre"] ?? "N/A",
    };
  }

  Widget _crearTarjetaReporte(String titulo, String valor, IconData icono, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icono, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(valor, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reportes Generales")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: obtenerReportes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar reportes"));
          } else {
            final reportes = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _crearTarjetaReporte("Total de Ventas", "\$${reportes["total"]}", Icons.monetization_on, Colors.green),
                  const SizedBox(height: 12),
                  _crearTarjetaReporte("Promedio de Precios", "\$${reportes["promedio"]}", Icons.show_chart, Colors.blue),
                  const SizedBox(height: 12),
                  _crearTarjetaReporte("Platillo Más Vendido", "${reportes["masvendido"]}", Icons.star, Colors.amber),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

// ==========================================
// GRÁFICAS GENERALES
// ==========================================
class GraficasRestaurante extends StatefulWidget {
  @override
  GraficasRestauranteState createState() => GraficasRestauranteState();
}

class GraficasRestauranteState extends State<GraficasRestaurante> {
  Future<Map<String, dynamic>> obtenerReportes() async {
    final totalUrl = Uri.parse("$baseUrl/reportes/total");
    final promedioUrl = Uri.parse("$baseUrl/reportes/promedio");
    final masVendidoUrl = Uri.parse("$baseUrl/reportes/masvendido");

    final totalResp = await http.get(totalUrl);
    final promedioResp = await http.get(promedioUrl);
    final masVendidoResp = await http.get(masVendidoUrl);

    return {
      "total": jsonDecode(totalResp.body)["total_ventas"] ?? 0,
      "promedio": jsonDecode(promedioResp.body)["promedio_precio"] ?? 0,
      "masvendido": jsonDecode(masVendidoResp.body)["nombre"] ?? "N/A",
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gráficas del Restaurante")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: obtenerReportes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar gráficas"));
          } else {
            final reportes = snapshot.data!;
            double total = double.tryParse(reportes["total"].toString()) ?? 10.0;
            double promedio = double.tryParse(reportes["promedio"].toString()) ?? 5.0;

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        borderData: FlBorderData(
                          show: true,
                          border: const Border(
                            bottom: BorderSide(color: Colors.black, width: 2),
                            left: BorderSide(color: Colors.black, width: 2),
                          ),
                        ),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                switch (value.toInt()) {
                                  case 0:
                                    return const Text("Ventas");
                                  case 1:
                                    return const Text("Promedio");
                                  default:
                                    return const Text("");
                                }
                              },
                            ),
                          ),
                        ),
                        barGroups: [
                          BarChartGroupData(x: 0, barRods: [
                            BarChartRodData(toY: total > 0 ? total : 9, color: Colors.green, width: 28, borderRadius: BorderRadius.circular(6))
                          ]),
                          BarChartGroupData(x: 1, barRods: [
                            BarChartRodData(toY: promedio > 0 ? promedio : 7.5, color: Colors.cyan, width: 28, borderRadius: BorderRadius.circular(6))
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Platillo más vendido: ${reportes["masvendido"]}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

// ==========================================
// PANEL ADMINISTRATIVO
// ==========================================
class PanelAdministrativo extends StatefulWidget {
  @override
  PanelAdministrativoState createState() => PanelAdministrativoState();
}

class PanelAdministrativoState extends State<PanelAdministrativo> {
  List platillos = [];
  String filtro = "";
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    obtenerPlatillos();
  }

  Future<void> obtenerPlatillos() async {
    try {
      final url = Uri.parse("$baseUrl/platillos");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          platillos = jsonDecode(response.body);
          cargando = false;
        });
      }
    } catch (e) {
      setState(() => cargando = false);
    }
  }

  void agregarAlCarrito(Map<String, dynamic> platillo) {
    double precio = double.tryParse(platillo["precio"].toString()) ?? 0.0;
    
    setState(() {
      carritoGlobal.add({
        "platillo_id": platillo["id"],
        "nombre": platillo["nombre"],
        "precio": precio,
        "cantidad": 1,
        "subtotal": precio,
        "imagen": platillo["imagen"]
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${platillo["nombre"]} agregado al carrito")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categorias = ["Postres", "Platos Fuertes", "Bebidas"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel Administrativo"),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, '/carrito'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/admin_reporte_meseros'),
                  icon: const Icon(Icons.badge, size: 16),
                  label: const Text("Meseros"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/admin_reporte_clientes'),
                  icon: const Icon(Icons.people, size: 16),
                  label: const Text("Clientes"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/estadisticas_meseros'),
                  icon: const Icon(Icons.bar_chart, size: 16),
                  label: const Text("G. Meseros"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/estadisticas_clientes'),
                  icon: const Icon(Icons.pie_chart, size: 16),
                  label: const Text("G. Clientes"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/exportar'),
                icon: const Icon(Icons.file_download, color: Colors.white),
                label: const Text("EXPORTAR REPORTES (PDF / EXCEL)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Buscar platillo...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (valor) => setState(() => filtro = valor.toLowerCase()),
            ),
          ),
          Expanded(
            child: cargando
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: categorias.map((cat) {
                      final filtrados = platillos.where((p) {
                        final coincideCategoria = p["categoria"] == cat;
                        final coincideNombre = (p["nombre"] ?? '').toString().toLowerCase().contains(filtro);
                        return coincideCategoria && coincideNombre;
                      }).toList();

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ExpansionTile(
                          leading: const Icon(Icons.restaurant_menu, color: Colors.orange),
                          title: Text(cat, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          children: filtrados.map<Widget>((p) {
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: p["imagen"] != null && p["imagen"].toString().isNotEmpty
                                    ? Image.network("$baseUrl/uploads/${p["imagen"]}", width: 45, height: 45, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.fastfood))
                                    : const Icon(Icons.fastfood),
                              ),
                              title: Text("${p["nombre"]}"),
                              subtitle: Text("Precio: \$${p["precio"]}"),
                              trailing: IconButton(
                                icon: const Icon(Icons.add_shopping_cart, color: Colors.green),
                                onPressed: () => agregarAlCarrito(p),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// CARRITO DE COMPRAS
// ==========================================
class CarritoCompras extends StatefulWidget {
  final List<Map<String, dynamic>> carrito;
  CarritoCompras({required this.carrito});

  @override
  CarritoComprasState createState() => CarritoComprasState();
}

class CarritoComprasState extends State<CarritoCompras> {
  List meseros = [];
  List clientes = [];
  int? meseroSeleccionado;
  int? clienteSeleccionado;

  @override
  void initState() {
    super.initState();
    if (rolUsuarioLogueado == "Administrador") {
      obtenerMeseros();
      obtenerClientes();
    }
  }

  Future<void> obtenerMeseros() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/usuarios/meseros"));
      if (res.statusCode == 200) setState(() => meseros = jsonDecode(res.body));
    } catch (_) {}
  }

  Future<void> obtenerClientes() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/usuarios/clientes"));
      if (res.statusCode == 200) setState(() => clientes = jsonDecode(res.body));
    } catch (_) {}
  }

  double calcularTotal() {
    return widget.carrito.fold(
        0.0, (sum, item) => sum + (double.tryParse(item["subtotal"].toString()) ?? 0.0));
  }

  void confirmarOrden() async {
    if (widget.carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("El carrito está vacío")));
      return;
    }

    int? finalMeseroId = meseroSeleccionado;
    int? finalClienteId = clienteSeleccionado;

    if (rolUsuarioLogueado == "Mesero") {
      finalMeseroId = usuarioIdLogueado;
    } else if (rolUsuarioLogueado == "Cliente") {
      finalClienteId = usuarioIdLogueado;
    }

    final url = Uri.parse("$baseUrl/ordenes");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "total": calcularTotal(),
        "detalle": widget.carrito,
        "mesero_id": finalMeseroId,
        "cliente_id": finalClienteId,
      }),
    );

    final resData = jsonDecode(response.body);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resData["mensaje"] ?? "Procesado")));

    if (resData["status"] == "ok") {
      mostrarNotificacion(
        "Orden Registrada Exitosamente",
        "Se ha procesado una nueva orden por un total de \$${calcularTotal()}.",
      );
      setState(() => widget.carrito.clear());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Carrito de Compras")),
      body: Column(
        children: [
          if (rolUsuarioLogueado == "Administrador") ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: "Asignar Mesero", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                value: meseroSeleccionado,
                items: meseros.map<DropdownMenuItem<int>>((m) => DropdownMenuItem<int>(value: m["id"], child: Text(m["usuario"]))).toList(),
                onChanged: (val) => setState(() => meseroSeleccionado = val),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: "Asignar Cliente", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                value: clienteSeleccionado,
                items: clientes.map<DropdownMenuItem<int>>((c) => DropdownMenuItem<int>(value: c["id"], child: Text(c["usuario"]))).toList(),
                onChanged: (val) => setState(() => clienteSeleccionado = val),
              ),
            ),
          ],
          Expanded(
            child: widget.carrito.isEmpty
                ? const Center(child: Text("No hay platillos en el carrito"))
                : ListView.builder(
                    itemCount: widget.carrito.length,
                    itemBuilder: (context, index) {
                      final item = widget.carrito[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          title: Text(item["nombre"], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("${item["cantidad"]} x \$${item["precio"]} = \$${item["subtotal"]}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => setState(() => widget.carrito.removeAt(index)),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("\$${calcularTotal()}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: confirmarOrden,
                    child: const Text("Confirmar Orden", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// HISTORIAL DE ÓRDENES
// ==========================================
class HistorialOrdenes extends StatefulWidget {
  @override
  HistorialOrdenesState createState() => HistorialOrdenesState();
}

class HistorialOrdenesState extends State<HistorialOrdenes> {
  Future<List> obtenerHistorial() async {
    final url = Uri.parse("$baseUrl/historial");
    final response = await http.get(url);
    return jsonDecode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historial de Órdenes")),
      body: FutureBuilder<List>(
        future: obtenerHistorial(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text("Error al cargar historial"));
          } else {
            final historial = snapshot.data!;
            Map<int, List> ordenesAgrupadas = {};

            for (var item in historial) {
              int id = item["orden_id"] ?? item["id"];
              if (!ordenesAgrupadas.containsKey(id)) {
                ordenesAgrupadas[id] = [];
              }
              ordenesAgrupadas[id]!.add(item);
            }

            return ListView(
              children: ordenesAgrupadas.entries.map((entry) {
                final orden = entry.value;
                final fecha = orden[0]["fecha"];
                final total = orden[0]["total"];
                final mesero = orden[0]["mesero_nombre"] ?? "Sin asignar";
                final cliente = orden[0]["cliente_nombre"] ?? "Sin asignar";

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ExpansionTile(
                    leading: const CircleAvatar(backgroundColor: Colors.brown, child: Icon(Icons.history, color: Colors.white)),
                    title: Text("Orden #${entry.key}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Mesero: $mesero | Cliente: $cliente\nFecha: $fecha"),
                    trailing: Text("\$$total", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                    children: orden.map<Widget>((detalle) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.fastfood, color: Colors.orange, size: 20),
                      title: Text("${detalle["platillo"] ?? detalle["nombre"]}"),
                      subtitle: Text("${detalle["cantidad"]} x \$${detalle["subtotal"]}"),
                    )).toList(),
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}

// ==========================================
// SECCIONES DE ROL MESERO Y CLIENTE
// ==========================================
class OrdenesMeseroScreen extends StatefulWidget {
  @override
  OrdenesMeseroScreenState createState() => OrdenesMeseroScreenState();
}

class OrdenesMeseroScreenState extends State<OrdenesMeseroScreen> {
  Future<List> obtenerOrdenesMesero() async {
    final url = Uri.parse("$baseUrl/ordenes/mesero/$usuarioIdLogueado");
    final response = await http.get(url);
    return jsonDecode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Órdenes Asignadas (Mesero)")),
      body: FutureBuilder<List>(
        future: obtenerOrdenesMesero(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text("Sin órdenes asignadas"));
          } else {
            final historial = snapshot.data!;
            Map<int, List> ordenesAgrupadas = {};

            for (var item in historial) {
              int id = item["orden_id"];
              if (!ordenesAgrupadas.containsKey(id)) ordenesAgrupadas[id] = [];
              ordenesAgrupadas[id]!.add(item);
            }

            return ListView(
              children: ordenesAgrupadas.entries.map((entry) {
                final orden = entry.value;
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ExpansionTile(
                    title: Text("Orden #${entry.key} - Cliente: ${orden[0]["cliente_nombre"] ?? "No asignado"}"),
                    subtitle: Text("Total: \$${orden[0]["total"]}"),
                    children: orden.map<Widget>((d) => ListTile(
                      title: Text("${d["platillo"]}"),
                      subtitle: Text("${d["cantidad"]} x \$${d["subtotal"]}"),
                    )).toList(),
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}

class OrdenesClienteScreen extends StatefulWidget {
  @override
  OrdenesClienteScreenState createState() => OrdenesClienteScreenState();
}

class OrdenesClienteScreenState extends State<OrdenesClienteScreen> {
  Future<List> obtenerOrdenesCliente() async {
    final url = Uri.parse("$baseUrl/ordenes/cliente/$usuarioIdLogueado");
    final response = await http.get(url);
    return jsonDecode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis Pedidos Realizados")),
      body: FutureBuilder<List>(
        future: obtenerOrdenesCliente(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text("Sin pedidos registrados"));
          } else {
            final historial = snapshot.data!;
            Map<int, List> ordenesAgrupadas = {};

            for (var item in historial) {
              int id = item["orden_id"];
              if (!ordenesAgrupadas.containsKey(id)) ordenesAgrupadas[id] = [];
              ordenesAgrupadas[id]!.add(item);
            }

            return ListView(
              children: ordenesAgrupadas.entries.map((entry) {
                final orden = entry.value;
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ExpansionTile(
                    title: Text("Pedido #${entry.key}"),
                    subtitle: Text("Total: \$${orden[0]["total"]}"),
                    children: orden.map<Widget>((d) => ListTile(
                      title: Text("${d["platillo"]}"),
                      subtitle: Text("${d["cantidad"]} x \$${d["subtotal"]}"),
                    )).toList(),
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}

class ReportesMesero extends StatefulWidget {
  @override
  ReportesMeseroState createState() => ReportesMeseroState();
}

class ReportesMeseroState extends State<ReportesMesero> {
  Future<List> obtenerReportesMesero() async {
    final url = Uri.parse("$baseUrl/reportes/mesero/${usuarioIdLogueado ?? 1}");
    final response = await http.get(url);
    return jsonDecode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reportes por Mesero")),
      body: FutureBuilder<List>(
        future: obtenerReportesMesero(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final reportes = snapshot.data ?? [];
          return ListView.builder(
            itemCount: reportes.length,
            itemBuilder: (context, index) {
              final r = reportes[index];
              return ListTile(
                title: Text("Orden #${r["id"]}"),
                subtitle: Text("Total: \$${r["total"]}"),
              );
            },
          );
        },
      ),
    );
  }
}

class ReportesCliente extends StatefulWidget {
  @override
  ReportesClienteState createState() => ReportesClienteState();
}

class ReportesClienteState extends State<ReportesCliente> {
  Future<List> obtenerReportesCliente() async {
    final url = Uri.parse("$baseUrl/reportes/cliente/${usuarioIdLogueado ?? 1}");
    final response = await http.get(url);
    return jsonDecode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reportes por Cliente")),
      body: FutureBuilder<List>(
        future: obtenerReportesCliente(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final reportes = snapshot.data ?? [];
          return ListView.builder(
            itemCount: reportes.length,
            itemBuilder: (context, index) {
              final r = reportes[index];
              return ListTile(
                title: Text("Pedido #${r["id"]}"),
                subtitle: Text("Total: \$${r["total"]}"),
              );
            },
          );
        },
      ),
    );
  }
}

// ==========================================
// REPORTES Y LISTADOS DE ADMINISTRADOR
// ==========================================
class AdminReporteMeseros extends StatefulWidget {
  @override
  AdminReporteMeserosState createState() => AdminReporteMeserosState();
}

class AdminReporteMeserosState extends State<AdminReporteMeseros> {
  Future<List> obtenerReporteMeseros() async {
    final url = Uri.parse("$baseUrl/admin/reporte-meseros");
    final response = await http.get(url);
    return jsonDecode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Desempeño de Meseros")),
      body: FutureBuilder<List>(
        future: obtenerReporteMeseros(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final meseros = snapshot.data ?? [];
          return ListView.builder(
            itemCount: meseros.length,
            itemBuilder: (context, index) {
              final m = meseros[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(child: Text("${m["mesero_id"]}")),
                  title: Text(m["mesero_nombre"], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Ventas totales: \$${m["total_ventas"]}"),
                  trailing: Text("${m["total_ordenes"]} órdenes"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AdminReporteClientes extends StatefulWidget {
  @override
  AdminReporteClientesState createState() => AdminReporteClientesState();
}

class AdminReporteClientesState extends State<AdminReporteClientes> {
  Future<List> obtenerReporteClientes() async {
    final url = Uri.parse("$baseUrl/admin/reporte-clientes");
    final response = await http.get(url);
    return jsonDecode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historial de Clientes")),
      body: FutureBuilder<List>(
        future: obtenerReporteClientes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final clientes = snapshot.data ?? [];
          return ListView.builder(
            itemCount: clientes.length,
            itemBuilder: (context, index) {
              final c = clientes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.teal, child: Text("${c["cliente_id"]}", style: const TextStyle(color: Colors.white))),
                  title: Text(c["cliente_nombre"], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Total consumido: \$${c["total_compras"]}"),
                  trailing: Text("${c["total_ordenes"]} pedidos"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ==========================================
// ESTADÍSTICAS GRÁFICAS Y EXPORTAR
// ==========================================
class EstadisticasMeserosScreen extends StatefulWidget {
  @override
  EstadisticasMeserosScreenState createState() => EstadisticasMeserosScreenState();
}

class EstadisticasMeserosScreenState extends State<EstadisticasMeserosScreen> {
  Future<List> obtenerEstadisticas() async {
    final url = Uri.parse("$baseUrl/estadisticas/meseros");
    final response = await http.get(url);
    return jsonDecode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ventas por Mesero")),
      body: FutureBuilder<List>(
        future: obtenerEstadisticas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final datos = snapshot.data ?? [];
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: BarChart(
              BarChartData(
                barGroups: datos.asMap().entries.map((entry) {
                  return BarChartGroupData(x: entry.key, barRods: [
                    BarChartRodData(toY: double.tryParse(entry.value["ventas"].toString()) ?? 0, color: Colors.blueAccent, width: 22)
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class EstadisticasClientesScreen extends StatefulWidget {
  @override
  EstadisticasClientesScreenState createState() => EstadisticasClientesScreenState();
}

class EstadisticasClientesScreenState extends State<EstadisticasClientesScreen> {
  Future<List> obtenerEstadisticas() async {
    final url = Uri.parse("$baseUrl/estadisticas/clientes");
    final response = await http.get(url);
    return jsonDecode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pedidos por Cliente")),
      body: FutureBuilder<List>(
        future: obtenerEstadisticas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final datos = snapshot.data ?? [];
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: PieChart(
              PieChartData(
                sections: datos.asMap().entries.map((entry) {
                  double val = double.tryParse(entry.value["pedidos"].toString()) ?? 0;
                  return PieChartSectionData(
                    value: val,
                    title: "${entry.value["usuario"]}\n($val)",
                    radius: 70,
                    color: Colors.primaries[entry.key % Colors.primaries.length],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ExportarReportesScreen extends StatefulWidget {
  @override
  ExportarReportesScreenState createState() => ExportarReportesScreenState();
}

class ExportarReportesScreenState extends State<ExportarReportesScreen> {
  bool cargando = false;

  Future<void> descargarArchivo(String tipo) async {
    setState(() => cargando = true);
    try {
      final url = Uri.parse("$baseUrl/export/$tipo");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final ext = tipo == "pdf" ? "pdf" : "xlsx";
        final filePath = "${dir.path}/reporte_ventas.$ext";
        final file = File(filePath);

        await file.writeAsBytes(response.bodyBytes);
        mostrarNotificacion("Reporte Generado", "El archivo $tipo se guardó correctamente.");
        await OpenFilex.open(filePath);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al descargar: $e")));
    } finally {
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Exportar Reportes")),
      body: Center(
        child: cargando
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.picture_as_pdf_rounded, size: 80, color: Colors.purple),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, minimumSize: const Size(double.infinity, 50)),
                      onPressed: () => descargarArchivo("pdf"),
                      icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                      label: const Text("EXPORTAR A PDF", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 50)),
                      onPressed: () => descargarArchivo("excel"),
                      icon: const Icon(Icons.table_chart, color: Colors.white),
                      label: const Text("EXPORTAR A EXCEL", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
