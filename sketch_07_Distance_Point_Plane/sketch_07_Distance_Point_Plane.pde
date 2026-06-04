
float planeA = 0;
float planeB = 0.866;
float planeC = 0.5;
float planeD = 0;

ArrayList<Meteor> meteors;
ArrayList<Particle> particles;

int score = 0;

float shieldAlpha = 120;
float cameraShake = 0;

void setup() {
  size(800, 600, P3D);
  meteors = new ArrayList<Meteor>();
  particles = new ArrayList<Particle>();
  noStroke();
}

void draw() {
  background(10, 10, 25);
  
  lights();
  directionalLight(255, 200, 200, -1, 1, -1);
  ambientLight(50, 50, 80);

  pushMatrix();
  translate(width / 2, height / 2 + 100, -200);
  
  if (cameraShake > 0.5) {
    translate(random(-cameraShake, cameraShake), random(-cameraShake, cameraShake), random(-cameraShake, cameraShake));
    cameraShake *= 0.9;
  }
  
  rotateX(-PI / 8); 
  rotateY(frameCount * 0.005); 

  // Dibujar el Escudo Protector
  pushMatrix();
  rotateX(PI / 6); 
  
  fill(100, 200, 255, shieldAlpha); 
  if (shieldAlpha > 100) shieldAlpha -= 8;
  
  stroke(0, 255, 255, shieldAlpha + 50);
  strokeWeight(2);
  box(700, 4, 700); 
  popMatrix();

  //Generador de Meteoritos
  if (frameCount % 20 == 0) {
    meteors.add(new Meteor(random(-350, 350), -800, random(-350, 350)));
  }

  //Actualizar Meteoritos
  for (int i = meteors.size() - 1; i >= 0; i--) {
    Meteor m = meteors.get(i);
    m.update();
    m.display();

    if (m.destroyed) {
      crearExplosion(m.x, m.y, m.z, m.col);
      shieldAlpha = 255;
      cameraShake = 20;
      
      meteors.remove(i);
      score += 10;
    } else if (m.y > 600) {
      meteors.remove(i); 
    }
  }
  
  for (int i = particles.size() - 1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.update();
    p.display();
    if (p.isDead()) {
      particles.remove(i);
    }
  }
  
  popMatrix();

  hint(DISABLE_DEPTH_TEST);
  camera(); 
  
  fill(255);
  textSize(24);
  textAlign(LEFT, TOP);
  text("Impactos Neutralizados: " + score, 20, 20);
  
  fill(150, 255, 150);
  textSize(14);
  text("Fórmula Activa: d = |Ax+By+Cz+D| / sqrt(A^2+B^2+C^2)", 20, 60);
  
  hint(ENABLE_DEPTH_TEST);
}

// [NUEVO] Función para crear muchas partículas cuando hay impacto
void crearExplosion(float ex, float ey, float ez, color col) {
  for (int i = 0; i < 20; i++) {
    particles.add(new Particle(ex, ey, ez, col));
  }
}

class Meteor {
  float x, y, z;
  float speed = random(6, 12);
  float radius = random(15, 25);
  boolean destroyed = false;
  color col;

  Meteor(float _x, float _y, float _z) {
    x = _x; y = _y; z = _z;
    col = color(255, random(80, 180), 30);
  }

  void update() {
    y += speed;

    float numerador = abs(planeA * x + planeB * y + planeC * z + planeD);
    float denominador = sqrt(planeA * planeA + planeB * planeB + planeC * planeC);
    
    float distancia = numerador / denominador;

    if (distancia < radius + 2.0) { 
      destroyed = true;
    }
  }

  void display() {
    pushMatrix();
    translate(x, y, z);
    noStroke();
    fill(col);
    sphereDetail(9);
    sphere(radius);
    popMatrix();
  }
}

class Particle {
  float x, y, z;
  float vx, vy, vz;
  float lifespan;
  color col;
  
  Particle(float _x, float _y, float _z, color _col) {
    x = _x; y = _y; z = _z;
    vx = random(-8, 8);
    vy = random(-10, 2);
    vz = random(-8, 8);
    lifespan = 255;
    col = _col;
  }
  
  void update() {
    x += vx;
    y += vy;
    z += vz;
    vy += 0.5;
    lifespan -= 10;
  }
  
  void display() {
    pushMatrix();
    translate(x, y, z);
    fill(red(col), green(col), blue(col), lifespan);
    noStroke();
    box(5);
    popMatrix();
  }
  
  boolean isDead() {
    return lifespan <= 0;
  }
}
