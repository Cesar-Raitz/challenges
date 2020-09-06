float currX = 0;
float currY = 0;
float marginTop = 2;
float marginLeft = 8;
float marginRight = 8;
float marginBottom = 4;

interface MenuAction {
   void run(Menu m);
}

/*============================================================= 
   Static members
=============================================================*/
ArrayList<Menu> Menu_menus = new ArrayList();
Menu Menu_topMenu = null;

Menu Menu_NewSub(String label, int id) {
   if (Menu_topMenu == null) {
      println("Create a top menu first!");
      return null;
   }
   int l = len(Menu_menus);
   Menu top = Menu_menus.get(l-1);
   Menu sub = new Menu(label);
   top.addSub(sub);   
   sub.action = top.action; // copy the top-menu's action    
   sub.id = id;
   return sub;
}

Menu Menu_NewSub(String label) {
   return Menu_NewSub(label, 0);
}

void Menu_New(String label, MenuAction action) {
   int l = len(Menu_menus);
   if (l > 0) {
      Menu top = Menu_menus.get(l-1);
      currX += top.boxW;
   }
   Menu m = new Menu(label);
   m.action = action;
   Menu_menus.add(m);
   m.id = 0;
}
//=============================================================
class Menu {
   float x, y;
   String label;
   float textH;
   float textW;
   float boxW;
   float boxH;
   float angle = 0;
   boolean hl = false;
   boolean selected = false;
   ArrayList<Menu> subs = null;
   boolean isSub = false;
   boolean animating = false;
   int id;
   
   MenuAction action = null;
   
   //==========================================================
   Menu(String label) {
      Menu_topMenu = this;
      this.label = label;
      x = currX;
      y = currY;
      textH = 32;
      textSize(textH);
      textW = textWidth(label);
      boxW = marginLeft + textW + marginRight;
      boxH = marginTop + textH + marginBottom;
   }
   //==========================================================
   void deselect() {
      selected = false;
      hl = false;
   }
   //==========================================================
   void addSub(Menu sub) {
      float y2 = boxH;
      if (subs == null) { 
         subs = new ArrayList();
      }
      else {
         int i = len(subs) - 1;
         Menu last = subs.get(i);
         y2 = last.y + last.boxH;
      }
      //m.setAction(sma);
      sub.x = x;
      sub.y = y2;
      sub.isSub = true;
      sub.boxW = boxW;   // same width as the top menu
      subs.add(sub);     // add it to the subs list
   }
   //==========================================================
   boolean update() {
      final float omega = 0.1;
      if (selected) {
         animating = true;
         angle += omega;
         if (angle >= 2*PI)
            angle -= 2*PI;
      }
      else if (animating) {
         angle += omega;
         if (angle >= 2*PI) {
            animating = false;
            angle = 0;
         }
      }
      return true;
   }
   //==========================================================
   void draw() {
      noStroke();
      if (selected || hl) fill(250);
      else fill(150);
      textSize(textH);
      
      if (!isSub) {
         textAlign(LEFT, TOP);
         pushMatrix();
         translate(0, boxH/2);
         rotateX(angle);
         translate(0, -boxH/2);
         text(label, x+marginLeft, y+marginTop);
         popMatrix();
         
         if (selected && subs != null)
            for (Menu sm: subs) sm.draw();
      }
      else {
         textAlign(CENTER, TOP);
         text(label, x+boxW/2, y+marginTop);
      }
      /*noFill();
      stroke(200,0,0);
      strokeWeight(2);
      rect(x, y, boxW, boxH);*/
   }
   //==========================================================
   boolean mouseOver() {
      // In case where the submenus are visible
      if (!isSub && selected && subs != null) {
         for (Menu sm: subs) sm.hl = false;;
         for (Menu sm: subs) {
            sm.hl = sm.mouseOver();
            if (sm.hl) break;
         }
         return false;
      }
      return insideBox(mouseX, mouseY, x, y, boxW, boxH);
   }
   //==========================================================
   private boolean p_act() {
      if (action != null) {
         action.run(this);
         return true;
      }
      return false;
   }
   //==========================================================
   boolean mouseClick() {
      if (subs != null) {
         if (selected) {
            for (Menu sm: subs) {
               if (sm.hl) {  // Execute sub's action
                  selected = false;
                  sm.p_act();
                  break;
               }
            }
         }
         else {
            selected = true; // Reveal sub-menus
         }
      }
      else if (!selected) {
         selected = true;    // Animate this top menu  
         p_act();
      }
      return selected;
   }
   //==========================================================
}
