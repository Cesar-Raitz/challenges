Menu currMenu;

void setupMenus() {
   // This is the closest we get to a lambda function for Java<8
   Menu_New("SIZE", new MenuAction(){ public void run(Menu m) {
      String txt = "Restarted game with an %dx%dx%d cube";   
      println(String.format(txt, m.id, m.id, m.id));
      if (m.id >= 2 && m.id <= 7) resetGame(m.id);
   }});
   
   Menu_NewSub("two",2);
   Menu_NewSub("three",3);
   Menu_NewSub("four",4);
   Menu_NewSub("five",5);
   Menu_NewSub("six",6);
   Menu_NewSub("seven",7);
   
   Menu_New("SHUFFLE",
      new MenuAction(){ public void run(Menu m) {
         println("We are shuffling the Rubik!");
         shuffling = true;
   }});
   
   Menu_New("RESET",
      new MenuAction(){ public void run(Menu m){
         println("The Rubik was reset");
         resetGame(g_dim);
         // Cause a single spin animation
         m.selected = false;
         m.animating = true;
   }});
}
