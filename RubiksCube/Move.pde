class Move
{  
   int axis;   // rotation axis
   int sign;   // rotation sign
   int plane;  // cube's plane number
   float speed = 0.2;
   
   ArrayList<Cubie> list;
   PMatrix3D m3D;
   float angle;
   boolean moving;
   //==========================================================
   Move(int axis, int sign, int plane) {
      this.plane = plane;
      this.axis = axis;
      this.sign = sign;
      begin(true);
   }
   //==========================================================
   void reverse() {
      begin(false);
   }
   //==========================================================
   void begin(boolean forward) {
      if (!forward) sign = -sign;
      angle = 0.0;
      m3D = new PMatrix3D();
      list = selectPlane(axis, plane);
      for (Cubie c: list) c.mat = m3D;
      moving = true;
   }
   //==========================================================
   boolean update() {
      if (!moving) return false;
      angle += (sign > 0)? -speed: speed;
      
      m3D.reset();
      switch (axis) {
         case 0: m3D.rotate(angle,1,0,0); break;
         case 1: m3D.rotate(angle,0,1,0); break;
         case 2: m3D.rotate(angle,0,0,1); break;
      }
      if (abs(angle) > PI/2) {
         for (Cubie c: list) {
            c.turn(axis, sign);
            c.mat = null;
         }
         moving = false;
      }
      return moving;
   }
}
