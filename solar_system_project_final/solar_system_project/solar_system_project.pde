// CONTROLS
// Mouse Wheel  = Zoom
// Mouse Drag   = Move camera
// W A S D      = Camera movement
// UP ARROW     = Faster time
// DOWN ARROW   = Slower time


// TEXTURES
PImage[] icons = new PImage[9];

PImage sunImg;
PImage moonImg;


// PLANET MOTION
float[] angles = new float[9];
float[] spinAngles = new float[9];


// STAR FIELD
float[] starX = new float[700];
float[] starY = new float[700];
float[] starSize = new float[700];


// TIMER
float simDays = 0;
float timeSpeed = 1.0;


// CAMERA + ZOOM
float zoom = 1.0;
float targetZoom = 1.0;

float camX = 0;
float camY = 0;

float targetCamX = 0;
float targetCamY = 0;


// REALISTIC SELF ROTATION SPEEDS
float[] realSpin = {

  0.010,   // Mercury
 -0.002,   // Venus (retrograde rotation)
  0.050,   // Earth
  0.048,   // Mars
  0.120,   // Jupiter
  0.100,   // Saturn
 -0.070,   // Uranus
  0.080,   // Neptune
 -0.008    // Pluto
};


// AXIAL TILTS
float[] axialTilt = {

  0.03,
  177,
  23.5,
  25,
  3,
  27,
  98,
  28,
  122
};


// PLANET DATA
// {OrbitX, OrbitY, OrbitSpeed,
//  PlanetSize, OrbitTilt}

float[][] physics = {

  {85, 65, 0.0479, 5, 7},      // Mercury
  {125, 95, 0.0350, 11, 3},    // Venus
  {170, 130, 0.0298, 12, 0},   // Earth
  {220, 170, 0.0241, 6, 2},    // Mars

  {310, 235, 0.0131, 42, 1},   // Jupiter
  {420, 320, 0.0097, 36, 2},   // Saturn

  {530, 400, 0.0068, 20, 1},   // Uranus
  {630, 475, 0.0054, 19, 2},   // Neptune

  {720, 545, 0.0047, 3, 17}    // Pluto
};


// PLANET NAMES
String[] names = {

  "Mercury",
  "Venus",
  "Earth",
  "Mars",
  "Jupiter",
  "Saturn",
  "Uranus",
  "Neptune",
  "Pluto"
};



// SETUP
void setup() {

  // Window size
  size(1800, 1000);

  // Window title
  surface.setTitle("NASA Solar System Simulation");

  // Stable FPS
  frameRate(60);

  // Improve rendering quality
  pixelDensity(displayDensity());

  smooth(8);

  imageMode(CENTER);

  textAlign(CENTER);


  // Generate stars
  for (int i = 0; i < 700; i++) {

    starX[i] = random(width);

    starY[i] = random(height);

    starSize[i] = random(1, 3);
  }


  // Load textures
  icons[0] = loadImage("mercury.png");
  icons[1] = loadImage("venus.png");
  icons[2] = loadImage("earth.png");
  icons[3] = loadImage("mars.png");
  icons[4] = loadImage("jupiter.png");
  icons[5] = loadImage("saturn.png");
  icons[6] = loadImage("uranus.png");
  icons[7] = loadImage("neptune.png");
  icons[8] = loadImage("pluto.png");

  moonImg = loadImage("moon.png");

  sunImg = loadImage("sun.png");
}

// MAIN DRAW LOOP
void draw() {

  // Background
  drawBackground();

  // Stars
  drawStars();

  // Simulation time
  simDays += timeSpeed;

  // Smooth camera movement
  camX = lerp(camX, targetCamX, 0.08);
  camY = lerp(camY, targetCamY, 0.08);

  // Move system to center
  translate(
    width/2 - 80 + camX,
    height/2 + camY
  );

  // Smooth zoom
  zoom = lerp(zoom, targetZoom, 0.08);
  scale(zoom);

  // Draw Sun
  drawSun();

  // Draw planets
  for (int i = 0; i < 9; i++) {
    drawOrbit(i);
    drawPlanet(i);
  }

  // Draw interface
  drawHUD();
}

// SPACE BACKGROUND
void drawBackground() {

  for (int i = 0; i < height; i++) {

    float inter =
      map(i, 0, height, 0, 1);

    stroke(
      lerpColor(
        color(1, 1, 8),
        color(0, 0, 28),
        inter
      )
    );

    line(0, i, width, i);
  }
}

// TWINKLING STARS
void drawStars() {

  noStroke();

  for (int i = 0; i < 700; i++) {

    fill(
      255,
      255,
      255,
      100 +
      sin(frameCount * 0.02 + i) * 100
    );

    ellipse(
      starX[i],
      starY[i],
      starSize[i],
      starSize[i]
    );
  }
}

// SUN
void drawSun() {
  pushMatrix();
  rotate(frameCount * 0.0015);
  noStroke();

  // Outer glow
  for (int i = 0; i < 20; i++) {
    fill(255, 120, 0, 4);
    ellipse(
      0,
      0,
      240 + i * 6,
      240 + i * 6
    );
  }

  // Solar corona
  for (int i = 0; i < 12; i++) {
    float pulse =
      sin(frameCount * 0.03 + i) * 8;
    fill(255, 180, 0, 10);
    ellipse(
      0,
      0,
      170 + i * 5 + pulse,
      170 + i * 5 + pulse
    );
  }

  // Sun rays
  strokeWeight(2);

  for (int i = 0; i < 24; i++) {
    float angle =
      TWO_PI / 24 * i +
      frameCount * 0.002;

    float rayLength =
      90 +
      sin(frameCount * 0.04 + i) * 20;

    stroke(255, 170, 0, 35);

    line(
      cos(angle) * 60,
      sin(angle) * 60,
      cos(angle) * rayLength,
      sin(angle) * rayLength
    );
  }

  noStroke();

  fill(255, 200, 0, 80);

  ellipse(0, 0, 150, 150);

  fill(255, 230, 120, 90);

  ellipse(0, 0, 125, 125);

  // Sun texture
  if (sunImg != null) {

    pushMatrix();

    rotate(frameCount * 0.002);

    tint(255, 240, 220);

    image(
      sunImg,
      0,
      0,
      120,
      120
    );

    noTint();

    popMatrix();
  }

  // Core light
  fill(255, 255, 220, 50);

  ellipse(0, 0, 55, 55);

  popMatrix();
}

// ORBITS
void drawOrbit(int i) {
  pushMatrix();
  rotate(radians(physics[i][4]));
  noFill();

  // Orbit glow
  for (int j = 0; j < 2; j++) {
    stroke(120, 160, 255, 8);
    strokeWeight(2 + j);
    ellipse(
      0,
      0,
      physics[i][0] * 2,
      physics[i][1] * 2
    );
  }

  // Main orbit
  stroke(180, 180, 220, 35);
  strokeWeight(1);
  ellipse(
    0,
    0,
    physics[i][0] * 2,
    physics[i][1] * 2
  );

  popMatrix();
}

// PLANETS
void drawPlanet(int i) {

  // Kepler-inspired orbit motion
  angles[i] +=
    physics[i][2] *
    (1.0 + 0.15 * cos(angles[i])) *
    timeSpeed;

  // Realistic self rotation
  spinAngles[i] +=
    realSpin[i] * timeSpeed;

  // Orbit position
  float x =
    cos(angles[i]) * physics[i][0];

  float y =
    sin(angles[i]) * physics[i][1];

  pushMatrix();
  rotate(radians(physics[i][4]));
  translate(x, y);

  // Planet glow
  noStroke();
  fill(255, 25);

  ellipse(
    0,
    0,
    physics[i][3] + 10,
    physics[i][3] + 10
  );

  // Planet texture
  pushMatrix();

  // Axial tilt
  rotate(radians(axialTilt[i]));

  // Self rotation
  rotate(spinAngles[i]);

  tint(235);

  if (icons[i] != null) {

    image(
      icons[i],
      0,
      0,
      physics[i][3],
      physics[i][3]
    );
  }

  noTint();

  // Uranus ring
  if (i == 6) {
    rotate(radians(-60));
    noFill();
    stroke(180, 220, 255, 70);
    strokeWeight(2);
    ellipse(0, 0, 42, 14);
    stroke(200, 240, 255, 25);
    strokeWeight(5);
    ellipse(0, 0, 50, 18);
  }

  popMatrix();

  // Earth-Moon system
  if (i == 2) {
    pushMatrix();
    rotate(simDays * 0.045);
    translate(32, 0);

    if (moonImg != null) {
      image(
        moonImg,
        0,
        0,
        3.5,
        3.5
      );
    }

    popMatrix();
  }


  // Labels
  fill(255);
  textSize(10);
  text(
    names[i],
    0,
    -physics[i][3] - 14
  );

  popMatrix();
}

// HUD
void drawHUD() {

  resetMatrix();

  noStroke();

  fill(0, 140);

  rect(20, 20, 320, 150, 20);

  fill(0, 255, 170);

  textAlign(LEFT);

  textSize(18);

  text(
    "SOLAR SYSTEM",
    40,
    50
  );

  fill(255);

  textSize(15);

  int year =
    2026 + floor(simDays / 365.25);

  int month =
    1 + floor((simDays % 365.25) / 30.44);

  int day =
    1 + floor(simDays % 30.44);

  text(
    "DATE : " +
    nf(day, 2) + "/" +
    nf(month, 2) + "/" +
    year,
    40,
    88
  );

  text(
    "SPEED : " +
    nf(timeSpeed, 1, 1),
    40,
    115
  );

  text(
    "ZOOM : " +
    nf(zoom, 1, 2),
    40,
    142
  );
}

// KEYBOARD CONTROLS
void keyPressed() {

  // Time speed
  if (keyCode == UP) {
    timeSpeed += 0.2;
  }
  if (keyCode == DOWN) {
    timeSpeed -= 0.2;
  }
  timeSpeed =
    constrain(timeSpeed, 0.1, 5);

  // Camera movement
  if (key == 'a' || key == 'A') {
    targetCamX += 120;
  }
  if (key == 'd' || key == 'D') {
    targetCamX -= 120;
  }
  if (key == 'w' || key == 'W') {
    targetCamY += 120;
  }
  if (key == 's' || key == 'S') {
    targetCamY -= 120;
  }
}

// MOUSE WHEEL ZOOM
void mouseWheel(processing.event.MouseEvent event) {
  float e = event.getCount();
  targetZoom -= e * 0.08;
  targetZoom =
    constrain(targetZoom, 0.4, 4.5);
}

// CAMERA DRAG
void mouseDragged() {
  targetCamX +=
    (mouseX - pmouseX) * 0.7;
  targetCamY +=
    (mouseY - pmouseY) * 0.7;
}
