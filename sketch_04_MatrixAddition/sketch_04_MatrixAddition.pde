// Dimensiones de la cuadrícula (10x10)
int rows = 10;
int cols = 10;
int cellSize = 50; 

// Declaración de las 3 matrices (Mismo tamaño)
int[][] matrizA = new int[rows][cols]; // Humedad base de la tierra
int[][] matrizB = new int[rows][cols]; // Agua añadida por el jugador
int[][] matrizC = new int[rows][cols]; // Humedad Total = A + B

void setup() {
  size(500, 600);
  
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      matrizA[i][j] = int(random(0, 3));
      matrizB[i][j] = 0; // Al principio no hay agua añadida
    }
  }
}

void draw() {
  background(40);
  
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      matrizC[i][j] = matrizA[i][j] + matrizB[i][j];
    }
  }

  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      int humedad = matrizC[i][j];
      
      if (humedad == 0) fill(139, 69, 19);       // Marrón oscuro (Muy seco)
      else if (humedad == 1) fill(160, 82, 45);  // Marrón claro
      else if (humedad == 2) fill(184, 134, 11); // Tierra húmeda
      else if (humedad == 3) fill(205, 133, 63); // Tierra muy húmeda
      else fill(34, 139, 34);                    // Verde (Creció planta)
      
      stroke(50);
      strokeWeight(1);
      rect(j * cellSize, i * cellSize, cellSize, cellSize);
      
      if (humedad >= 4) {
        fill(0, 255, 0);
        noStroke();
        ellipse(j * cellSize + cellSize/2, i * cellSize + cellSize/2, 20, 20);
      }
      
      fill(255);
      textSize(14);
      textAlign(CENTER, CENTER);
      text(humedad, j * cellSize + cellSize/2, i * cellSize + cellSize/2);
    }
  }
  
  // Interfaz de Usuario
  fill(255);
  textAlign(LEFT, TOP);
  textSize(16);
  text("Haz clic para regar la tierra ", 10, rows * cellSize + 20);
  text("Las plantas crecen si la Humedad >= 4", 10, rows * cellSize + 50);
}

// Interacción: Regar la tierra
void mousePressed() {
  int col = mouseX / cellSize;
  int row = mouseY / cellSize;
  
  // Validar que el clic esté dentro de la cuadrícula
  if (row >= 0 && row < rows && col >= 0 && col < cols) {
    
    // Añadir agua al centro
    matrizB[row][col] += 2;
    
    // Añadir agua (salpicadura) a las casillas vecinas, si existen
    if (row - 1 >= 0) matrizB[row - 1][col] += 1; // Arriba
    if (row + 1 < rows) matrizB[row + 1][col] += 1; // Abajo
    if (col - 1 >= 0) matrizB[row][col - 1] += 1; // Izquierda
    if (col + 1 < cols) matrizB[row][col + 1] += 1; // Derecha
  }
}
