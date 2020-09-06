/*====================================================================
   MY Rubik's Cube attempt
   Cesar Raitz Jr.
   
   Based on the Coding Challenge #142 by Daniel Shiffman:
   https://thecodingtrain.com/CodingChallenges/142.3-rubiks-cube.html
   
   NO WARRANTIES WHATSOEVER!
====================================================================*/
// With Nicolas Clavaud's Picking library I was getting some endDraw()
// errors:
//import picking.*;
//Picker g_picker;

import peasy.*;
PeasyCam cam;

import peasy.org.apache.commons.math.geometry.*;

final int
	UPP = 0,
	DWN = 1,
	LFT = 2,
	RGT = 3,
	FRT = 4,
	BCK = 5;

color[] g_colors = {
  #FFFFFF, #FFFF00,
  #FF0000, #FF9900,
  #00FF00, #0000FF
};

color[] g_colors2 = new color[6];
boolean reSelect = false;
int currCubie = -1;
int currFace = -1;

ArrayList<Cubie> cubies;
int g_dim = 5;
int[] g_map;

boolean printPos = false;
ArrayList<Move> movePile;
Move currMove = null;

PFont myFont;
boolean shuffling = false;

//====================================================================
void setup() {
   size(460, 460, P3D);
   surface.setTitle("Rubik's Cube by CRaitz");
   cam = new PeasyCam(this, 500);
   //g_picker = new Picker(this);
   setupPicker();
   resetGame(5);
   
   colorMode(HSB);
   int index = 0;
   g_colors2 = new int[len(g_colors)];
   for (color c: g_colors) {
      float h = hue(c);
      float s = saturation(c);
      float b = brightness(c);
      g_colors[index] = color(h, s, 0.8*b);
      g_colors2[index] = color(h, s, 2*b);
      index++;
   }
   colorMode(RGB);
   
   myFont = createFont("Arial", 32);
   textFont(myFont);
   textMode(SHAPE);
   setupMenus();
}
//====================================================================
void resetGame(int dim) {
   cam.setRotations(-PI/4, 2*PI/8, -PI/5);
   if (dim < 5) cam.setDistance(500);
   else cam.setDistance(110 * dim);
   
   g_dim = dim;
   g_map = new int[g_dim];
   int[] range = new int[g_dim];
   boolean even = g_dim%2 == 0;
   for (int i = 0, x = -g_dim/2; i < g_dim; i++) {
      range[i] = i;
      g_map[i] = x++;
      if (even && x == 0) x++;
   }
   currMove = null;
   movePile = new ArrayList();
   cubies = new ArrayList();
   int index = 0;
   for (int x: range)
      for (int y: range)
         for (int z: range)
            cubies.add(new Cubie(index++,x,y,z));
   
   // Interface stuff
   reSelect = false;
   currCubie = -1;
   currFace = -1;
}
//====================================================================
ArrayList<Cubie> selectPlane(int dim, int num)
{
   ArrayList<Cubie> list = new ArrayList();
   // Pick cubies of a given plane to move
   for (Cubie c: cubies) {
      switch (dim) {
         case 0: if (c.x == num) list.add(c); break;
         case 1: if (c.y == num) list.add(c); break;
         case 2: if (c.z == num) list.add(c); break;
      }
   }
   return list;
}
//====================================================================
void mouseSelect(int num, int side)
{
   for (Cubie c: cubies) c.deselect();
   if (num < 0 || num >= len(cubies)) {
      // Deselect only
      return;
   }

   ArrayList<Cubie> px, py, pz; 
   Cubie c0 = cubies.get(num);
   if (side != FRT && side != BCK) {
      px = selectPlane(0, c0.x);
      int[] xl = {UPP, DWN, LFT, RGT};
      for (Cubie c: px) c.select(xl);
   }
   if (side != LFT && side != RGT) {
      py = selectPlane(1, c0.y);
      int[] yl = {UPP, DWN, FRT, BCK};
      for (Cubie c: py) c.select(yl);
   }
   if (side != UPP && side != DWN) {
      pz = selectPlane(2, c0.z);
      int[] zl = {LFT, RGT, FRT, BCK};
      for (Cubie c: pz) c.select(zl);
   }
   
   if (printPos) {
      print("Cubinho selecionado:", num);
      if (side == UPP) print("-UP");
      if (side == DWN) print("-DN");
      if (side == LFT) print("-LF");
      if (side == RGT) print("-RG");
      if (side == FRT) print("-FR");
      if (side == BCK) print("-BK");
      
      print("  x=", g_map[c0.x]);
      print("  y=", g_map[c0.y]);
      print("  z=", g_map[c0.z]);
      println();
   }
}
//====================================================================
int lastId = 0;
void mouseMoved()
{
   if (currMove == null && !shuffling) {
      //int id = g_picker.get(mouseX, mouseY);
      int id = pickId();
      int num = id >> 3;
      int face = id & 7;
      
      if (num >= 0 && num < len(cubies)) {
         if (num != currCubie || face != currFace) {
            //println("cubie =",num,"  face =",face);
            mouseSelect(num, face);
            currCubie = num;
            currFace = face;
            return;
         }
      }
      else {
         if (currFace != -1) {
            // Deselect any cubie
            mouseSelect(-1,-1);
            currCubie = -1;
            currFace = -1;
         }
      }
   }
   
   // Verify hovering over menus
   for (Menu m: Menu_menus) {
      m.hl = m.mouseOver();
   }
}
//====================================================================
void mouseClicked() {
   if (currMenu != null) {
      // Click on a selected menu
      currMenu.mouseClick();
      currMenu.deselect();
      currMenu = null;
      return;
   }
   
   for (Menu m: Menu_menus) {
      if (m.hl) {
         // Clicks on non-selected menu
         if (m.mouseClick()) {
            currMenu = m;
         }
         return;
      }
   }
}

//====================================================================
void keyPressed()
{
   if (shuffling) return;
   
   int dir = -1;
   switch (key) {
      case 'w': case 'W': dir = 0; break;  // up
      case 's': case 'S': dir = 2; break;  // down
      case 'a': case 'A': dir = 3; break;  // left
      case 'd': case 'D': dir = 1; break;  // right
      case 'p':
         printPos = !printPos;
         if (printPos) {
            println("Printing cubie position");
         }
         return;
      case ' ':
         if (currMove == null && len(movePile) > 0) {
            currMove = movePile.remove(len(movePile)-1);
            currMove.reverse();
         }
         return;
   }
   
   // DO A ROTATION
   if (currMove == null && dir != -1 && currCubie != -1)
   {
      assert(currFace >= 0);
      // Get the coordinates from the current cubie
      Cubie c0 = cubies.get(currCubie);
      int cx = c0.x, cy = c0.y, cz = c0.z;
          
      // Project the cube axes onto the screen
      float[] r = cam.getRotations();
      Rotation camRot = new Rotation(
         RotationOrder.XYZ, r[0], r[1], r[2]);
      Vector3D vi = camRot.applyTo(Vector3D.plusI);
      Vector3D vj = camRot.applyTo(Vector3D.plusJ);
      double[][] projs = {
         {vi.getX(), vj.getX()},
         {vi.getY(), vj.getY()},
         {vi.getZ(), vj.getZ()}};
      
      // Select the current face's normal axis index
      // {0=x, 1=y, 2=z} and sign (-1 or +1)
      int cfAxis = 0;
      int cfSign = -1;
      switch (currFace) {
         case FRT: cfSign = 1;
         case BCK: cfAxis = 0;
            break;

         case LFT: cfSign = 1;
         case RGT: cfAxis = 1;
            break;
         
         case UPP: cfSign = 1;
         case DWN: cfAxis = 2;
            break;
      }
      
      // Look for the axis closest to the keyboard
      // direction dir (0=up, 1=left, 2=down, 3=right)
      int kbSign = 0;
      int kbAxis = -1;
      double maxp = -10;
      for (int i = 0; i < 3; i++) {
         // Não analisa as projeções da normal da face
         if (i == cfAxis) continue;
         
         double p = -10;
         switch (dir) {
            case 0: p = -projs[i][1]; break; // up
            case 1: p = +projs[i][0]; break; // right
            case 2: p = +projs[i][1]; break; // down
            case 3: p = -projs[i][0]; break; // left
         }
         if (Math.abs(p) > maxp) {
            kbSign = (p < 0)? -1: 1;
            maxp = Math.abs(p);
            kbAxis = i;
         }
      }
      
      // ALL SET TO ROTATE?
      if (kbAxis >= 0)
      {
         // Do a cross-product of sorts
         int rotSign = 0;
         int rotAxis = 0;
         int[] next = {1, 2, 0};
         if (next[kbAxis] == cfAxis) {
            rotAxis = next[cfAxis];
            rotSign = kbSign*cfSign;
         }
         else {
            rotAxis = next[kbAxis];
            rotSign = -kbSign*cfSign;
         }
         
         /*char[] table = {'X','Y','Z'};
         print("Rotate: ");
         print((cfSign<0)? '-': '+');
         print(table[cfAxis], "x ");
         print((kbSign<0)? '-': '+');
         print(table[kbAxis], "= ");
         print((rotSign<0)? '-': '+');
         println(table[rotAxis]);*/
         
         int plane = cx;
         if (rotAxis == 1) plane = cy;
         else if (rotAxis == 2) plane = cz;
         currMove = new Move(rotAxis, rotSign, plane);
         movePile.add(currMove);
         
         // Desselect all cubies
         currCubie = -1;
         mouseSelect(currCubie, currFace);
      }
   }
}
//====================================================================
void draw()
{
   for (Menu m: Menu_menus)
      m.update();
      
   if (currMove != null) {
      if (!currMove.update()) {
         currMove = null;
         if (!shuffling)
            reSelect = true;
      }
   }
   else if (shuffling) {
      if (Menu_menus.get(1).selected) {
         currMove = new Move(int(random(4)),
            (random(1) >= 0.5)? -1: +1,
            int(random(g_dim)));
         //currMove.speed = 0.2;
         movePile.add(currMove);
      }
      else {
         shuffling = false;
         currMove = null;
         reSelect = true;
      }
   }
   
   background(51);
   scale(55);
   strokeWeight(0.05);
   for (Cubie c: cubies)
      c.show();
   //g_picker.stop();

   // Repeat the cube drawing for the picking buffer
   beginPicker();
      cam.getState().apply(pickerBuffer());
      background(51);
      scale(50);
      strokeWeight(0.05);
      for (Cubie c: cubies)
         c.show();
   endPicker();

   cam.beginHUD();
   hint(DISABLE_DEPTH_TEST);
   for (Menu m: Menu_menus) m.draw();
   hint(ENABLE_DEPTH_TEST);
   //showPBuffer();
   cam.endHUD();

   // Apply current camera matrix to Picker too
   //PGraphics a = g_picker.getBuffer();
   //if (a != null) cam.getState().apply(a);

	/*
   // Show the Euclidean axes
   strokeWeight(0.1);
   stroke(255,0,0); line(0,0,0, 3,0,0);
   stroke(0,255,0); line(0,0,0, 0,3,0);
   stroke(0,0,255); line(0,0,0, 0,0,3);
   */
   if (reSelect) {
      reSelect = false;
      mouseMoved();
   }
}
/*====================================================================
   Some useful functions here
====================================================================*/
int len(int[] t) { return t.length; }
int len(ArrayList a) { return a.size(); }
void swap(int[] m, int i, int j) {
   int t = m[i];
   m[i] = m[j];
   m[j] = t;
}

boolean btw(float x, float a, float b) {
   return (x >= a && x < b);
}

boolean insideBox(float x, float y,
   float u, float v, float w, float h) {
   return (x >= u && y >= v && x < u+w && y < v+h);
}

int unmap(int[] map, int value) {
   for (int i=0; i<map.length; i++)
      if (map[i] == value)
         return i;
   throw new IllegalArgumentException(
      "Value "+str(value)+" not available");
}
