// importing OSC and NET utilities //<>// //<>//
import oscP5.*;
import netP5.*;

OscP5 oscP5;
Partial[] p1;
Partial[] p2;

PShader blur;
PShader contrast;
PShader sharp;
PShader hsv;

int part1;
int part2;

float x1, x2;
float sharp1, sharp2;
float scl = 1.0;
float scl2 = 1.0;
float speed = 0.01;
int midiTotal;
int section = 1;

float slowScl = 0.0;
float move = 0.0;
float strokeWeight, strokeWeight2;
float minDist, maxDist, rot;

int num = 14;
color[] col1 = new color[num];
float[] dist1 = new float[num];
int[] dir1 = new int[num];
float[] pos1 = new float[num];

color[] col2 = new color[num];
float[] dist2 = new float[num];
int[] dir2 = new int[num];
float[] pos2 = new float[num];

int[] midiNum1 = {67, 65, 70, 68, 73, 72, 77, 75, 80, 78};
int[] midiNum2 = {58, 61, 63, 65, 70, 72, 67, 75, 66, 0};
int[] midiNum2b = {54, 51, 49, 48, 53, 44, 46, 55, 58, 0};


PImage noise;

void setup() {
  noCursor();

  blur = loadShader("blur.glsl");
  sharp = loadShader("sharp.glsl");
  contrast = loadShader("contrast.glsl");

  strokeWeight = 1;
  strokeWeight2 = 1;

  sharp1 = 0.5;
  sharp2 = 0.95;

  strokeWeight(strokeWeight);
  strokeCap(PROJECT);
  colorMode(HSB, 360);
  background(0);
  size(displayWidth, displayHeight, P2D);
  maxDist = width/1.5;
  minDist = width/100.0;

  blur.set("scale_factor", 1.3);

  sharp.set("resolution", float(width), float(height));
  sharp.set("mouse", 1.0, 1.0);

  contrast.set("resolution", float(width), float(height));
  contrast.set("contrast", 1.3);


  /*noise = createImage(width, height, HSB);
   noise.loadPixels();
   for (int i = 0; i < noise.pixels.length; i++) {
   noise.pixels[i] = color(0, 0, random(0, 360));
   }
   noise.filter(BLUR);
   noise.updatePixels();
   */

  p1 = new Partial[num];
  p2 = new Partial[num];
  for (int i = 0; i < num; i++) {
    p1[i] = new Partial(i, num);
    p2[i] = new Partial(i, num);
  }

  // OSC address
  oscP5 = new OscP5(this, 12001);
}

void draw() {

  noStroke();
  fill(0, 0, 0, 150);
  rect(0, 0, width, height);

  pushMatrix();
  translate(width/2.0, height/2.0);
  rot = (rot + speed) % TWO_PI;
  rotate(rot);
  if (section == 1 || section == 2) {
    sectionOneTwo();
    if (strokeWeight < width/140.0) {
      strokeWeight = strokeWeight + 0.005;
    }
  }
  if (section == 3 || section == 4) {
    if (section == 3 && strokeWeight2 < width/140.0) {
      strokeWeight2 = strokeWeight2 + 0.005;
    }
    sectionThreeFour();
  }
  if (section == 5) {
    sectionFive();
    if (speed < 1.0) {
      speed = speed + 0.0001;
    }
  }
  popMatrix();

  // blur the noise, then overlay that

  /*
  noise.loadPixels();
   for (int i = 0; i < noise.pixels.length; i++) {
   noise.pixels[i] = color(0, 0, random(0, 360));
   }
   noise.filter(BLUR);
   noise.updatePixels();
   
   //blendMode(OVERLAY);
   
   image(noise, 0, 0, width, height);
   */
  filter(blur);
  //sharp.set("mouse", float(mouseX)/width, float(mouseY)/height);
  sharp.set("mouse", sharp1, sharp2);
  println(sharp1, sharp2, section);
  filter(sharp);
  filter(contrast);
}

void sectionOneTwo() {
  if (section == 2) {
    if (x1 > -height/4) {
      x1 = x1 - 0.3;
    }
    if (x2 < height/4) {
      x2 = x2 + 0.3;
    }
    if (x1 < -height/4 && x2 > height/4) {
      section = 3;
    }
    if (sharp1 > 0.35) {
      sharp1 = sharp1 - 0.0002;
    }
  }
  for (int i = 0; i < num/2; i++) {  
    if (pos1[i] > 0) {
      pos1[i] = pos1[i] - 0.025;
    }
    if (pos2[i] > 0) {
      pos2[i] = pos2[i] - 0.025;
    }
    strokeWeight(strokeWeight); 
    stroke(col1[i]);
    p1[i].update(x1, 0, dist1[i], pos1[i], dir1[i]);
    stroke(col2[i]);
    p2[i + num/2].update(x2, 0, dist2[i], pos2[i], dir2[i]);
  }
}

void sectionThreeFour() {
  if (sharp1 > 0.25) {
    sharp1 = sharp1 - 0.00008;
  }
  int num_loops = 1;
  if (scl < 2.0 && section == 4) {
    scl = scl + 0.0005;
  }
  if (section == 4) {
    num_loops = 4;
  }
  for (int j = 0; j < num_loops; j++) {
    pushMatrix();
    if (section == 4) {
      if (j == 1) {
        scale(scl);
      }
      if (sharp1 < 0.26 && j > 1) {
        scale(slowScl * (j + 1) + 1.0);
      }
    }
    for (int i = 0; i < num; i++) {  
      if (pos1[i] > 0 && j == 0) {
        pos1[i] = pos1[i] - 0.025;
      }
      if (pos2[i] > 0 && j == 0) {
        pos2[i] = pos2[i] - 0.025;
      }
      if (i < num/2) {
        strokeWeight(strokeWeight);
      } else {
        strokeWeight(strokeWeight2);
      }
      stroke(col1[i]);
      p1[i].update(x1, 0, dist1[i], pos1[i], dir1[i]);
      stroke(col2[i]);
      p2[i].update(x2, 0, dist2[i], pos2[i], dir2[i]);
    }
    popMatrix();
  }
}

void sectionFive() {
  if (sharp1 < 0.71) {
    sharp1 = sharp1 + 0.0002;
  }
  if (scl2 < 1.0) {
    scl2 = scl2 + 0.001;
  }
  if (x1 <= 0) {
    x1 = x1 + 0.3;
  }
  if (x2 >= 0) {
    x2 = x2 - 0.3;
  }
  for (int j = 0; j < 32; j++) {
    pushMatrix();
    if (j == 1) {
      scale(scl);
    }
    if (j > 1) {
      scale(1.0/(j * scl2 + 1.0));
    }
    for (int i = 0; i < num; i++) {  
      if (pos1[i] > 0 && j == 0) {
        pos1[i] = pos1[i] - 0.015;
      }
      if (pos2[i] > 0 && j == 0) {
        pos2[i] = pos2[i] - 0.015;
      }
      if (i < num/2) {
        strokeWeight(strokeWeight);
      } else {
        strokeWeight(strokeWeight2);
      }
      stroke(col1[i]);
      p1[i].update(x1, 0, dist1[i], pos1[i], dir1[i]);
      stroke(col2[i]);
      p2[i].update(x2, 0, dist2[i], pos2[i], dir2[i]);
    }
    popMatrix();
  }
}

void oscEvent(OscMessage msg) {
  int val;
  if (msg.checkAddrPattern("/part1")) {
    midiTotal++;
    val = msg.get(0).intValue();
    if (val == 75 && section == 1) {
      section = 2;
    }
    if (val == 66 && section == 3) {
      section = 4;
    }
    if (val == 54 && section == 4) {
      section = 5;
    }
    if (section == 5 && val == 77) {
      sharp1 = random(0.0, 1.0);
      sharp2 = random(0.0, 1.0);
    }
    for (int i = 0; i < 10; i++) {
      if (val == midiNum1[i]) {
        pos1[i] = 1.0;
        dist1[i] = int(random(4, 20)) * height/40.0;
        col1[i] = color(random(270, 330), 360, 360);
        dir1[i] = int(random(0, 2));
        if (section > 2 && i < 8) {
          pos1[i + num/2] = 1.0;
          dist1[i + num/2] = int(random(4, 20)) * height/40.0;
          col1[i + num/2] = color(random(230, 290), 360, 360);
          dir1[i + num/2] = int(random(0, 2));
        }
      }
      if (val == midiNum2b[i]) {
        pos2[i] = 1.0;
        dist2[i] = int(random(4, 20)) * height/40.0;
        col2[i] = color(random(300, 360), 360, 360);
        dir2[i] = int(random(0, 2));
        if (section > 2 && i < 8) {
          pos2[i + num/2] = 1.0;
          dist2[i + num/2] = int(random(4, 20)) * height/40.0;
          col2[i + num/2] = color(random(200, 260), 360, 360);
          dir2[i + num/2] = int(random(0, 2));
        }
      }
    }
  }

  if (msg.checkAddrPattern("/part2")) {
    midiTotal++;
    val = msg.get(0).intValue();
    println(val);
    if (val == 75 && section == 1) {
      section = 2;
    }
    if (val == 66 && section == 3) {
      section = 4;
    }
    if (val == 54 && section == 4) {
      section = 5;
    }
    if (section == 5 && val == 77) {
      sharp1 = random(0.0, 1.0);
      sharp2 = random(0.0, 1.0);
    }
    for (int i = 0; i < 10; i++) {
      if (val == midiNum2[i]) {
        pos2[i] = 1.0;
        dist2[i] = int(random(4, 20)) * height/40.0;
        col2[i] = color(random(300, 360), 360, 360);
        dir2[i] = int(random(0, 2));
        if (section > 2 && i < 8) {
          pos2[i + num/2] = 1.0;
          dist2[i + num/2] = int(random(4, 20)) * height/40.0;
          col2[i + num/2] = color(random(200, 260), 360, 360);
          dir2[i + num/2] = int(random(0, 2));
        }
      }
      if (val == midiNum2b[i]) {
        pos2[i] = 1.0;
        dist2[i] = int(random(4, 20)) * height/40.0;
        col2[i] = color(random(300, 360), 360, 360);
        dir2[i] = int(random(0, 2));
        if (section > 2 && i < 8) {
          pos2[i + num/2] = 1.0;
          dist2[i + num/2] = int(random(4, 20)) * height/40.0;
          col2[i + num/2] = color(random(200, 260), 360, 360);
          dir2[i + num/2] = int(random(0, 2));
        }
      }
    }
  }
}