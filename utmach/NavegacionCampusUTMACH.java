package navegacioncampusutmach.navegacioncampusutmach;

/**
 * Prototipo de Navegacion Universitaria (UTMACH) - Version Dinamica
 */
import java.util.Scanner;
import java.util.ArrayList;
import java.util.Collections;

public class NavegacionCampusUTMACH {

    static Scanner scanner = new Scanner(System.in);
    
    // Variables para Estadisticas de Simulacion
    static int numRecalculos = 0;
    static int numAlertas = 0;
    static int[] visitas = new int[6];
    static double tiempoTotalViaje = 0.0;
    static ArrayList<String> historialNodos = new ArrayList<>();

    public static void main(String[] args) {
        int opcion;

        String[] nombres = new String[6];
        int[] coordX = new int[6];
        int[] coordY = new int[6];
        boolean[] congestion = new boolean[6];
        double[][] matriz = new double[6][6];

        inicializarCampus(nombres, coordX, coordY, congestion, matriz);

        do {
            System.out.println("");
            System.out.println("========================================================");
            System.out.println("   SISTEMA DE NAVEGACION UNIVERSITARIA - UTMACH");
            System.out.println("========================================================");
            System.out.println("  1. Ejecutar busqueda de ruta dinamica (Paso a Paso)");
            System.out.println("  2. Mostrar matriz de adyacencia (Grafo)");
            System.out.println("  3. Consultar plano de coordenadas cartesianas");
            System.out.println("  4. Salir");
            System.out.print("Seleccione opcion (1-4): ");
            
            opcion = scanner.nextInt();

            switch (opcion) {
                case 1:
                    // Se clona la matriz para poder modificarla (cerrar caminos) sin afectar otras ejecuciones
                    double[][] matrizSimulacion = clonarMatriz(matriz);
                    ejecutarNavegacionDinamica(matrizSimulacion, congestion, nombres);
                    break;
                case 2:
                    System.out.println("");
                    System.out.println("--- MATRIZ DE ADYACENCIA ---");
                    for (int i = 0; i <= 5; i++) {
                        System.out.print("[" + i + "] -> ");
                        for (int j = 0; j <= 5; j++) {
                            System.out.print(Math.round(matriz[i][j]) + " | ");
                        }
                        System.out.println();
                    }
                    break;
                case 3:
                    System.out.println("");
                    System.out.println("--- COORDENADAS REGISTRADAS ---");
                    for (int i = 0; i <= 5; i++) {
                        System.out.println(" [" + i + "] " + nombres[i] + " -> X: " + coordX[i] + "m | Y: " + coordY[i] + "m");
                    }
                    break;
                case 4:
                    System.out.println("Finalizando el motor de busqueda. ¡Exitos en sus estudios!");
                    break;
                default:
                    System.out.println("Opcion incorrecta. Intente de nuevo.");
            }
        } while (opcion != 4);
    }

    public static double[][] clonarMatriz(double[][] original) {
        double[][] clon = new double[6][6];
        for (int i = 0; i < 6; i++) {
            System.arraycopy(original[i], 0, clon[i], 0, 6);
        }
        return clon;
    }

    public static void conectar(double[][] matriz, int[] coordX, int[] coordY, int n1, int n2) {
        double dist;
        dist = Math.sqrt(Math.pow(coordX[n2] - coordX[n1], 2) + Math.pow(coordY[n2] - coordY[n1], 2));
        matriz[n1][n2] = dist;
        matriz[n2][n1] = dist;
    }

    public static void inicializarCampus(String[] nombres, int[] coordX, int[] coordY, boolean[] congestion, double[][] matriz) {
        nombres[0] = "Entrada Principal"; coordX[0] = 0; coordY[0] = 0; congestion[0] = false;
        nombres[1] = "Fac. Ingenieria Civil (FIC)"; coordX[1] = 120; coordY[1] = 80; congestion[1] = false;
        nombres[2] = "Fac. Ciencias Medicas y de la Salud"; coordX[2] = 250; coordY[2] = 180; congestion[2] = true;
        nombres[3] = "Fac. Ciencias Empresariales (FCE)"; coordX[3] = 80; coordY[3] = 220; congestion[3] = true;
        nombres[4] = "Fac. Ciencias Sociales (FCS)"; coordX[4] = 300; coordY[4] = 60; congestion[4] = false;
        nombres[5] = "Centro de la Facultad (Rectorado)"; coordX[5] = 160; coordY[5] = 140; congestion[5] = false;

        for (int i = 0; i <= 5; i++) {
            for (int j = 0; j <= 5; j++) {
                if (i == j) {
                    matriz[i][j] = 0.0;
                } else {
                    matriz[i][j] = -1.0; // Representa infinito/sin conexion
                }
            }
        }

        conectar(matriz, coordX, coordY, 0, 1); conectar(matriz, coordX, coordY, 0, 3);
        conectar(matriz, coordX, coordY, 0, 4); conectar(matriz, coordX, coordY, 0, 5);
        conectar(matriz, coordX, coordY, 1, 2); conectar(matriz, coordX, coordY, 1, 4);
        conectar(matriz, coordX, coordY, 1, 5); conectar(matriz, coordX, coordY, 2, 3);
        conectar(matriz, coordX, coordY, 2, 5); conectar(matriz, coordX, coordY, 3, 4);
        conectar(matriz, coordX, coordY, 3, 5); conectar(matriz, coordX, coordY, 4, 5);
    }

    public static String obtenerIndicaciones(int llave) {
        String indicaciones;
        switch (llave) {
            case 1: case 10: indicaciones = "Transite por el sendero entre la Entrada y la FIC"; break;
            case 3: case 30: indicaciones = "Siga por la avenida principal de interconexion"; break;
            case 4: case 40: indicaciones = "Camine por la via que conecta la Entrada con la FCS"; break;
            case 5: case 50: indicaciones = "Cruce la plazoleta en diagonal"; break;
            case 12: case 21: indicaciones = "Siga por el pasillo entre Ingenieria y Ciencias Medicas"; break;
            case 14: case 41: indicaciones = "Siga el sendero peatonal transversal"; break;
            case 15: case 51: indicaciones = "Cruce la plaza central inter-facultades"; break;
            case 23: case 32: indicaciones = "Camine por la vereda peatonal principal"; break;
            case 25: case 52: indicaciones = "Recorra la via de acceso al bloque administrativo"; break;
            case 34: case 43: indicaciones = "Camine cruzando la zona de las canchas deportivas"; break;
            case 35: case 53: indicaciones = "Dirijase por la explanada que conecta los edificios"; break;
            case 45: case 54: indicaciones = "Siga por el pasillo central del campus"; break;
            default: indicaciones = "Siga por la calzada peatonal del campus";
        }
        return indicaciones;
    }

    // Metodo encapsulado de Dijkstra para recalculos dinamicos
    public static ArrayList<Integer> calcularRutaDijkstra(double[][] matriz, int origen, int destino, boolean[] congestion) {
        int nMax = 6;
        double[] distancias = new double[nMax];
        int[] previo = new int[nMax];
        int[] visitado = new int[nMax];
        double velocidad = 1.4; // m/s

        for (int k = 0; k < nMax; k++) {
            distancias[k] = 99999.0;
            previo[k] = -1;
            visitado[k] = 0;
        }
        distancias[origen] = 0.0;

        for (int cont = 0; cont < nMax; cont++) {
            double minD = 99999.0;
            int u = -1;
            for (int k = 0; k < nMax; k++) {
                if (visitado[k] == 0 && distancias[k] < minD) {
                    minD = distancias[k];
                    u = k;
                }
            }

            if (u != -1) {
                visitado[u] = 1;
                for (int v = 0; v < nMax; v++) {
                    if (visitado[v] == 0 && matriz[u][v] > 0) {
                        double nuevaDistancia = distancias[u] + matriz[u][v];
                        
                        // LOGICA PROPOSICIONAL (Decisiones Optimizadas)
                        // Si la nueva distancia es menor -> Actualiza
                        if (nuevaDistancia < distancias[v]) {
                            distancias[v] = nuevaDistancia;
                            previo[v] = u;
                        } 
                        // Si hay rutas con la misma distancia -> Seleccionar la de menor tiempo (evaluando congestion)
                        else if (nuevaDistancia == distancias[v]) {
                            double tiempoAntiguo = distancias[v] / velocidad;
                            if (congestion[v]) tiempoAntiguo *= 1.2; 
                            
                            double tiempoNuevo = nuevaDistancia / velocidad;
                            if (congestion[v]) tiempoNuevo *= 1.2;
                            
                            if (tiempoNuevo < tiempoAntiguo) {
                                previo[v] = u;
                            }
                        }
                    }
                }
            }
        }

        // Reconstruir la ruta
        ArrayList<Integer> camino = new ArrayList<>();
        if (distancias[destino] == 99999.0) return camino; // No hay ruta

        int paso = destino;
        while (paso != -1) {
            camino.add(paso);
            paso = previo[paso];
        }
        Collections.reverse(camino); // Invertir para que vaya desde origen hasta destino
        return camino;
    }

    public static void ejecutarNavegacionDinamica(double[][] matriz, boolean[] congestion, String[] nombres) {
        int origen, destino;
        double minutosLimite;
        double velocidad = 1.4; // m/s
        
        // Reset de estadisticas de la simulacion actual
        numRecalculos = 0;
        numAlertas = 0;
        historialNodos.clear();
        tiempoTotalViaje = 0.0;
        for(int i=0; i<6; i++) visitas[i] = 0;

        System.out.println("");
        System.out.println("=== CONFIGURACION DEL VIAJE ===");
        for (int k = 0; k < 6; k++) {
            System.out.println("[" + k + "] " + nombres[k]);
        }
        
        do {
            System.out.print("Seleccione su ubicacion actual (0-5): ");
            origen = scanner.nextInt();
        } while (origen < 0 || origen > 5);

        do {
            System.out.print("Seleccione su destino (0-5, diferente al origen): ");
            destino = scanner.nextInt();
        } while (destino < 0 || destino > 5 || origen == destino);
        
        System.out.print("Ingrese su tiempo limite antes de clase (en minutos): ");
        minutosLimite = scanner.nextDouble();

        System.out.println("\n=========================================================");
        System.out.println("  INICIANDO SIMULACION DINAMICA (PASO A PASO)  ");
        System.out.println("=========================================================");

        int actual = origen;
        double distanciaTotalRecorrida = 0;
        boolean eventoForzado = false;
        String expresionMatematica = "";
        
        // Registrar visita al origen
        historialNodos.add(nombres[actual]);
        visitas[actual]++;

        while (actual != destino) {
            // Recalcular ruta desde la posicion actual
            ArrayList<Integer> ruta = calcularRutaDijkstra(matriz, actual, destino, congestion);
            
            if (ruta.isEmpty() || ruta.get(0) != actual) {
                System.out.println("\n[ERROR CRITICO] No hay rutas conectadas hacia el destino. Viaje cancelado.");
                break;
            }
            
            int siguiente = ruta.get(1); // ruta.get(0) es el nodo actual
            double distTramo = matriz[actual][siguiente];
            
            // LOGICA PROPOSICIONAL Y EVENTOS EN TIEMPO REAL
            // Probabilidad del 25% de que se cierre el camino a mitad del trayecto (se ejecuta una sola vez)
            if (!eventoForzado && Math.random() < 0.25) {
                System.out.println("\n>>> [ALERTA DE IMPREVISTO EN TIEMPO REAL] <<<");
                System.out.println("¡El sendero " + nombres[actual] + " -> " + nombres[siguiente] + " se ha CERRADO por mantenimiento!");
                System.out.println("> Regla Logica [Si un camino se cierra]: Buscando ruta alternativa inmediatamente...");
                
                // Bloqueamos el camino en la matriz (peso infinito)
                matriz[actual][siguiente] = -1.0;
                matriz[siguiente][actual] = -1.0;
                eventoForzado = true;
                numRecalculos++;
                
                // Recalculamos
                ArrayList<Integer> rutaAlternativa = calcularRutaDijkstra(matriz, actual, destino, congestion);
                if (rutaAlternativa.isEmpty()) {
                    System.out.println("[RESULTADO] No se encontraron rutas alternativas viables. Estudiante atrapado.");
                    break;
                }
                
                // Justificacion en Texto
                System.out.println(">> JUSTIFICACION: Se recalculo la ruta debido al cierre del tramo. Se selecciono una alternativa optimizando la distancia y tiempo desde su posicion actual.");
                
                // Actualizamos el siguiente nodo tras el recalculo
                siguiente = rutaAlternativa.get(1);
                distTramo = matriz[actual][siguiente];
            }
            
            // Avanzar en la simulacion
            double tiempoTramoSeg = distTramo / velocidad;
            if (congestion[siguiente]) {
                tiempoTramoSeg *= 1.2; // 20% penalizacion por congestion
            }
            
            System.out.println("\n[" + nombres[actual] + "] ===> [" + nombres[siguiente] + "]");
            System.out.println("  * Indicacion : " + obtenerIndicaciones(actual * 10 + siguiente));
            System.out.println("  * Distancia  : " + Math.round(distTramo) + " metros");
            
            // Calculo de ETA y tiempo restante del plan actual (Sumatoria de los tramos restantes en la ruta planificada)
            double distRestanteRuta = 0;
            for(int i = 1; i < ruta.size() - 1; i++) {
                distRestanteRuta += matriz[ruta.get(i)][ruta.get(i+1)];
            }
            double etaRestanteSeg = distRestanteRuta / velocidad;
            double tiempoOcupadoMin = (tiempoTotalViaje + tiempoTramoSeg) / 60.0;
            double etaTotalFuturoMin = tiempoOcupadoMin + (etaRestanteSeg / 60.0);
            
            System.out.println("  * ETA (Tiempo Restante en viaje): " + (int)(etaRestanteSeg / 60) + " min " + (int)(etaRestanteSeg % 60) + " seg");
            
            // LOGICA PROPOSICIONAL: Alerta de retraso
            if (etaTotalFuturoMin > minutosLimite) {
                System.out.println("  >>> [ALERTA DE RETRASO] <<<");
                System.out.println("  > Regla Logica: El ETA total proyectado (" + Math.round(etaTotalFuturoMin) + " min) supera su limite (" + minutosLimite + " min).");
                System.out.println("  > Justificacion: Se sugiere justificar su atraso ante el docente, esta via generara demora.");
                numAlertas++;
            }
            
            // Construccion de Expresion Matematica (d1 + d2 + ...)
            if (expresionMatematica.isEmpty()) {
                expresionMatematica = Math.round(distTramo) + "m";
            } else {
                expresionMatematica += " + " + Math.round(distTramo) + "m";
            }
            
            // Acumuladores
            distanciaTotalRecorrida += distTramo;
            tiempoTotalViaje += tiempoTramoSeg;
            actual = siguiente;
            
            // Actualizar estadisticas
            historialNodos.add(nombres[actual]);
            visitas[actual]++;
            
            // Delay visual para la simulacion (1 segundo)
            try { Thread.sleep(1000); } catch (InterruptedException e) {}
        }
        
        // REPORTE FINAL ESTADISTICO Y MATEMATICO
        if (actual == destino) {
            generarReporteFinal(distanciaTotalRecorrida, expresionMatematica, velocidad);
        }
    }
    
    public static void generarReporteFinal(double distanciaTotal, String expresionMatematica, double velocidad) {
        System.out.println("\n=========================================================");
        System.out.println("       REPORTE DE SIMULACION Y ANALISIS MATEMATICO       ");
        System.out.println("=========================================================");
        
        System.out.println("\n[1] EXPRESION ALGEBRAICA DE LA RUTA:");
        System.out.println("    Sumatoria (D_total) = d_1 + d_2 + ... + d_n");
        System.out.println("    D_total = " + expresionMatematica + " = " + Math.round(distanciaTotal) + " metros");
        double distKm = distanciaTotal / 1000.0;
        System.out.println("    Conversion a Kilometros: " + String.format("%.3f", distKm) + " Km");
        
        System.out.println("\n[2] CALCULO DE VELOCIDAD PROMEDIO:");
        System.out.println("    Formula: V = D_total / T_total");
        double tiempoTotalMin = tiempoTotalViaje / 60.0;
        double velocidadPromedioReal = distanciaTotal / tiempoTotalViaje; // m/s real incluyendo penalizaciones
        System.out.println("    V = " + Math.round(distanciaTotal) + "m / " + Math.round(tiempoTotalViaje) + "s");
        System.out.println("    Velocidad Promedio Efectiva: " + String.format("%.2f", velocidadPromedioReal) + " m/s");
        
        System.out.println("\n[3] ESTADISTICAS AVANZADAS DE LA SIMULACION:");
        System.out.print("    - Historial de Nodos: ");
        for (int i = 0; i < historialNodos.size(); i++) {
            System.out.print(historialNodos.get(i));
            if(i < historialNodos.size() - 1) System.out.print(" -> ");
        }
        System.out.println("\n    - Tiempo total empleado: " + (int)tiempoTotalMin + " min y " + (int)(tiempoTotalViaje % 60) + " seg");
        System.out.println("    - Imprevistos / Recalculos de ruta ocurridos: " + numRecalculos);
        System.out.println("    - Alertas de retraso emitidas: " + numAlertas);
        
        // Calcular lugar mas visitado
        int maxVisitas = 0;
        String lugarMasVisitado = "";
        for (int i=0; i<6; i++) {
            if (visitas[i] > maxVisitas) {
                maxVisitas = visitas[i];
                lugarMasVisitado = "[" + i + "]"; // Simplified
            }
        }
        System.out.println("    - Nodo con mayor concurrencia: Nodo " + lugarMasVisitado + " (Visitado " + maxVisitas + " veces)");
        System.out.println("=========================================================\n");
    }
}
