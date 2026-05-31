float a1 = 1, b1 = 1, c1 = 300; // Línea 1 (Roja)
float a2 = 1, b2 = -1, c2 = 100; // Línea 2 (Verde)
float a3 = 2, b3 = 1, c3 = 400; // Línea 3 (Azul)

// Variables para el control del deslizador
float sliderX;
float sliderMinX = 100;
float sliderMaxX = 500;
float sliderY = 500;

void setup() {
  size(600, 600);
  sliderX = (sliderMinX + sliderMaxX) / 2;
}

void draw() {
  background(25);
  
  //Interacción: Actualizar coeficiente C3 con el deslizador
  if (mousePressed && mouseX > sliderMinX - 10 && mouseX < sliderMaxX + 10 && mouseY > sliderY - 20 && mouseY < sliderY + 20) {
    sliderX = constrain(mouseX, sliderMinX, sliderMaxX);
  }
  c3 = map(sliderX, sliderMinX, sliderMaxX, 200, 600);
  
  float det12 = a1 * b2 - a2 * b1;
  
  float x12 = (c1 * b2 - c2 * b1) / det12;
  float y12 = (a1 * c2 - a2 * c1) / det12;
  
  float residuo3 = a3 * x12 + b3 * y12 - c3;
  
  String estadoSistema = "";
  color colorUI;
  boolean resuelto = false;

  if (abs(residuo3) < 2.0) {
    estadoSistema = "SISTEMA COMPATIBLE DETERMINADO (SCD)";
    colorUI = color(0, 255, 0); // Verde
    resuelto = true;
  } else {
    estadoSistema = "SISTEMA INCOMPATIBLE ";
    colorUI = color(255, 0, 0); // Rojo
  }
  
  strokeWeight(3);
  
  // Línea 1
  stroke(255, 50, 50, 150);
  dibujarLinea(a1, b1, c1);
  
  // Línea 2
  stroke(50, 255, 50, 150);
  dibujarLinea(a2, b2, c2);
  
  // Línea 3
  stroke(50, 50, 255, 200);
  dibujarLinea(a3, b3, c3);
  
  if (resuelto) {
    fill(0, 255, 0);
    noStroke();
    ellipse(x12, y12, 16, 16);
    
    stroke(0, 255, 0, 100);
    strokeWeight(1);
    noFill();
    ellipse(x12, y12, 30 + sin(frameCount*0.1)*10, 30 + sin(frameCount*0.1)*10);
  } else {
    fill(255, 255, 255, 150);
    noStroke();
    ellipse(x12, y12, 8, 8);
    
    float det13 = a1 * b3 - a3 * b1;
    float x13 = (c1 * b3 - c3 * b1) / det13;
    float y13 = (a1 * c3 - a3 * c1) / det13;
    ellipse(x13, y13, 8, 8);
    
    float det23 = a2 * b3 - a3 * b2;
    float x23 = (c2 * b3 - c3 * b2) / det23;
    float y23 = (a2 * c3 - a3 * c2) / det23;
    ellipse(x23, y23, 8, 8);
  }
  
  fill(40);
  noStroke();
  rect(0, 420, width, 180);

  stroke(100);
  strokeWeight(4);
  line(sliderMinX, sliderY, sliderMaxX, sliderY); 
  
  fill(colorUI);
  stroke(255);
  strokeWeight(2);
  ellipse(sliderX, sliderY, 20, 20);

  fill(200);
  textSize(13);
  textAlign(LEFT, TOP);
  text("Eq 1 (Rojo): " + int(a1) + "x + " + int(b1) + "y = " + int(c1), 30, 435);
  text("Eq 2 (Verde): " + int(a2) + "x + (" + int(b2) + ")y = " + int(c2), 30, 455);
  fill(150, 150, 255);
  text("Eq 3 (Azul): " + int(a3) + "x + " + int(b3) + "y = " + int(c3) + "  <-- ARRASTRA HACIA LOS LADOS", 30, 475);
  
  fill(colorUI);
  textSize(16);
  textAlign(CENTER, TOP);
  text(estadoSistema, width/2, 515);
  
  fill(255);
  textSize(13);
  if (resuelto) {
    text("¡HACKEO CON ÉXITO! El sistema tiene solución única", width/2, 550);
  } else {
    text("Arrastra el botón hacia la izquierda o derecha para alinear los láseres.", width/2, 550);
  }
}

void dibujarLinea(float A, float B, float C) {
  float xStart = 0;
  float yStart = (C - A * xStart) / B;
  float xEnd = width;
  float yEnd = (C - A * xEnd) / B;
  line(xStart, yStart, xEnd, yEnd);
}
