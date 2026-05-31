float lineA = 0;
float lineB = 1;
float lineC = -500; 

float[] laneX = { 150, 250, 350, 450 };
char[] keysLeft = { 'a', 's', 'd', 'f' };
char[] keysRight = { 'h', 'j', 'k', 'l' };

// Lista dinámica para gestionar múltiples notas simultáneas
ArrayList<Note> notes = new ArrayList<Note>();

// Parámetros de juego y dificultad
int score = 0;
int lives = 5; // El jugador comienza con 5 vidas
boolean gameOver = false;

float baseSpeed = 4.0;
float currentSpeed = 4.0;
int frameCounter = 0;
int spawnInterval = 60;

String feedbackText = "¡RITMO DINÁMICO!";
color feedbackColor = color(255);
int feedbackTimer = 0;

void setup() {
  size(600, 600);
}

void draw() {
  background(15, 15, 25);
  
  //Pantalla de Game Over
  if (gameOver) {
    fill(0, 0, 0, 200);
    rect(0, 0, width, height);
    
    fill(255, 50, 50);
    textSize(50);
    textAlign(CENTER, CENTER);
    text("GAME OVER", width/2, height/2 - 40);
    
    fill(255);
    textSize(24);
    text("Puntuación Final: " + score, width/2, height/2 + 30);
    return; // Detener toda la actualización del juego
  }
  
  frameCounter++;
  
  if (score >= 2000) {
    currentSpeed = baseSpeed * 2.0; // Velocidad duplicada (+100% de velocidad)
  } else {
    currentSpeed = baseSpeed;
  }
  
  if (frameCounter >= spawnInterval) {
    frameCounter = 0;
    spawnNotesByScore();
    
    if (score < 800) {
      spawnInterval = int(random(45, 90));   
    } else if (score < 2000) {
      spawnInterval = int(random(30, 80));   
    } else if (score < 4000) {
      spawnInterval = int(random(20, 70));   
    } else {
      spawnInterval = int(random(15, 50));   
    }
  }
  
  stroke(40, 40, 60);
  strokeWeight(2);
  for (int i = 0; i < 4; i++) {
    line(laneX[i], 0, laneX[i], height);
    
    fill(100, 100, 150);
    textSize(14);
    textAlign(CENTER, TOP);
    text(String.valueOf(keysLeft[i]).toUpperCase() + "/" + String.valueOf(keysRight[i]).toUpperCase(), laneX[i], 515);
  }
  
  stroke(100, 100, 255);
  strokeWeight(4);
  float yLinea = -lineC / lineB;
  line(0, yLinea, width, yLinea);
  
  for (int i = notes.size() - 1; i >= 0; i--) {
    Note n = notes.get(i);
    n.y += currentSpeed;
    n.display();
    
    if (n.y > height + 20) {
      feedbackText = "MISS";
      feedbackColor = color(255, 50, 50);
      feedbackTimer = 30;
      
      lives--; // Restar una vida por omitir nota
      if (lives <= 0) gameOver = true;
      
      notes.remove(i);
    }
  }
  
  //UI
  fill(255);
  textSize(22);
  textAlign(LEFT, TOP);
  text("Score: " + score, 20, 20);
  
  // Mostrar las vidas restantes con texto y color dinámico
  textAlign(RIGHT, TOP);
  if (lives > 2) fill(100, 255, 100); // Verde si tiene bastante vida
  else fill(255, 100, 100);           // Rojo si está en peligro
  text("Vidas : " + lives, width - 20, 20);
  
  // Mostrar nivel de dificultad actual
  textAlign(LEFT, TOP);
  textSize(14);
  fill(150, 150, 255);
  if (score < 800) text("Fase 1: 1 nota / Variable", 20, 50);
  else if (score < 2000) text("Fase 2: 1-2 notas / Ráfagas", 20, 50);
  else if (score < 4000) text("Fase 3: 1-2 notas / ¡VELOCIDAD 2X!", 20, 50);
  else text("Fase TOTAL: 1-3 notas / ¡LOCURA!", 20, 50);
  
  // Feedback en el centro
  if (feedbackTimer > 0) {
    fill(feedbackColor);
    textSize(45);
    textAlign(CENTER, CENTER);
    text(feedbackText, width/2, height/2 - 80);
    feedbackTimer--;
  }
}

// --- 7. Lógica de Spawneo Inteligente según el Score ---
void spawnNotesByScore() {
  int maxNotasPermitidas = 1;
  
  if (score < 800) {
    maxNotasPermitidas = 1; 
  } else if (score < 4000) {
    maxNotasPermitidas = int(random(1, 3)); 
  } else {
    maxNotasPermitidas = int(random(1, 4)); 
  }
  
  boolean[] carrilOcupado = new boolean[4];
  int notasGeneradas = 0;
  
  while (notasGeneradas < maxNotasPermitidas) {
    int laneIdx = int(random(0, 4));
    if (!carrilOcupado[laneIdx]) {
      notes.add(new Note(laneIdx));
      carrilOcupado[laneIdx] = true;
      notasGeneradas++;
    }
  }
}

void keyPressed() {
  if (gameOver) return; // Desactivar controles si ya perdió
  
  char k = Character.toLowerCase(key);
  int targetLane = -1;
  
  for (int i = 0; i < 4; i++) {
    if (k == keysLeft[i] || k == keysRight[i]) {
      targetLane = i;
      break;
    }
  }
  
  if (targetLane != -1) {
    int indexAProcesar = -1;
    float minYDist = Float.MAX_VALUE;
    
    for (int i = 0; i < notes.size(); i++) {
      Note n = notes.get(i);
      if (n.lane == targetLane) {
        float dY = abs(n.y - 500); 
        if (dY < minYDist) {
          minYDist = dY;
          indexAProcesar = i;
        }
      }
    }
    
    if (indexAProcesar != -1) {
      Note notaObjetivo = notes.get(indexAProcesar);
      
      float numerador = abs(lineA * laneX[notaObjetivo.lane] + lineB * notaObjetivo.y + lineC);
      float denominador = sqrt(lineA * lineA + lineB * lineB);
      float distancia = numerador / denominador;
      
      if (distancia < 15) {
        feedbackText = "PERFECT";
        feedbackColor = color(0, 255, 100);
        score += 100;
        notes.remove(indexAProcesar);
      } else if (distancia < 35) {
        feedbackText = "GREAT";
        feedbackColor = color(255, 200, 0);
        score += 50;
        notes.remove(indexAProcesar);
      } else if (distancia < 60) {
        feedbackText = "BAD";
        feedbackColor = color(255, 120, 0);
        notes.remove(indexAProcesar);
      } else {
        feedbackText = "FALLO";
        feedbackColor = color(255, 50, 50);
        lives--; // Quitar vida por pulsar mal
        if (lives <= 0) gameOver = true;
      }
      feedbackTimer = 25;
    } else {
      feedbackText = "VACÍO";
      feedbackColor = color(255, 0, 100);
      feedbackTimer = 25;
      
      lives--; // Penalización por pulsar en vacío
      if (lives <= 0) gameOver = true;
    }
  }
}

class Note {
  int lane; 
  float y;
  float radius = 18;
  color noteColor;
  
  Note(int _lane) {
    lane = _lane;
    y = -20; 
    
    if (lane == 0) noteColor = color(255, 80, 80);     
    else if (lane == 1) noteColor = color(80, 255, 80);  
    else if (lane == 2) noteColor = color(80, 180, 255); 
    else noteColor = color(255, 220, 80);                
  }
  
  void display() {
    fill(noteColor);
    stroke(255, 180);
    strokeWeight(2);
    ellipse(laneX[lane], y, radius * 2, radius * 2);
    
    fill(255, 200);
    noStroke();
    ellipse(laneX[lane], y, radius * 0.8, radius * 0.8);
  }
}
