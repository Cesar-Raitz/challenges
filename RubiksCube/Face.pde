class Face {
   int side;
   int clr;
   int id;
   boolean hl;
   
   Face(int side, int id) {
      this.side = side;
      this.id = id;
      clr = side;
      hl = false;
   }
   
   void show(boolean highlight)
   {
      //g_picker.start(id + side);
      setId(id+side);
      
      if (highlight || hl)
         fill(g_colors2[clr]);
      else
         fill(g_colors[clr]);
      
      float x[] = {0, 1, 1, 0};
      float y[] = {0, 0, 1, 1};
      float z = 0;
      int i;
      
      beginShape();
      switch (side) {
         case UPP: z += 1;
         case DWN: for (i=0; i<4; i++) 
            vertex(x[i], y[i], z); break;
         
         case FRT: z += 1;
         case BCK: for (i=0; i<4; i++)
            vertex(z, x[i], y[i]); break;
            
         case LFT: z += 1;
         case RGT: for (i=0; i<4; i++)
            vertex(y[i], z, x[i]); break;
      }
      endShape(CLOSE);
   }
}
