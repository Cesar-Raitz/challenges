final color noId = 0xFFFFFFFF;
final int F = 1;
color currId = 0;
boolean pickerOn = false;
PGraphics pb = null;

void setupPicker() {
   pb = createGraphics(width/F, height/F, P3D);
}

void beginPicker() {
   pb.beginDraw();
   pickerOn = true;
   pb.background(noId);
}

void endPicker() {
   pb.endDraw();
   pickerOn = false;
}

void setId(int i) {
   currId = color(
      (i>>16) & 0xFF,
      (i>>8) & 0xFF,
      i & 0xFF);
}

void showPBuffer() {
   if (!pickerOn)
      image(pb,0,0);
}

PGraphics pickerBuffer() {
   return pb;
}

int pickId() {
   //if (pickerOn) return 666;
   //else return pb.get(mouseX/F, mouseY/F);
   return pb.get(mouseX/F, mouseY/F) & 0xFFFFFF;
}

@Override
void background(color c) {
   if (!pickerOn) super.background(c);
   //else pb.background(noId);
   //else pb.background(c);
}

@Override
void fill(int rgb) {
   if (!pickerOn) super.fill(rgb);
   else pb.fill(currId);
   //else pb.fill(rgb);
}

@Override
void vertex(float x, float y, float z) {
   if (!pickerOn) super.vertex(x,y,z);
   else pb.vertex(x,y,z);
}

@Override
void beginShape() {
   if (pickerOn) pb.beginShape();
   else super.beginShape();
}

@Override
void endShape(int mode) {
   if (pickerOn) pb.endShape(mode);
   else super.endShape(mode);
}

@Override
void scale(float s) {
   if (pickerOn) pb.scale(s);
   else super.scale(s);
}

@Override
void stroke(int i) {
   if (pickerOn) pb.stroke(i);
   else super.stroke(i);
}

@Override
void noStroke() {
   if (pickerOn) {
      pb.noStroke();
   }
   else super.noStroke();
}

@Override
void strokeWeight(float w) {
   if (pickerOn) pb.strokeWeight(w);
   else super.strokeWeight(w);
}

@Override
void pushMatrix() {
   if (pickerOn) pb.pushMatrix();
   else super.pushMatrix();
}

@Override
void popMatrix() {
   if (pickerOn) pb.popMatrix();
   else super.popMatrix();
}

@Override
void applyMatrix(PMatrix3D m) {
   if (pickerOn) pb.applyMatrix(m);
   else super.applyMatrix(m);
}

@Override
void translate(float x, float y, float z) {
   if (!pickerOn) super.translate(x,y,z);
   else pb.translate(x,y,z);
}

@Override
void rect(float x, float y, float w, float h) {
   if (!pickerOn) super.rect(x,y,w,h);
   else pb.rect(x,y,w,h);
}
