class Cubie {
	PMatrix3D mat;
	boolean highlight;
   boolean moving;
   int id, x, y, z;
   Face[] faces = new Face[6];

	Cubie(int id, int x, int y, int z) {
      highlight = false;
      moving = false;
      mat = null;
      this.x = x;
      this.y = y;
      this.z = z;
      this.id = id;
      
      for (int side = 0; side < 6; side++)
         faces[side] = new Face(side, id<<3);
	}
   //==========================================================
   void deselect() {
      highlight = false;
      for (Face f: faces)
         f.hl = false;
   }
   //==========================================================
   Face getFace(int side) {
      for (Face f: faces)
         if (f.side == side)
            return f;
      // Default face
      return faces[0];
   }
   //==========================================================
   void select(int[] list) {
      assert(list != null);
      for (int n: list) getFace(n).hl = true;
   }
   //==========================================================
   void turn(int axis, int angle) {
      char[] table = {'x','y','z'};
      turn(table[axis], angle);
   }
   //==========================================================
   void turn(char axis, int angle) {
      // dim = 'x', 'y' or 'z'
      // angle = +1 or -1
      
      // Escolhe coordenadas de acordo com o eixo de rotação
      int u = 0;
      int v = 0;
      switch (axis) {
         case 'x': u = y; v = z; break;
         case 'y': u = z; v = x; break;
         case 'z': u = x; v = y;
      }
      if (highlight) print(x,y,z," --> ");
      
      // Passa para coordenadas centradas
      u = g_map[u];
      v = g_map[v];
      // Aplica a transformação de rotação
      int up = (angle > 0)? v: -v;
      int vp = (angle < 0)? u: -u;
      up = unmap(g_map, up);
      vp = unmap(g_map, vp);
      
      // Grava as coordenadas transformadas
      switch (axis) {
         case 'x': y = up; z = vp; break;
         case 'y': z = up; x = vp; break;
         case 'z': x = up; y = vp;
      }
      if (highlight) println(x,y,z);
      assert(x >= 0 && x < g_dim);
      assert(y >= 0 && y < g_dim);
      assert(z >= 0 && z < g_dim);
      
      //  UPP,DWN,LFT,RGT,FRT,BCK
      int[][] T = {
         {LFT,RGT,DWN,UPP,FRT,BCK},
         {BCK,FRT,LFT,RGT,UPP,DWN},
         {UPP,DWN,FRT,BCK,RGT,LFT}};
      int[] t;
      if (axis == 'x') t = T[0];
      else if (axis == 'y') t = T[1];
      else t = T[2];
      for (Face f: faces) {
         if (angle>0) f.side = t[f.side];
         else f.side = unmap(t,f.side);
      }
   }
   //==========================================================
	void show() {
   	if (highlight)
			fill(255,0,0);
		else
			fill(255);
		stroke(0);
		
      pushMatrix();
      if (mat != null) {
         applyMatrix(mat);
      }
		// Desloca o cubie de acordo com o índice
      float o = float(g_dim)/2;
      translate(x-o, y-o, z-o);
      for (Face f: faces)
         f.show(highlight);
      popMatrix();
   }
}
