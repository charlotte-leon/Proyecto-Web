package navegacioncampusutmach.navegacioncampusutmach;

import java.util.Scanner;
import java.util.ArrayList;
import java.util.List;

public class NavegacionCampusUTMACH {
    static Scanner scanner = new Scanner(System.in);
    static final double INFINITO = 99999.0;
    static final double VELOCIDAD_M_S = 1.4; // metros por segundo
    
    // Almacena las filas de la tabla de verdad de la ultima simulacion
    static List<String[]> historialTablaVerdad = new ArrayList<>();

    public static void main(String[] args) {
        int opcion;

        String[] nombres = new String[6];
        int[] coordX = new int[6];
        int[] coordY = new int[6];
        boolean[] congestion = new boolean[6];
        double[][] matriz = new double[6][6];
        int[] horariosLimite = new int[6];

        inicializarCampus(nombres, coordX, coordY, congestion, matriz, horariosLimite);

        do {
            System.out.println("");
            System.out.println("========================================================");
            System.out.println("   SISTEMA DE NAVEGACION UNIVERSITARIA - UTMACH");
            System.out.println("========================================================");
            System.out.println("  1. Iniciar Navegacion Dinamica (Simulacion)");
            System.out.println("  2. Visualizar Mapa de Grafos del Campus");
            System.out.println("  3. Mostrar matriz de adyacencia (Grafo)");
            System.out.println("  4. Consultar plano de coordenadas cartesianas");
            System.out.println("  5. Registrar horario limite por facultad (minutos)");
            System.out.println("  6. Mostrar reporte de decisiones logicas (Tabla de Verdad)");
            System.out.println("  7. Salir");
            System.out.print("Seleccione opcion (1-7): ");
            
            opcion = scanner.nextInt();

            switch (opcion) {
                case 1:
                    prepararSimulacion(matriz, congestion, nombres, horariosLimite);
                    break;
                case 2:
                    mostrarMapaGrafo();
                    break;
                case 3:
                    System.out.println("");
                    System.out.println("--- MATRIZ DE ADYACENCIA ---");
                    for (int i = 0; i <= 5; i++) {
                        System.out.printf("[%d] -> %6.1f | %6.1f | %6.1f | %6.1f | %6.1f | %6.1f\n", 
                                i, matriz[i][0], matriz[i][1], matriz[i][2], matriz[i][3], matriz[i][4], matriz[i][5]);
                    }
                    break;
                case 4:
                    System.out.println("");
                    System.out.println("--- COORDENADAS REGISTRADAS ---");
                    for (int i = 0; i <= 5; i++) {
                        System.out.println(" [" + i + "] " + nombres[i] + " -> X: " + coordX[i] + "m | Y: " + coordY[i] + "m");
                    }
                    break;
                case 5:
                    registrarHorarios(nombres, horariosLimite);
                    break;
                case 6:
                    mostrarTablaVerdad();
                    break;
                case 7:
                    System.out.println("Finalizando el motor de busqueda. ¡Exitos en sus estudios!");
                    break;
                default:
                    System.out.println("Opcion incorrecta. Intente de nuevo.");
            }
        } while (opcion != 7);
    }

    public static void registrarHorarios(String[] nombres, int[] horariosLimite) {
        System.out.println("\n--- REGISTRO DE HORARIOS LIMITE ---");
        int seleccion = -1;
        do {
            System.out.println("\nSeleccione la facultad a modificar:");
            for (int i = 0; i < 6; i++) {
                System.out.println("[" + i + "] " + nombres[i] + " (Actual: " + (horariosLimite[i] == 9999 ? "Sin limite" : horariosLimite[i] + " min") + ")");
            }
            System.out.println("[6] Finalizar registro");
            System.out.print("Opcion: ");
            seleccion = scanner.nextInt();
            
            switch (seleccion) {
                case 0:
                case 1:
                case 2:
                case 3:
                case 4:
                case 5:
                    System.out.print("Ingrese los minutos maximos para " + nombres[seleccion] + " (0 para eliminar limite): ");
                    int tiempo = scanner.nextInt();
                    if (tiempo <= 0) {
                        horariosLimite[seleccion] = 9999; // 9999 internamente significa sin limite
                        System.out.println("Límite eliminado.");
                    } else {
                        horariosLimite[seleccion] = tiempo;
                        System.out.println("Horario actualizado.");
                    }
                    break;
                case 6:
                    System.out.println("Registro de horarios finalizado.");
                    break;
                default:
                    System.out.println("Opcion invalida. Intente de nuevo.");
            }
        } while (seleccion != 6);
    }

    public static void mostrarTablaVerdad() {
        System.out.println("\n==================================================================================================");
        System.out.println("                        REPORTE MATRICIAL DE DECISIONES (TABLA DE VERDAD)");
        System.out.println("==================================================================================================");
        if (historialTablaVerdad.isEmpty()) {
            System.out.println("No hay datos registrados. Realice una simulacion de navegacion primero.");
        } else {
            System.out.printf("%-20s | %-12s | %-12s | %-15s | %-20s\n", "TRAMO (A -> B)", "MAS CORTO(p)", "ABIERTO(q)", "MENOR CONG.(r)", "DECISION (p ^ q)");
            System.out.println("--------------------------------------------------------------------------------------------------");
            for (String[] fila : historialTablaVerdad) {
                System.out.printf("%-20s | %-12s | %-12s | %-15s | %-20s\n", fila[0], fila[1], fila[2], fila[3], fila[4]);
            }
        }
        System.out.println("==================================================================================================\n");
    }

    public static void conectar(double[][] matriz, int[] coordX, int[] coordY, int n1, int n2) {
        double dist;
        dist = Math.sqrt(Math.pow(coordX[n2] - coordX[n1], 2) + Math.pow(coordY[n2] - coordY[n1], 2));
        matriz[n1][n2] = dist;
        matriz[n2][n1] = dist;
    }

    public static void inicializarCampus(String[] nombres, int[] coordX, int[] coordY, boolean[] congestion, double[][] matriz, int[] horariosLimite) {
        nombres[0] = "Entrada Principal"; coordX[0] = 0; coordY[0] = 0; congestion[0] = false;
        nombres[1] = "Fac. Ingenieria Civil (FIC)"; coordX[1] = 120; coordY[1] = 80; congestion[1] = false;
        nombres[2] = "Fac. Ciencias Medicas y de la Salud"; coordX[2] = 250; coordY[2] = 180; congestion[2] = true;
        nombres[3] = "Fac. Ciencias Empresariales (FCE)"; coordX[3] = 80; coordY[3] = 220; congestion[3] = true;
        nombres[4] = "Fac. Ciencias Sociales (FCS)"; coordX[4] = 300; coordY[4] = 60; congestion[4] = false;
        nombres[5] = "Centro de la Facultad (Rectorado)"; coordX[5] = 160; coordY[5] = 140; congestion[5] = false;

        for (int i = 0; i < 6; i++) {
            horariosLimite[i] = 9999; // 9999 indica sin limite por defecto
            for (int j = 0; j < 6; j++) {
                if (i == j) {
                    matriz[i][j] = 0.0;
                } else {
                    matriz[i][j] = -1.0;
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

    public static void mostrarMapaGrafo() {
        System.out.println("\n========================================================");
        System.out.println("            MAPA DEL CAMPUS UTMACH (GRAFOS)             ");
        System.out.println("========================================================");
        System.out.println("                                                            ");
        System.out.println("  [3] FCE ----------------------- [2] Medicas               ");
        System.out.println("   |  \\                           /  |                      ");
        System.out.println("   |   \\                         /   |                      ");
        System.out.println("   |    \\                       /    |                      ");
        System.out.println("   |     \\                     /     |                      ");
        System.out.println("   |      \\                   /      |                      ");
        System.out.println("   |       \\                 /       |                      ");
        System.out.println("   |        --[5] Rectorado--        |                      ");
        System.out.println("   |         /      |        \\       |                      ");
        System.out.println("   |        /       |         \\      |                      ");
        System.out.println("   |       /        |          \\     |                      ");
        System.out.println("   |      /         |           \\    |                      ");
        System.out.println("   |     /          |            \\   |                      ");
        System.out.println(" [0] Entrada --- [1] FIC ------ [4] FCS                     ");
        System.out.println("                                                            ");
        System.out.println("========================================================\n");
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
            default:
                indicaciones = "Siga por la calzada peatonal del campus";
        }
        return indicaciones;
    }

    // Clase auxiliar para devolver la ruta y distancia
    static class ResultadoRuta {
        List<Integer> camino = new ArrayList<>();
        double distanciaTotal = INFINITO;
        String logDecisiones = "";
        boolean huboDesempateCongestion = false;
    }

    public static ResultadoRuta calcularRutaDijkstra(double[][] matriz, boolean[] congestion, int origen, int destino) {
        int nMax = 6;
        double[] distancias = new double[nMax];
        int[] previo = new int[nMax];
        int[] visitado = new int[nMax];
        ResultadoRuta resultado = new ResultadoRuta();

        for (int k = 0; k < nMax; k++) {
            distancias[k] = INFINITO;
            previo[k] = -1;
            visitado[k] = 0;
        }
        distancias[origen] = 0.0;

        for (int cont = 0; cont < nMax; cont++) {
            double minD = INFINITO;
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
                        if (nuevaDistancia < distancias[v]) {
                            distancias[v] = nuevaDistancia;
                            previo[v] = u;
                        } else if (nuevaDistancia == distancias[v] && distancias[v] != INFINITO) {
                            // Regla logica proposicional: Rutas misma distancia -> menor tiempo/congestion
                            double penalizacionV = congestion[v] ? 1.2 : 1.0;
                            double penalizacionActual = congestion[previo[v]] ? 1.2 : 1.0;
                            if (penalizacionV < penalizacionActual) {
                                previo[v] = u;
                                resultado.huboDesempateCongestion = true;
                                resultado.logDecisiones += "Se detectó empate de distancias hacia el nodo " + v 
                                    + ". Se seleccionó la ruta alternativa proveniente del nodo " + u 
                                    + " por ser más rápida (menor congestión).\n";
                            }
                        }
                    }
                }
            }
        }

        resultado.distanciaTotal = distancias[destino];
        if (resultado.distanciaTotal < INFINITO) {
            int paso = destino;
            List<Integer> rutaInversa = new ArrayList<>();
            while (paso != -1) {
                rutaInversa.add(paso);
                paso = previo[paso];
            }
            // Invertir para tener desde el origen al destino
            for (int i = rutaInversa.size() - 1; i >= 0; i--) {
                resultado.camino.add(rutaInversa.get(i));
            }
        }

        return resultado;
    }

    public static void prepararSimulacion(double[][] matrizOriginal, boolean[] congestion, String[] nombres, int[] horariosLimite) {
        int origen, destino;
        int nMax = 6;
        int tiempoDisponibleMinutos;

        do {
            System.out.println("\n=== ORIGEN ===");
            for (int k = 0; k < nMax; k++) {
                System.out.println("[" + k + "] " + nombres[k]);
            }
            System.out.print("Seleccione su ubicacion actual (0-5): ");
            origen = scanner.nextInt();
        } while (!(origen >= 0 && origen < nMax));

        do {
            System.out.print("Seleccione su destino (1-5, diferente al origen): ");
            destino = scanner.nextInt();
        } while (!(destino >= 0 && destino < nMax && origen != destino));

        System.out.print("Ingrese el tiempo personal del que dispone para este recorrido (en minutos): ");
        tiempoDisponibleMinutos = scanner.nextInt();

        // Copiamos la matriz para no afectar la original durante la simulacion de bloqueos
        double[][] matrizSimulacion = new double[nMax][nMax];
        for (int i = 0; i < nMax; i++) {
            System.arraycopy(matrizOriginal[i], 0, matrizSimulacion[i], 0, nMax);
        }

        simularNavegacion(matrizSimulacion, congestion, nombres, origen, destino, tiempoDisponibleMinutos, horariosLimite);
    }

    public static void simularNavegacion(double[][] matriz, boolean[] congestion, String[] nombres, int origenIncial, int destino, int tiempoDisponibleMinutos, int[] horariosLimite) {
        int tiempoLimiteSegundos = tiempoDisponibleMinutos * 60;
        int tiempoLimiteFacultadSeg = horariosLimite[destino] * 60;
        
        int tiempoConsumidoSegundos = 0;
        double distanciaTotalRecorrida = 0;
        int contadorRecalculos = 0;
        int alertasGeneradas = 0;
        List<Integer> historialNodos = new ArrayList<>();
        
        historialTablaVerdad.clear(); // Limpiamos la tabla de verdad para la nueva simulacion
        
        historialNodos.add(origenIncial);
        int nodoActual = origenIncial;
        
        System.out.println("\n=========================================================");
        System.out.println("        INICIANDO SIMULACION DINAMICA DE RUTA");
        System.out.println("=========================================================");

        ResultadoRuta rutaOriginal = calcularRutaDijkstra(matriz, congestion, origenIncial, destino);
        if (rutaOriginal.distanciaTotal == INFINITO) {
            System.out.println("Error: No existe una ruta conexa hacia el destino desde el inicio.");
            return;
        }

        boolean llegoDestino = false;
        
        while (!llegoDestino) {
            ResultadoRuta rutaOptima = calcularRutaDijkstra(matriz, congestion, nodoActual, destino);
            
            if (rutaOptima.distanciaTotal == INFINITO) {
                System.out.println("¡ALERTA CRITICA! Debido a los cierres, se ha bloqueado por completo el acceso al destino.");
                break;
            }

            if (!rutaOptima.logDecisiones.isEmpty()) {
                System.out.println("[SISTEMA] " + rutaOptima.logDecisiones);
            }

            int siguienteNodo = rutaOptima.camino.get(1);
            double distanciaTramo = matriz[nodoActual][siguienteNodo];
            
            // Calculo de ETA
            double tiempoRestanteSegundos = rutaOptima.distanciaTotal / VELOCIDAD_M_S;
            if (congestion[destino]) {
                tiempoRestanteSegundos *= 1.20; // 20% mas si hay congestion
            }
            int etaTotal = tiempoConsumidoSegundos + (int)tiempoRestanteSegundos;

            System.out.println("\n--- ESTADO ACTUAL ---");
            System.out.println("Ubicacion: " + nombres[nodoActual]);
            System.out.println("Proximo destino: " + nombres[siguienteNodo] + " (" + Math.round(distanciaTramo) + " m)");
            System.out.println("Indicacion: " + obtenerIndicaciones(nodoActual * 10 + siguienteNodo));
            System.out.printf("ETA Restante: %d min y %d seg\n", (int)(tiempoRestanteSegundos/60), (int)(tiempoRestanteSegundos%60));
            
            // Alertas por tiempo global o cierre de facultad
            boolean hayAlerta = false;
            if (etaTotal > tiempoLimiteSegundos) {
                System.out.println(">> ¡ALERTA DE RETRASO PERSONAL! El tiempo estimado total superará su tiempo disponible personal.");
                hayAlerta = true;
            }
            if (horariosLimite[destino] != 9999 && etaTotal > tiempoLimiteFacultadSeg) {
                System.out.println(">> ¡ALERTA DE CIERRE! El tiempo estimado (" + (etaTotal/60) + " min) excede el horario de ingreso a " + nombres[destino] + " (" + horariosLimite[destino] + " min).");
                hayAlerta = true;
            }
            
            if (hayAlerta) {
                alertasGeneradas++;
                System.out.println(">> Sugerencia: Acelere el paso, considere alternativas o notifique su retraso.");
            }

            System.out.print("\n¿Se encuentra abierto el tramo hacia " + nombres[siguienteNodo] + "? (s/n): ");
            String respuesta = scanner.next().trim().toLowerCase();

            // Guardamos valores para la tabla de verdad
            String lblTramo = nodoActual + " -> " + siguienteNodo;
            String valP = "V"; // Siempre V porque Dijkstra nos dio el mas corto
            String valR = rutaOptima.huboDesempateCongestion ? "V" : "N/A";
            
            if (respuesta.equals("s")) {
                historialTablaVerdad.add(new String[]{lblTramo, valP, "V", valR, "Avanzar (Seleccionada)"});
                
                double tiempoTramo = distanciaTramo / VELOCIDAD_M_S;
                tiempoConsumidoSegundos += tiempoTramo;
                distanciaTotalRecorrida += distanciaTramo;
                nodoActual = siguienteNodo;
                historialNodos.add(nodoActual);

                if (nodoActual == destino) {
                    llegoDestino = true;
                    System.out.println("\n¡Ha llegado a su destino exitosamente!");
                }
            } else if (respuesta.equals("n")) {
                historialTablaVerdad.add(new String[]{lblTramo, valP, "F", valR, "Bloqueo (Ruta Alternativa)"});
                
                matriz[nodoActual][siguienteNodo] = -1.0;
                matriz[siguienteNodo][nodoActual] = -1.0; 
                contadorRecalculos++;
                System.out.println("\n[JUSTIFICACION] Se bloqueó la vía. Se recalculó la ruta debido al cierre del tramo " + nombres[nodoActual] + " - " + nombres[siguienteNodo] + "; se buscará una ruta alternativa por optimización de tiempo.");
            } else {
                System.out.println("Opción no válida. Asumiendo que el camino está abierto.");
                historialTablaVerdad.add(new String[]{lblTramo, valP, "V", valR, "Avanzar (Default)"});
            }
        }

        if (llegoDestino) {
            generarReporteFinal(nombres, rutaOriginal, distanciaTotalRecorrida, tiempoConsumidoSegundos, historialNodos, contadorRecalculos, alertasGeneradas);
        }
    }

    public static void generarReporteFinal(String[] nombres, ResultadoRuta rutaOriginal, double distanciaRecorrida, int tiempoConsumido, List<Integer> historial, int recalculos, int alertas) {
        System.out.println("\n=========================================================");
        System.out.println("    REPORTE MATEMATICO Y ESTADISTICAS DE LA SIMULACION");
        System.out.println("=========================================================");
        
        System.out.println("\n[ ESTADISTICAS DEL VIAJE ]");
        System.out.print("Historial de nodos visitados: ");
        for (int i = 0; i < historial.size(); i++) {
            System.out.print(nombres[historial.get(i)]);
            if (i < historial.size() - 1) System.out.print(" -> ");
        }
        System.out.println("\nRecálculos de ruta realizados: " + recalculos);
        System.out.println("Alertas de retraso generadas: " + alertas);
        
        double velocidadPromedio = (tiempoConsumido > 0) ? (distanciaRecorrida / tiempoConsumido) : 0;
        System.out.printf("Velocidad promedio empleada: %.2f m/s\n", velocidadPromedio);
        System.out.printf("Tiempo total empleado: %d minutos y %d segundos\n", (tiempoConsumido/60), (tiempoConsumido%60));

        System.out.println("\n[ REPORTE MATEMATICO - COMPARATIVA DE RUTAS ]");
        double distOriginalKm = rutaOriginal.distanciaTotal / 1000.0;
        double distRecorridaKm = distanciaRecorrida / 1000.0;

        System.out.println("Ruta Inicial Planificada (Óptima):");
        System.out.printf(" - Distancia: %.2f metros (%.3f km)\n", rutaOriginal.distanciaTotal, distOriginalKm);
        
        if (recalculos > 0) {
            System.out.println("\nRuta Final Tomada (Debido a Imprevistos):");
            System.out.printf(" - Distancia: %.2f metros (%.3f km)\n", distanciaRecorrida, distRecorridaKm);
            double diferencia = distanciaRecorrida - rutaOriginal.distanciaTotal;
            System.out.printf(" - Impacto de desvíos: +%.2f metros extra recorridos.\n", diferencia);
        } else {
            System.out.println("\nEl trayecto se completó siguiendo la ruta original sin desvíos.");
        }
        System.out.println("\nTip: Puede consultar la matriz de decisiones lógicas desde el menú principal.");
        System.out.println("=========================================================");
    }
}
