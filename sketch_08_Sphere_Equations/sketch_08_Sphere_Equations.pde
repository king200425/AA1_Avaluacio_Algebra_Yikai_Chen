ArrayList<Ecuacion> listaEcuaciones;
int indiceActual = 0;

float anguloRotacion = 0;
boolean evaluando = false;
int temporizadorEscaneo = 0;

void setup() {
  size(900, 600, P3D); // Usar motor 3D
  
  listaEcuaciones = new ArrayList<Ecuacion>();
  
  listaEcuaciones.add(new Ecuacion("1) x^2 + y^2 - 2x + 4y - 8 = 0", 1, 1, 0, -2, 4, 0, -8, false));
  
  listaEcuaciones.add(new Ecuacion("2) 2x^2 - 2y^2 + 2z^2 + 4x - 16 = 0", 2, -2, 2, 4, 0, 0, -16, false));
  
  listaEcuaciones.add(new Ecuacion("3) 2x^2 + 2y^2 + 2z^2 + 4x - 16 = 0", 2, 2, 2, 4, 0, 0, -16, false));

  listaEcuaciones.add(new Ecuacion("4) x^2 + 3y^2 + z^2 - 2xz - 4 = 0", 1, 3, 1, 0, 0, 0, -4, true));

  listaEcuaciones.add(new Ecuacion("5) 3x^2 + 3y^2 + 3z^2 + 6x - 12z - 3 = 0", 3, 3, 3, 6, 0, -12, -3, false));
}

void draw() {
  background(15, 20, 30);
  
  Ecuacion ecActual = listaEcuaciones.get(indiceActual);
  
  // Lógica del escáner de holograma
  if (temporizadorEscaneo > 0) {
    temporizadorEscaneo--;
    evaluando = true;
  } else {
    evaluando = false;
  }

  pushMatrix();
  translate(width * 0.7, height * 0.5, 0); // Posicionar holograma
  
  if (evaluando) {
    // Efecto de "pensando / escaneando"
    rotateX(frameCount * 0.1);
    rotateY(frameCount * 0.1);
    noFill();
    stroke(0, 255, 255, 100);
    strokeWeight(1);
    box(random(100, 150));
  } else {
    // Escaneo terminado, mostrar resultado
    rotateX(-PI/6);
    rotateY(anguloRotacion);
    anguloRotacion += 0.01;
    
    // Dibujar ejes de coordenadas XYZ
    strokeWeight(2);
    stroke(255, 50, 50); line(0,0,0, 150,0,0); // X Rojo
    stroke(50, 255, 50); line(0,0,0, 0,-150,0); // Y Verde
    stroke(50, 50, 255); line(0,0,0, 0,0,150); // Z Azul
    
    if (ecActual.esEsferaValida) {
      // Dibujar la esfera calculada
      lights(); // Encender luz para dar volumen
      directionalLight(0, 255, 255, -1, 1, -1);
      
      float escala = 40.0;
      translate(ecActual.cx * escala, -ecActual.cy * escala, ecActual.cz * escala);
      
      fill(0, 150, 255, 150); // Azul holográfico transparente
      stroke(0, 255, 255, 200);
      strokeWeight(1);
      sphereDetail(16);
      sphere(ecActual.radio * escala);
    } else {
      noFill();
      stroke(255, 50, 50, 200);
      strokeWeight(4);
      box(100 + sin(frameCount * 0.2) * 20); // Pálpito de error
    }
  }
  popMatrix();

  hint(DISABLE_DEPTH_TEST);
  camera();
  
  // Fondo del panel
  fill(25, 30, 45, 220);
  noStroke();
  rect(0, 0, width * 0.45, height);
  
  // Textos
  fill(0, 255, 255);
  textSize(22);
  textAlign(LEFT, TOP);
  text("DECODIFICADOR HOLOGRÁFICO", 20, 30);
  
  fill(255);
  textSize(16);
  text("Ecuación analizada:", 20, 80);
  
  fill(255, 255, 0);
  textSize(18);
  text(ecActual.textoOriginal, 20, 110);
  
  // Resultados del análisis matemático
  if (evaluando) {
    fill(150);
    text("Ejecutando algoritmo de Completar Cuadrados...", 20, 180);
  } else {
    fill(255);
    text("RESULTADO DEL ANÁLISIS:", 20, 180);
    
    if (ecActual.esEsferaValida) {
      fill(50, 255, 50);
      text("> ESTADO: ESFERA DETECTADA", 20, 220);
      fill(200);
      text("- Centro C(x, y, z): (" + nf(ecActual.cx,0,2) + ", " + nf(ecActual.cy,0,2) + ", " + nf(ecActual.cz,0,2) + ")", 20, 260);
      text("- Radio r: " + nf(ecActual.radio,0,2), 20, 290);
    } else {
      fill(255, 50, 50);
      text("> ESTADO: ERROR, NO ES UNA ESFERA", 20, 220);
      fill(200);
      text("- Causa: " + ecActual.mensajeError, 20, 260);
    }
  }
  
  // Instrucciones
  fill(100, 200, 255);
  textSize(14);
  text(">> Presiona ESPACIO para escanear la siguiente ecuación", 20, height - 40);
  
  hint(ENABLE_DEPTH_TEST);
}

void keyPressed() {
  if (key == ' ') {
    indiceActual++;
    if (indiceActual >= listaEcuaciones.size()) {
      indiceActual = 0;
    }
    temporizadorEscaneo = 45;
  }
}

class Ecuacion {
  String textoOriginal;
  float A, B, C, D, E, F, G;
  boolean tieneTerminosCruzados;
  
  // Resultados
  boolean esEsferaValida = false;
  float cx, cy, cz, radio;
  String mensajeError = "";
  
  Ecuacion(String _txt, float _a, float _b, float _c, float _d, float _e, float _f, float _g, boolean _cruzados) {
    textoOriginal = _txt;
    A = _a; B = _b; C = _c;
    D = _d; E = _e; F = _f; G = _g;
    tieneTerminosCruzados = _cruzados;
    
    calcularPropiedades();
  }
  
  void calcularPropiedades() {
    // 1. Regla: No puede tener términos cruzados (xy, xz, yz)
    if (tieneTerminosCruzados) {
      esEsferaValida = false;
      mensajeError = "Presencia de términos cruzados.";
      return;
    }
    
    // Coeficientes A, B, C deben existir y ser idénticos
    if (A == 0 || B == 0 || C == 0) {
      esEsferaValida = false;
      mensajeError = "Falta algún término al cuadrado (A, B o C es 0).";
      return;
    }
    
    if (A != B || A != C) {
      esEsferaValida = false;
      mensajeError = "Los coeficientes cuadráticos no son iguales.";
      return;
    }
    
    float d = D / A;
    float e = E / A;
    float f = F / A;
    float g = G / A;
    
    cx = -d / 2.0;
    cy = -e / 2.0;
    cz = -f / 2.0;
    
    float rCuadrado = (cx * cx) + (cy * cy) + (cz * cz) - g;
    
    if (rCuadrado > 0) {
      esEsferaValida = true;
      radio = sqrt(rCuadrado);
    } else {
      esEsferaValida = false;
      mensajeError = "El radio resultante es negativo o cero.";
    }
  }
}
