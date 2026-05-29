// Lista de torretas y misiles
ArrayList<Turret> turrets;
ArrayList<Missile> missiles;

// Variables de tiempo
int lastTime;
float waveTimer = 0;
int wavesSurvived = 0;
boolean turretSpawnedThisWave = false;

boolean gameOver = false;
float playerRadius = 10;

void setup() {
  size(800, 600);
  turrets = new ArrayList<Turret>();
  missiles = new ArrayList<Missile>();
  
  // Crear la primera torreta en el centro superior
  turrets.add(new Turret(width / 2, 50));
  
  lastTime = millis();
}

void draw() {
  background(30, 30, 40); // Fondo oscuro
  
  if (gameOver) {
    fill(255, 0, 0);
    textSize(50);
    textAlign(CENTER, CENTER);
    text("¡HAS MUERTO!\nOleadas superadas: " + wavesSurvived, width/2, height/2);
    return; // Congelar juego
  }
  
  //Time
  float currentTime = millis();
  float dt = (currentTime - lastTime) / 1000.0;
  lastTime = (int)currentTime;
  
  // Posición del jugador
  float playerX = mouseX;
  float playerY = mouseY;
  
  //Lógica del Temporizador
  waveTimer += dt;
  
  //A los 2 segundos: Spawnea una nueva torreta
  if (waveTimer >= 2.0 && !turretSpawnedThisWave) {
    // Generar posición aleatoria lejos del jugador
    turrets.add(new Turret(random(50, width-50), random(50, height-50)));
    turretSpawnedThisWave = true;
  }
  
  //A los 3 segundos: Disparan TODAS las torretas
  if (waveTimer >= 3.0) {
    waveTimer = 0; // Reiniciar ciclo
    wavesSurvived++; // Aumentar contador de supervivencia
    turretSpawnedThisWave = false;
    
    // Cada torreta dispara un misil
    for (Turret t : turrets) {
      missiles.add(new Missile(t.x, t.y, playerX, playerY));
    }
  }
  
  //Actualizar y dibujar Misiles
  for (int i = missiles.size() - 1; i >= 0; i--) {
    Missile m = missiles.get(i);
    m.update(dt, playerX, playerY);
    m.display();
    
    // Comprobar Colisión con el jugador
    if (dist(m.x, m.y, playerX, playerY) < (m.radius + playerRadius)) {
      gameOver = true;
    }
    
    // Eliminar misiles que salen de la pantalla 
    if (m.x < -50 || m.x > width+50 || m.y < -50 || m.y > height+50) {
      missiles.remove(i);
    }
  }
  
  //Dibujar Torretas y Jugador
  for (Turret t : turrets) {
    t.display();
  }
  
  fill(0, 255, 255); // Jugador
  noStroke();
  ellipse(playerX, playerY, playerRadius * 2, playerRadius * 2);
  
  //UI Interfaz
  fill(255);
  textSize(20);
  textAlign(RIGHT, TOP);
  text("Oleadas: " + wavesSurvived, width - 20, 20);
  text("Torretas: " + turrets.size(), width - 20, 50);
  
  // Barra de recarga visual
  fill(100);
  rect(0, height - 10, width, 10);
  fill(255, 100, 100);
  rect(0, height - 10, width * (waveTimer / 3.0), 10);
}

class Turret {
  float x, y;
  Turret(float _x, float _y) {
    x = _x; y = _y;
  }
  void display() {
    fill(150);
    stroke(255);
    rectMode(CENTER);
    rect(x, y, 30, 30);
    fill(255, 0, 0);
    ellipse(x, y, 15, 15);
    rectMode(CORNER);
  }
}

class Missile {
  float x, y;
  float dirX, dirY; // Vector de dirección normalizado
  float speed = 180; // Velocidad de vuelo
  float age = 0;     // Tiempo de vida
  float radius = 6;
  
  Missile(float startX, float startY, float targetX, float targetY) {
    x = startX; y = startY;
    // Dirección inicial hacia el objetivo
    float d = dist(x, y, targetX, targetY);
    dirX = (targetX - x) / d;
    dirY = (targetY - y) / d;
  }
  
  void update(float dt, float px, float py) {
    age += dt;
    
    if (age < 2.0) {
      float vX = px - x;
      float vY = py - y;
      
      float crossZ = (dirX * vY) - (dirY * vX);
      
      float turnRate = 2.5 * dt; // Velocidad de giro
      
      float currentAngle = atan2(dirY, dirX);
      
      if (crossZ > 0) {
        currentAngle += turnRate;
      } else if (crossZ < 0) {
        currentAngle -= turnRate;
      }
      
      // Actualizar el vector de dirección
      dirX = cos(currentAngle);
      dirY = sin(currentAngle);
    }
    
    // Mover el misil
    x += dirX * speed * dt;
    y += dirY * speed * dt;
  }
  
  void display() {
    pushMatrix();
    translate(x, y);
    rotate(atan2(dirY, dirX));
    
    if (age < 2.0) {
      fill(255, 100, 0); // Naranja si está buscando
    } else {
      fill(100); // Gris si vuela recto
    }
    
    stroke(255);
    strokeWeight(1);
    beginShape();
    vertex(10, 0);
    vertex(-5, 5);
    vertex(-5, -5);
    endShape(CLOSE);
    popMatrix();
  }
}
