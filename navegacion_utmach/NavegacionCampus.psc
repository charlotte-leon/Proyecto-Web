// ======================================================================
//     SISTEMA DE NAVEGACION UNIVERSITARIA - CAMPUS UTMACH
// ======================================================================
// Prototipo de navegación que modela el campus como un grafo de 6 nodos.
// Desarrollado bajo el perfil de configuración "ESTRICTO" de PSeInt:
//   - Uso obligatorio de punto y coma (;) al final de cada sentencia.
//   - Indexación con base cero (0) para arreglos y matrices.
//   - Operadores lógicos normalizados: Y (conjunción), O (disyunción) y NO (negación).
//   - Definición explícita de todas las variables locales y de bloque.
// ======================================================================

// -----------------------------------------------------------------------
// SUBPROCESO: InicializarMatriz
// Llena la matriz de adyacencia de 6x6 con distancias peatonales reales.
// Utiliza el valor centinela -1 para indicar que no hay camino directo.
// -----------------------------------------------------------------------
SubProceso InicializarMatriz(matriz Por Referencia, coordX, coordY)
	Definir i, j Como Entero;
	Para i <- 0 Hasta 5 Hacer
		Para j <- 0 Hasta 5 Hacer
			matriz[i,j] <- -1.0;
		FinPara
	FinPara
	Para i <- 0 Hasta 5 Hacer
		matriz[i,i] <- 0.0;
	FinPara
	
	// Conexiones bidireccionales del grafo del campus (distancias calculadas dinámicamente)
	matriz[0,1] <- DistanciaEuclidiana(coordX[0], coordY[0], coordX[1], coordY[1]);
	matriz[1,0] <- matriz[0,1];
	matriz[0,3] <- DistanciaEuclidiana(coordX[0], coordY[0], coordX[3], coordY[3]);
	matriz[3,0] <- matriz[0,3];
	matriz[0,4] <- DistanciaEuclidiana(coordX[0], coordY[0], coordX[4], coordY[4]);
	matriz[4,0] <- matriz[0,4];
	matriz[0,5] <- DistanciaEuclidiana(coordX[0], coordY[0], coordX[5], coordY[5]);
	matriz[5,0] <- matriz[0,5];
	
	matriz[1,2] <- DistanciaEuclidiana(coordX[1], coordY[1], coordX[2], coordY[2]);
	matriz[2,1] <- matriz[1,2];
	matriz[1,4] <- DistanciaEuclidiana(coordX[1], coordY[1], coordX[4], coordY[4]);
	matriz[4,1] <- matriz[1,4];
	matriz[1,5] <- DistanciaEuclidiana(coordX[1], coordY[1], coordX[5], coordY[5]);
	matriz[5,1] <- matriz[1,5];
	
	matriz[2,3] <- DistanciaEuclidiana(coordX[2], coordY[2], coordX[3], coordY[3]);
	matriz[3,2] <- matriz[2,3];
	matriz[2,5] <- DistanciaEuclidiana(coordX[2], coordY[2], coordX[5], coordY[5]);
	matriz[5,2] <- matriz[2,5];
	
	matriz[3,4] <- DistanciaEuclidiana(coordX[3], coordY[3], coordX[4], coordY[4]);
	matriz[4,3] <- matriz[3,4];
	matriz[3,5] <- DistanciaEuclidiana(coordX[3], coordY[3], coordX[5], coordY[5]);
	matriz[5,3] <- matriz[3,5];
	
	matriz[4,5] <- DistanciaEuclidiana(coordX[4], coordY[4], coordX[5], coordY[5]);
	matriz[5,4] <- matriz[4,5];
FinSubProceso

// -----------------------------------------------------------------------
// SUBPROCESO: InicializarCoordenadas
// Asigna las coordenadas cartesianas (X, Y) fijas en metros.
// -----------------------------------------------------------------------
SubProceso InicializarCoordenadas(coordX Por Referencia, coordY Por Referencia)
	coordX[0] <- 0;   coordY[0] <- 0;     // Entrada Principal
	coordX[1] <- 120; coordY[1] <- 80;    // Fac. Ingeniería Civil (FIC)
	coordX[2] <- 250; coordY[2] <- 180;   // Fac. Ciencias Médicas
	coordX[3] <- 80;  coordY[3] <- 220;   // Fac. Ciencias Empresariales (FCE)
	coordX[4] <- 300; coordY[4] <- 60;    // Fac. Ciencias Sociales (FCS)
	coordX[5] <- 160; coordY[5] <- 140;   // Centro del Campus (Rectorado)
FinSubProceso

// -----------------------------------------------------------------------
// SUBPROCESO: InicializarCongestion
// Define qué ubicaciones presentan congestión (Verdadero = tráfico alto).
// -----------------------------------------------------------------------
SubProceso InicializarCongestion(congestion Por Referencia)
	congestion[0] <- Falso;      // Entrada Principal
	congestion[1] <- Falso;      // FIC
	congestion[2] <- Verdadero;  // Ciencias Médicas (zona de laboratorios y clínica)
	congestion[3] <- Verdadero;  // FCE (zona comercial / parqueaderos)
	congestion[4] <- Falso;      // FCS
	congestion[5] <- Falso;      // Centro/Rectorado
FinSubProceso

// -----------------------------------------------------------------------
// SUBPROCESO: ObtenerNombreUbicacion
// Traduce el índice numérico en el nombre completo correspondiente.
// -----------------------------------------------------------------------
SubProceso ObtenerNombreUbicacion(indice, nombre Por Referencia)
	Segun indice Hacer
		0: nombre <- "Entrada Principal";
		1: nombre <- "Fac. Ingenieria Civil (FIC)";
		2: nombre <- "Fac. Ciencias Medicas y de la Salud";
		3: nombre <- "Fac. Ciencias Empresariales (FCE)";
		4: nombre <- "Fac. Ciencias Sociales (FCS)";
		5: nombre <- "Centro de la Facultad (Rectorado)";
		De Otro Modo: nombre <- "Ubicacion desconocida";
	FinSegun
FinSubProceso

// -----------------------------------------------------------------------
// FUNCION: DistanciaEuclidiana
// Calcula la distancia analítica en línea recta mediante vectores.
// Formula: d = RC( (x2 - x1)^2 + (y2 - y1)^2 );
// -----------------------------------------------------------------------
Funcion distancia <- DistanciaEuclidiana(x1, y1, x2, y2)
	Definir distancia Como Real;
	distancia <- RC((x2 - x1) ^ 2 + (y2 - y1) ^ 2);
FinFuncion

// -----------------------------------------------------------------------
// SUBPROCESO: ObtenerIndicaciones
// Retorna las indicaciones verbales (giro y orientación) para un tramo directo.
// -----------------------------------------------------------------------
SubProceso ObtenerIndicaciones(orig, dest, indicaciones Por Referencia)
	Definir llave Como Entero;
	llave <- orig * 10 + dest;
	Segun llave Hacer
		1:  indicaciones <- "Camine hacia el noreste pasando por el jardin principal";
		10: indicaciones <- "Camine hacia el suroeste de regreso a la Entrada Principal";
		3:  indicaciones <- "Siga recto por la avenida principal hacia el norte";
		30: indicaciones <- "Siga recto por la avenida principal hacia el sur hacia la Entrada";
		4:  indicaciones <- "Gire a la derecha y camine hacia el este con direccion a la FCS";
		40: indicaciones <- "Camine hacia el oeste de regreso a la Entrada Principal";
		5:  indicaciones <- "Camine en diagonal hacia el Rectorado en el Bloque Central";
		50: indicaciones <- "Camine en diagonal hacia la Entrada Principal";
		12: indicaciones <- "Siga por el pasillo de Ingenieria hacia Ciencias Medicas";
		21: indicaciones <- "Siga por el pasillo peatonal hacia la Fac. de Ingenieria Civil";
		14: indicaciones <- "Siga el sendero peatonal hacia el sureste hacia la FCS";
		41: indicaciones <- "Siga el sendero peatonal hacia el noroeste hacia la FIC";
		15: indicaciones <- "Camine hacia el sur cruzando la plaza central hacia el Rectorado";
		51: indicaciones <- "Camine hacia el norte cruzando la plaza central hacia la FIC";
		23: indicaciones <- "Camine hacia el oeste por la vereda peatonal hacia la FCE";
		32: indicaciones <- "Camine hacia el este por la vereda peatonal hacia Ciencias Medicas";
		25: indicaciones <- "Siga hacia el suroeste con direccion al Rectorado";
		52: indicaciones <- "Siga hacia el noreste con direccion a Ciencias Medicas";
		34: indicaciones <- "Camine hacia el sureste cruzando las canchas deportivas hacia la FCS";
		43: indicaciones <- "Camine hacia el noroeste cruzando las canchas deportivas hacia la FCE";
		35: indicaciones <- "Dirijase al sureste hacia el Bloque Central";
		53: indicaciones <- "Dirijase al noroeste hacia la FCE";
		45: indicaciones <- "Camine hacia el noroeste por el pasillo central hacia el Rectorado";
		54: indicaciones <- "Camine hacia el sureste por el pasillo central hacia la FCS";
		De Otro Modo:
			indicaciones <- "Siga por la calzada peatonal de interconexion del campus";
	FinSegun
FinSubProceso

// -----------------------------------------------------------------------
// SUBPROCESO: MostrarMatrizGrafos
// Imprime en pantalla la matriz de adyacencia de manera tabular.
// -----------------------------------------------------------------------
SubProceso MostrarMatrizGrafos(matriz)
	Definir i, j Como Entero;
	Escribir "";
	Escribir "================================================================";
	Escribir "       MATRIZ DE ADYACENCIA DEL CAMPUS (metros)";
	Escribir "================================================================";
	Escribir "Indices:   [0]Entr  [1]FIC  [2]Med  [3]FCE  [4]FCS  [5]Cent";
	Escribir "----------------------------------------------------------------";
	Para i <- 0 Hasta 5 Hacer
		Escribir "[", i, "] -> ", matriz[i,0], " | ", matriz[i,1], " | ", matriz[i,2], " | ", matriz[i,3], " | ", matriz[i,4], " | ", matriz[i,5];
	FinPara
	Escribir "================================================================";
FinSubProceso

// -----------------------------------------------------------------------
// SUBPROCESO: EjecutarNavegacion
// Contiene la lógica del núcleo de navegación y generación de reportes.
// -----------------------------------------------------------------------
SubProceso EjecutarNavegacion(matriz, coordX, coordY, congestion)
	Definir origen, destino, k, nodoIntermedio Como Entero;
	Definir distEucl, distMatriz, mejorDist, distAux Como Real;
	Definir rutaDirecta, caminoDisponible, caminoCongestionado Como Logico;
	Definir velocidad, penalizacionPct, tiempoBase, tiempoTotal Como Real;
	Definir tiempoMin, tiempoSeg Como Entero;
	Definir nombreOrigen, nombreDestino, nombreIntermedio Como Caracter;
	Definir indT1, indT2, indDirecto Como Caracter;
	Definir repetirAcceso Como Logico;
	
	velocidad <- 1.4;        // Velocidad de caminata estándar: 1.4 m/s.
	penalizacionPct <- 20.0; // Penalización por congestión: +20% al tiempo.
	repetirAcceso <- Verdadero;
	
	// =============================================================
	// A. VALIDACIÓN DE ENTRADA (Control de Acceso e Índice de Origen)
	// =============================================================
	Repetir
		Escribir "";
		Escribir "--------------------------------------------------------";
		Escribir "Ingrese su ubicacion actual (Indice del 0 al 5): ";
		Escribir "  0: Entrada Principal";
		Escribir "  1: FIC | 2: Medicas | 3: FCE | 4: FCS | 5: Centro";
		Escribir "--------------------------------------------------------";
		Escribir "Ubicacion origen: ";
		Leer origen;
		
		// Condicional estricto para verificar si el índice ingresado existe en el grafo
		Si origen < 0 O origen > 5 Entonces
			Escribir "";
			Escribir "==================================================";
			Escribir "  >> ERROR: Acceso denegado: coordenada inexistente";
			Escribir "  Ingrese un indice valido del 0 al 5.";
			Escribir "==================================================";
		SiNo
			repetirAcceso <- Falso;
		FinSi
	Hasta Que NO repetirAcceso;
	
	Escribir ">> Acceso concedido al modulo de navegacion.";
	
	// =============================================================
	// B. SELECCIÓN DE DESTINO
	// =============================================================
	Repetir
		Escribir "";
		Escribir "Facultades disponibles para destino (1 al 5): ";
		Para k <- 1 Hasta 5 Hacer
			ObtenerNombreUbicacion(k, nombreDestino);
			Escribir "  ", k, ". ", nombreDestino;
		FinPara
		Escribir "Seleccione su destino (1-5): ";
		Leer destino;
		
		Si destino < 1 O destino > 5 Entonces
			Escribir "Opcion invalida. Debe ser un entero entre 1 y 5.";
		SiNo
			Si origen = destino Entonces
				Escribir "El origen y el destino no pueden ser iguales. Elija otra ubicacion.";
			FinSi
		FinSi
	Hasta Que (destino >= 1 Y destino <= 5) Y (origen <> destino);
	
	ObtenerNombreUbicacion(origen, nombreOrigen);
	ObtenerNombreUbicacion(destino, nombreDestino);
	
	// =============================================================
	// C. CÁLCULOS MATEMÁTICOS INTEGRADOS
	// =============================================================
	
	// 1. Distancia Euclidiana (Vectores - Geometría Analítica)
	distEucl <- DistanciaEuclidiana(coordX[origen], coordY[origen], coordX[destino], coordY[destino]);
	
	// 2. Ruta y Distancia Real (Teoría de Grafos)
	distMatriz <- matriz[origen, destino];
	rutaDirecta <- Verdadero;
	nodoIntermedio <- -1;
	
	// Si no hay conexión directa (-1), buscamos una ruta con un nodo intermedio (2 saltos)
	Si distMatriz = -1 Entonces
		rutaDirecta <- Falso;
		mejorDist <- 99999;
		Para k <- 0 Hasta 5 Hacer
			Si k <> origen Y k <> destino Entonces
				Si matriz[origen, k] <> -1 Y matriz[k, destino] <> -1 Entonces
					distAux <- matriz[origen, k] + matriz[k, destino];
					Si distAux < mejorDist Entonces
						mejorDist <- distAux;
						nodoIntermedio <- k;
					FinSi
				FinSi
			FinSi
		FinPara
		distMatriz <- mejorDist;
	FinSi
	
	caminoDisponible <- (distMatriz > 0 Y distMatriz < 99999);
	caminoCongestionado <- congestion[destino];
	
	// =============================================================
	// D. TOMA DE DECISIONES Y CÁLCULO DE ETA
	// =============================================================
	tiempoMin <- 0;
	tiempoSeg <- 0;
	
	Si caminoDisponible Entonces
		// Cálculo del tiempo base en segundos
		tiempoBase <- distMatriz / velocidad;
		
		// Penalización estadística según estado de congestión del destino
		Si caminoCongestionado Entonces
			tiempoTotal <- tiempoBase * (1 + penalizacionPct / 100);
		SiNo
			tiempoTotal <- tiempoBase;
		FinSi
		
		tiempoMin <- Trunc(tiempoTotal / 60);
		tiempoSeg <- Trunc(tiempoTotal - tiempoMin * 60);
	FinSi
	
	// =============================================================
	// E. REPORTE FINAL ACADÉMICO
	// =============================================================
	Escribir "";
	Escribir "========================================================================";
	Escribir "         REPORTE ACADEMICO DE NAVEGACION - CAMPUS UTMACH";
	Escribir "========================================================================";
	Escribir "1. FACULTAD DE DESTINO SELECCIONADA:";
	Escribir "   -> ", nombreDestino;
	Escribir "";
	
	Escribir "2. COORDENADAS DEL VECTOR DE ORIGEN Y DESTINO:";
	Escribir "   Origen  [", nombreOrigen, "]: (", coordX[origen], ", ", coordY[origen], ") metros.";
	Escribir "   Destino [", nombreDestino, "]: (", coordX[destino], ", ", coordY[destino], ") metros.";
	Escribir "   Vector de Desplazamiento: (", coordX[destino] - coordX[origen], ", ", coordY[destino] - coordY[origen], ") metros.";
	Escribir "";
	
	Escribir "3. DISTANCIA GEOMETRICA CALCULADA POR VECTORES (Linea Recta):";
	Escribir "   Distancia Euclidiana: ", distEucl, " metros.";
	Escribir "";
	
	Escribir "4. DISTANCIA PEATONAL REAL (Grafo del Campus):";
	Si caminoDisponible Entonces
		Si rutaDirecta Entonces
			Escribir "   Tipo de conexion: DIRECTA (Arista existente).";
			Escribir "   Distancia total calculada: ", distMatriz, " metros.";
			Escribir "";
			Escribir "F. INDICACIONES DE NAVEGACION:";
			ObtenerIndicaciones(origen, destino, indDirecto);
			Escribir "   >> INDICACION: ", indDirecto, " y continue ", distMatriz, " metros.";
		SiNo
			ObtenerNombreUbicacion(nodoIntermedio, nombreIntermedio);
			Escribir "   Tipo de conexion: INDIRECTA (Requiere nodo de paso).";
			Escribir "   Nodo intermedio optimizado: ", nombreIntermedio;
			Escribir "   Tramo 1 [", nombreOrigen, " -> ", nombreIntermedio, "]: ", matriz[origen, nodoIntermedio], " metros.";
			Escribir "   Tramo 2 [", nombreIntermedio, " -> ", nombreDestino, "]: ", matriz[nodoIntermedio, destino], " metros.";
			Escribir "   Distancia total calculada: ", distMatriz, " metros.";
			Escribir "";
			Escribir "F. INDICACIONES DE NAVEGACION:";
			ObtenerIndicaciones(origen, nodoIntermedio, indT1);
			ObtenerIndicaciones(nodoIntermedio, destino, indT2);
			Escribir "   >> INDICACION TRAMO 1: ", indT1, " y continue ", matriz[origen, nodoIntermedio], " metros.";
			Escribir "   >> INDICACION TRAMO 2: ", indT2, " y continue ", matriz[nodoIntermedio, destino], " metros.";
		FinSi
	SiNo
		Escribir "   Ruta no viable. No hay conexion directa ni via 1 nodo intermedio.";
	FinSi
	Escribir "";
	
	Escribir "5. TIEMPO ESTIMADO DE LLEGADA (ETA) Y REGLAS LOGICAS:";
	Si caminoDisponible Entonces
		Escribir "   Velocidad promedio: ", velocidad, " m/s";
		Si congestion[destino] Entonces
			Escribir "   Camino congestionado: SI (Se aplico una penalizacion de +", penalizacionPct, "% al ETA)";
		SiNo
			Escribir "   Camino congestionado: NO";
		FinSi
		Escribir "   ETA CALCULADO: ", tiempoMin, " minutos y ", tiempoSeg, " segundos.";
		Escribir "";
		
		// EVALUACIÓN DE REGLAS DE DECISIÓN CON OPERADORES LÓGICOS ESTRICTOS
		Escribir "   [REGLA DE RUTA]:";
		// SI (camino_disponible Y NO camino_congestionado)
		Si caminoDisponible Y NO caminoCongestionado Entonces
			Escribir "     >> Mensaje: Ruta optima despejada.";
		SiNo
			Escribir "     >> Mensaje: Precaucion. Ruta con trafico peatonal o indirecta.";
		FinSi
		
		Escribir "   [REGLA DE ALERTA]:";
		// SI (tiempo_estimado > 5 minutos O distancia_matriz > 300 metros)
		Si (tiempoMin >= 5) O (distMatriz > 300) Entonces
			Escribir "     >> Alerta: Posible retraso a clases, camine rapido.";
			Si tiempoMin >= 5 Entonces
				Escribir "        * Justificacion: El tiempo estimado de caminata (", tiempoMin, " min) es igual o superior a 5 minutos.";
			FinSi
			Si distMatriz > 300 Entonces
				Escribir "        * Justificacion: La distancia peatonal real (", distMatriz, " m) excede el umbral academico de 300 metros.";
			FinSi
		SiNo
			Escribir "     >> Alerta: Sin reportar. Llegara a tiempo bajo condiciones promedio.";
		FinSi
	SiNo
		Escribir "   ETA no calculable debido a la indisponibilidad de ruta.";
	FinSi
	Escribir "========================================================================";
FinSubProceso

// -----------------------------------------------------------------------
// ALGORITMO PRINCIPAL: NavegacionCampusUTMACH
// -----------------------------------------------------------------------
Algoritmo NavegacionCampusUTMACH
	Definir opcion, k Como Entero;
	Definir nombreUbicacion Como Caracter;
	
	// Estructura matricial 6x6 y arreglos de tamaño 6 (Base Cero 0..5)
	Definir matriz Como Real;
	Dimension matriz[6,6];
	
	Definir coordX, coordY Como Entero;
	Dimension coordX[6];
	Dimension coordY[6];
	
	Definir congestion Como Logico;
	Dimension congestion[6];
	
	// Inicializaciones obligatorias de las estructuras
	InicializarCoordenadas(coordX, coordY);
	InicializarMatriz(matriz, coordX, coordY);
	InicializarCongestion(congestion);
	
	// Menú de navegación interactivo
	Repetir
		Escribir "";
		Escribir "========================================================";
		Escribir "   SISTEMA DE NAVEGACION UNIVERSITARIA - UTMACH";
		Escribir "========================================================";
		Escribir "  1. Ejecutar navegacion (elegir origen y destino)";
		Escribir "  2. Mostrar matriz de adyacencia (grafo del campus)";
		Escribir "  3. Consultar coordenadas cartesianas de ubicaciones";
		Escribir "  4. Salir de la aplicacion";
		Escribir "";
		Escribir "Seleccione una opcion (1-4): ";
		Leer opcion;
		
		Segun opcion Hacer
			1:
				EjecutarNavegacion(matriz, coordX, coordY, congestion);
			2:
				MostrarMatrizGrafos(matriz);
			3:
				Escribir "";
				Escribir "========================================================";
				Escribir "    COORDENADAS REGISTRADAS EN EL PLANO CARTESIANO";
				Escribir "========================================================";
				Para k <- 0 Hasta 5 Hacer
					ObtenerNombreUbicacion(k, nombreUbicacion);
					Escribir " [Nodo ", k, "] ", nombreUbicacion, " -> X: ", coordX[k], "m, Y: ", coordY[k], "m.";
				FinPara
				Escribir "========================================================";
			4:
				Escribir "";
				Escribir "Finalizando el Sistema de Navegacion UTMACH. ¡Exito en sus clases!";
			De Otro Modo:
				Escribir "";
				Escribir "Error: Opcion incorrecta. Intente nuevamente.";
		FinSegun;
	Hasta Que opcion = 4;
FinAlgoritmo
