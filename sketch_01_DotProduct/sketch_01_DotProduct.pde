// Posición del guardia
float guardX, guardY;
// Vector de dirección a la que mira el guardia
float guardDirX = 1, guardDirY = 0;
// Velocidad del guardia
float speed = 2.5; 

// Radio de visión
float viewRadius = 200;

// Estado del juego
boolean gameOver = false;

void setup() {
  size(600, 400);
  guardX = width / 2;
  guardY = height / 2;
}

void draw() {
  background(220);
  
  // Game Over
  if (gameOver) {
    fill(255, 0, 0);
    textSize(40);
    textAlign(CENTER, CENTER);
    text("¡HAS MUERTO!\n(GAME OVER)", width/2, height/2);
    return; // Detener el dibujo del juego
  }
  
  float targetX = mouseX;
  float targetY = mouseY;
  
  // Vector hacia el objetivo
  float toTargetX = targetX - guardX;
  float toTargetY = targetY - guardY;
  
  float distance = sqrt((toTargetX * toTargetX) + (toTargetY * toTargetY));
  
  boolean inFront = false;
  
  if (distance > 0) {

    float normTargetX = toTargetX / distance;
    float normTargetY = toTargetY / distance;
    
    float dotProduct = (guardDirX * normTargetX) + (guardDirY * normTargetY);
    
    if (dotProduct > 0.866 && distance < viewRadius) {
      inFront = true;
    }
  }
  
  if (inFront && distance > 0) {
    // Normalizar el vector de dirección y mover al guardia
    float moveX = (toTargetX / distance) * speed;
    float moveY = (toTargetY / distance) * speed;
    
    guardX += moveX;
    guardY += moveY;
    
    guardDirX = moveX / speed;
    guardDirY = moveY / speed;
  }
  
  // Comprobar Colisión
  
  if (distance < 25) {
    gameOver = true;
  }
  
  
   // Dibujar el "abanico" de visión
  noStroke();
  if (inFront) {
    fill(255, 0, 0, 60); // Rojo semitransparente
  } else {
    fill(0, 255, 0, 60); // Verde semitransparente
  }
  

  float angle = atan2(guardDirY, guardDirX);
  arc(guardX, guardY, viewRadius * 2, viewRadius * 2, angle - PI/6, angle + PI/6);
  
  stroke(0);
  strokeWeight(2);
  line(guardX, guardY, guardX + guardDirX * 30, guardY + guardDirY * 30);
  
  fill(inFront ? color(255, 0, 0) : color(0, 255, 0)); 
  ellipse(guardX, guardY, 30, 30);
  
  fill(0, 0, 255);
  ellipse(targetX, targetY, 20, 20); // Jugador (azul)
  
  //Textos UI
  fill(0);
  textSize(16);
  textAlign(LEFT, BASELINE);
  if (inFront) {
    text("¡Te persigo! (Chasing)", 20, 30);
  } else {
    text("Patrullando... (Patrolling)", 20, 30);
  }
}
