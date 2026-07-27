import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';

class Faculty {
  final String id;
  final String name;
  final LatLng location;
  final IconData icon;
  final Color color;

  Faculty(this.id, this.name, this.location, this.icon, this.color);
}

// Representa una conexión en el grafo
class Edge {
  final String from;
  final String to;
  final double distance;

  Edge(this.from, this.to, this.distance);
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  
  // Centro base (UTMACH Campus Ferroviaria)
  final LatLng _center = const LatLng(-3.286223, -79.911946); 

  // Límites estrictos a 1km a la redonda
  final LatLngBounds _bounds1km = LatLngBounds(
    const LatLng(-3.295223, -79.920946),
    const LatLng(-3.277223, -79.902946),
  );

  // Lista oficial de lugares UTMACH proporcionados
  final List<Faculty> _faculties = [
    Faculty('emp_med', 'Aulas Emp. y Medicina', const LatLng(-3.285561, -79.913546), Icons.business, Colors.blue),
    Faculty('soc', 'Facultad C. Sociales', const LatLng(-3.285439, -79.910775), Icons.people, Colors.green),
    Faculty('lab_emp', 'Lab. C. Empresariales', const LatLng(-3.285728, -79.909917), Icons.computer, Colors.teal),
    Faculty('bar1', 'Bar 1', const LatLng(-3.2866611476504852, -79.90941409404812), Icons.local_cafe, Colors.orange),
    Faculty('ing_civ', 'Facultad Ing. Civil', const LatLng(-3.287357, -79.910499), Icons.engineering, Colors.red),
    Faculty('estadio', 'Estadio UTMACH', const LatLng(-3.283825, -79.908990), Icons.sports_soccer, Colors.lightGreen),
    Faculty('ing_ferro', 'Ingreso Ferroviaria', const LatLng(-3.282826, -79.909518), Icons.door_front_door, Colors.brown),
    Faculty('ing_prin', 'Ingreso Principal', const LatLng(-3.287073, -79.912672), Icons.account_balance, Colors.indigo),
    Faculty('auditorium', 'Salón Auditorium', const LatLng(-3.286690, -79.912657), Icons.campaign, Colors.deepPurple),
    Faculty('qui_sal', 'C. Químicas y Salud', const LatLng(-3.285641, -79.911923), Icons.science, Colors.pink),
  ];

  // Adjacency List para el Grafo (Caminos permitidos)
  List<Edge> _edges = [];

  Faculty? _origin;
  Faculty? _destination;
  List<Polyline> _polylines = [];
  List<String> _routeSteps = [];
  bool _isLoadingRoute = false;

  @override
  void initState() {
    super.initState();
    _buildGraph();
  }

  // Calcula la distancia euclidiana aproximada en metros (Fórmula de Haversine simplificada)
  double _calculateDistance(LatLng p1, LatLng p2) {
    const double R = 6371e3; // Radio de la tierra en metros
    final phi1 = p1.latitude * pi / 180;
    final phi2 = p2.latitude * pi / 180;
    final deltaPhi = (p2.latitude - p1.latitude) * pi / 180;
    final deltaLambda = (p2.longitude - p1.longitude) * pi / 180;

    final a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
              cos(phi1) * cos(phi2) *
              sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  // Crea conexiones bidireccionales entre nodos
  void _addConnection(String id1, String id2) {
    final f1 = _faculties.firstWhere((f) => f.id == id1);
    final f2 = _faculties.firstWhere((f) => f.id == id2);
    final dist = _calculateDistance(f1.location, f2.location);
    _edges.add(Edge(id1, id2, dist));
    _edges.add(Edge(id2, id1, dist));
  }

  void _buildGraph() {
    _edges.clear();
    // Definimos la red de caminos lógicos peatonales en el campus
    _addConnection('ing_ferro', 'estadio');
    _addConnection('estadio', 'lab_emp');
    _addConnection('lab_emp', 'soc');
    _addConnection('soc', 'qui_sal');
    _addConnection('qui_sal', 'emp_med');
    _addConnection('emp_med', 'auditorium');
    _addConnection('auditorium', 'ing_prin');
    _addConnection('ing_prin', 'ing_civ');
    _addConnection('ing_civ', 'bar1');
    _addConnection('bar1', 'lab_emp');
    _addConnection('bar1', 'soc');
    _addConnection('qui_sal', 'auditorium');
    _addConnection('soc', 'ing_civ');
  }

  // Implementación del Algoritmo de Dijkstra
  List<Faculty> _dijkstra(String startId, String endId) {
    Map<String, double> distances = {};
    Map<String, String?> previous = {};
    List<String> unvisited = [];

    for (var f in _faculties) {
      distances[f.id] = double.infinity;
      previous[f.id] = null;
      unvisited.add(f.id);
    }
    distances[startId] = 0;

    while (unvisited.isNotEmpty) {
      // Ordenar por menor distancia
      unvisited.sort((a, b) => distances[a]!.compareTo(distances[b]!));
      String current = unvisited.first;

      if (current == endId) break; // Encontramos el destino
      unvisited.remove(current);

      // Evaluar vecinos
      var neighbors = _edges.where((e) => e.from == current).toList();
      for (var edge in neighbors) {
        if (unvisited.contains(edge.to)) {
          double alt = distances[current]! + edge.distance;
          if (alt < distances[edge.to]!) {
            distances[edge.to] = alt;
            previous[edge.to] = current;
          }
        }
      }
    }

    // Reconstruir el camino óptimo
    List<Faculty> path = [];
    String? current = endId;
    while (current != null) {
      path.insert(0, _faculties.firstWhere((f) => f.id == current));
      current = previous[current];
    }
    
    // Validar si realmente hay conexión
    if (path.first.id != startId) {
      return []; // Ruta no encontrada
    }
    return path;
  }

  void _drawRoute() async {
    if (_origin == null || _destination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona origen y destino.')),
      );
      return;
    }

    if (_origin!.id == _destination!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El origen y destino no pueden ser el mismo.')),
      );
      return;
    }

    setState(() {
      _isLoadingRoute = true;
      _routeSteps.clear();
      _polylines.clear();
    });

    // Simulamos un leve retraso para efecto de cálculo en UI
    await Future.delayed(const Duration(milliseconds: 300));

    // Ejecutar Dijkstra
    List<Faculty> optimalPath = _dijkstra(_origin!.id, _destination!.id);

    if (optimalPath.isEmpty) {
       setState(() {
         _isLoadingRoute = false;
         _routeSteps = ['Error: Puntos incomunicados en el grafo de rutas.'];
       });
       return;
    }

    // Extraer coordenadas y generar instrucciones
    List<LatLng> routePoints = [];
    List<String> steps = [];
    
    for (int i = 0; i < optimalPath.length; i++) {
      routePoints.add(optimalPath[i].location);
      if (i == 0) {
        steps.add('Inicia tu recorrido desde ${optimalPath[i].name}');
      } else if (i == optimalPath.length - 1) {
        double dist = _calculateDistance(optimalPath[i-1].location, optimalPath[i].location);
        steps.add('Camina ${dist.toInt()} metros y habrás llegado a ${optimalPath[i].name}');
      } else {
        double dist = _calculateDistance(optimalPath[i-1].location, optimalPath[i].location);
        steps.add('Camina ${dist.toInt()} metros hacia ${optimalPath[i].name}');
      }
    }

    setState(() {
      _polylines = [
        Polyline(
          points: routePoints,
          color: Colors.blueAccent,
          strokeWidth: 6.0,
        ),
      ];
      _routeSteps = steps;
      _isLoadingRoute = false;
    });

    // Centrar la cámara en la ruta
    final bounds = LatLngBounds.fromPoints(routePoints);
    _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(80.0)));
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // Panel de Selección Dinámica de Rutas
            Container(
              padding: const EdgeInsets.all(12.0),
              color: Theme.of(context).cardColor,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.my_location, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<Faculty>(
                          isExpanded: true,
                          hint: const Text('¿Dónde estás? (Origen)'),
                          value: _origin,
                          onChanged: (Faculty? newValue) {
                            setState(() => _origin = newValue);
                          },
                          items: _faculties.map((Faculty fac) {
                            return DropdownMenuItem<Faculty>(
                              value: fac,
                              child: Text(fac.name),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 20, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<Faculty>(
                          isExpanded: true,
                          hint: const Text('¿A dónde vas? (Destino)'),
                          value: _destination,
                          onChanged: (Faculty? newValue) {
                            setState(() => _destination = newValue);
                          },
                          items: _faculties.map((Faculty fac) {
                            return DropdownMenuItem<Faculty>(
                              value: fac,
                              child: Text(fac.name),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isLoadingRoute ? null : _drawRoute,
                        icon: _isLoadingRoute 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                          : const Icon(Icons.route),
                        label: const Text('Trazar Ruta Dijkstra'),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _origin = null;
                            _destination = null;
                            _polylines.clear();
                            _routeSteps.clear();
                          });
                          _mapController.move(_center, 15.5);
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Limpiar'),
                        style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                      ),
                    ],
                  )
                ],
              ),
            ),
            
            // Renderizado del Mapa
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _center,
                      initialZoom: 15.5,
                      minZoom: 14.5,
                      maxZoom: 18.0,
                      cameraConstraint: CameraConstraint.contain(
                        bounds: _bounds1km,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.utmach_app',
                      ),
                      PolylineLayer(
                        polylines: _polylines,
                      ),
                      MarkerLayer(
                        markers: _faculties.map((fac) {
                          return Marker(
                            point: fac.location,
                            width: 90,
                            height: 90,
                            child: Column(
                              children: [
                                Icon(fac.icon, color: fac.color, size: 40),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    fac.name, 
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 16,
                    bottom: 120, // Más arriba para no tapar los pasos
                    child: Column(
                      children: [
                        FloatingActionButton(
                          heroTag: 'zoom_in',
                          mini: true,
                          onPressed: _zoomIn,
                          child: const Icon(Icons.add),
                        ),
                        const SizedBox(height: 8),
                        FloatingActionButton(
                          heroTag: 'zoom_out',
                          mini: true,
                          onPressed: _zoomOut,
                          child: const Icon(Icons.remove),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Tarjeta Desplegable de Instrucciones Paso a Paso
        if (_routeSteps.isNotEmpty)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    width: double.infinity,
                    child: const Text(
                      'Ruta Mapeada Internamente',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _routeSteps.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_routeSteps[index], style: const TextStyle(fontSize: 14)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
