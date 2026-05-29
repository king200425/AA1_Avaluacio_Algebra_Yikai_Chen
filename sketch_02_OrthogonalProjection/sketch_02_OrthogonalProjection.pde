// Posición y velocidad del jugador
float playerX = 100;
float playerY = 500;
float playerSpeed = 4;

// Control de teclado WASD
boolean wPressed = false;
boolean aPressed = false;
boolean sPressed = false;
boolean dPressed = false;

// Puntos que definen las curvas de la pista
float[] trackX = { 100, 300, 500, 750 };
float[] trackY = { 500, 200, 400, 150 };
int numSegments = trackX.length - 1;

float trackWidth = 100;
// Radio del coche
float carRadius = 10;
float maxDeviation = (trackWidth / 2) - carRadius;

void setup() {
  size(800, 600);
}

void draw() {
  background(240); // Fondo
  
  float nextX = playerX;
  float nextY = playerY;
  
  if (wPressed) nextY -= playerSpeed;
  if (sPressed) nextY += playerSpeed;
  if (aPressed) nextX -= playerSpeed;
  if (dPressed) nextX += playerSpeed;
  
  float minLateralDist = Float.MAX_VALUE;
  float closestProjX = 0;
  float closestProjY = 0;
  float closestT = 0;
  int closestSegment = 0;
  float[] segLengths = new float[numSegments];
  float totalTrackLength = 0;
  
  for (int i = 0; i < numSegments; i++) {
    segLengths[i] = dist(trackX[i], trackY[i], trackX[i+1], trackY[i+1]);
    totalTrackLength += segLengths[i];
    
    // Vector U
    float uX = trackX[i+1] - trackX[i];
    float uY = trackY[i+1] - trackY[i];
    
    // Vector V
    float vX = nextX - trackX[i];
    float vY = nextY - trackY[i];
    
    // Proyección
    float dotProduct = (uX * vX) + (uY * vY);
    float magSqU = (uX * uX) + (uY * uY);
    
    float t = 0;
    if (magSqU > 0) t = dotProduct / magSqU;
    
    // Limitar t al segmento actual (0 a 1)
    t = constrain(t, 0.0, 1.0);
   
    float projX = trackX[i] + t * uX;
    float projY = trackY[i] + t * uY;
    
    float lateralDist = dist(nextX, nextY, projX, projY);
    
    // Encontrar el segmento más relevante para el jugador
    if (lateralDist < minLateralDist) {
      minLateralDist = lateralDist;
      closestProjX = projX;
      closestProjY = projY;
      closestT = t;
      closestSegment = i;
    }
  }
  
  if (minLateralDist <= maxDeviation) {
    playerX = nextX;
    playerY = nextY;
  } else {
    fill(255, 0, 0);
    textAlign(CENTER, TOP);
    text("¡Fuera de la pista! (Chocando contra el borde)", width/2, 60);
  }
  
  float distanceCovered = 0;
  for (int i = 0; i < closestSegment; i++) {
    distanceCovered += segLengths[i];
  }
  distanceCovered += closestT * segLengths[closestSegment];
  float totalProgress = distanceCovered / totalTrackLength;
  

  stroke(150); // Color asfalto
  strokeWeight(trackWidth);
  strokeJoin(ROUND); 
  strokeCap(PROJECT);
  noFill();
  beginShape();
  for (int i = 0; i < trackX.length; i++) {
    vertex(trackX[i], trackY[i]);
  }
  endShape();
  
  stroke(255);
  strokeWeight(2);
  beginShape();
  for (int i = 0; i < trackX.length; i++) {
    vertex(trackX[i], trackY[i]);
  }
  endShape();
  
  stroke(255, 255, 0); // Amarillo
  strokeWeight(2);
  line(playerX, playerY, closestProjX, closestProjY);
  
  noStroke();
  fill(255, 102, 0);
  ellipse(closestProjX, closestProjY, 10, 10);
  
  fill(0, 102, 255);
  ellipse(playerX, playerY, carRadius * 2, carRadius * 2);
  
  // Barra de progreso
  float barWidth = 200;
  float barHeight = 20;
  float barX = width - barWidth - 30;
  float barY = 30;
  
  fill(200);
  rect(barX, barY, barWidth, barHeight, 5); // Foando
  fill(0, 200, 100);
  rect(barX, barY, barWidth * totalProgress, barHeight, 5); // Progreso
  
  fill(0);
  textSize(14);
  textAlign(RIGHT, TOP);
  text("Progreso: " + int(totalProgress * 100) + "%", width - 30, barY + barHeight + 5);
  
  // Instrucciones
  textAlign(LEFT, TOP);
  fill(0);
  text("Usa WASD para conducir dentro de la pista", 20, 30);
}

//Captura de eventos del teclado
void keyPressed() {
  if (key == 'w' || key == 'W') wPressed = true;
  if (key == 'a' || key == 'A') aPressed = true;
  if (key == 's' || key == 'S') sPressed = true;
  if (key == 'd' || key == 'D') dPressed = true;
}

void keyReleased() {
  if (key == 'w' || key == 'W') wPressed = false;
  if (key == 'a' || key == 'A') aPressed = false;
  if (key == 's' || key == 'S') sPressed = false;
  if (key == 'd' || key == 'D') dPressed = false;
}
