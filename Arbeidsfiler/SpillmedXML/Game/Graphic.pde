

public class Graphic {

  private PImage background;
  private PImage logo;

  public Graphic() {
    background = loadImage("Bilder.Grafikk/background2tilpasset.png");
    logo = loadImage("Bilder.Grafikk/tempLogo.png");
  }
  public void drawBackground()
  {
    image(background, 0, 0, 1000, 700);
  }
  
  public void gameOverBackground() {
    background(0);
  }
  public void drawLogo()
  {
    image(logo,0,0);
  }
}