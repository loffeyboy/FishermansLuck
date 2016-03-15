  import ddf.minim.*;
  import java.util.*;
  import java.lang.Math;
  import java.time.Duration;
  //import com.dhchoi.*;
  
  private AudioPlayer audioPlayer;
  private Minim minim;
  private Player player;
  private Graphic graphic;
  private Saving saving;
  private Load load;
  private Level level;
  private SaveThread savingThread; 
  private Menu menu;
  //private ArrayList <Catch> fish;
  //private int numberOfFish = 6;
  private boolean sound;
  private boolean inGame;
  private boolean inPauseMenu;
  private boolean gameOver;
  private boolean inLevelMenu;
  private boolean inMainMenu;
  //CountdownTimer time;
  //private int score;
  //private int spawner;
  
  private final String STATE_MENU = "menu";
  private final String STATE_NEW = "new";
  private final String STATE_PLAY = "play";
  private final String STATE_LEVEL = "level";
  private final String STATE_QUIT = "quit";     
  private final String STATE_HELP = "help";
  private final String STATE_CONTINUE = "continue";
  private final String STATE_TUTUROIAL = "tutorial";
  private final String STATE_GAME_OVER = "game over";
  private final String STATE_PAUSE = "pause";
  private final String STATE_RESUME = "resume";
  private final String STATE_WIN = "win";
  private String STATE = STATE_MENU;
  
  void setup () {
    size(1000, 700);
    frameRate(60);
    player = new Player();
    graphic = new Graphic();
    menu = new Menu();
    saving = new Saving();
    load = new Load();
    //time = CountdownTimerService.getNewCountdownTimer(this);
    level = new Level(player);
    // level.setLevel(1);
    sound = true;
    //Music if sound == true play background music
    playBackgroundMusic(sound);
    gameOver = false;
    inGame = false;
    inPauseMenu = false;
    inLevelMenu = false;
    inMainMenu = true;
    //spawner = 300; //How often fish are spawning. The lower the number, the ofter fish are spawn
    saving.saveGameState( player, level.getArray(), level.getScore());
    this.savingThread = new SaveThread(saving, this, player);
    this.savingThread.start();
  }
  
  void draw () {
    //run();
    play();
  }
  
  //Runs the game
  public void run() {
    switch(STATE) {
    case STATE_MENU: 
      inGame = false;
      gameOver = false;
      inPauseMenu = false;
      inLevelMenu = false;
      inMainMenu = true;
      graphic.drawBackground();
      graphic.drawLogo();
      menu.drawMenuButton();
      break;
  
    case STATE_PAUSE:
      inLevelMenu = false;
      gameOver = false;
      inGame = false;
      inPauseMenu = true;
      inMainMenu = false;
      pauseGame();
      break;
  
  
    case STATE_CONTINUE:  // check with the got catch
      gameOver = false;
      inLevelMenu = false;
      inGame = true;
      inPauseMenu = false;
      inMainMenu = false;
      load.playerLoad();
      level.setScore(load.getScore());
      level.startTimer();
      // Denne funbskjonen skal flyttes til Level
      STATE = STATE_PLAY;
      break;
  
    case STATE_RESUME:
      gameOver = false;
      inLevelMenu = false;
      inGame = true;
      inPauseMenu = false;
      inMainMenu = false;
      level.startTimer();
      // Denne funbskjonen skal flyttes til Level
      STATE = STATE_PLAY;
      break;
  
    case STATE_NEW:
      setup();
      STATE = STATE_LEVEL;
      level.resetTimer();
      break;
  
  
    case STATE_PLAY: 
      inGame = true;
      inLevelMenu = false;
      gameOver = false;
      inPauseMenu = false;
      inMainMenu = false;
      play();
      break;
  
    case STATE_LEVEL:
      // setup();
      inGame = false;
      inLevelMenu = true;
      gameOver = false;
      inPauseMenu = false;
      inMainMenu = false;
      graphic.drawBackground();
      graphic.drawLogo();
      menu.drawLevelButton();
      break;
  
    case STATE_TUTUROIAL: 
      // tutorial skal inn her
      text("oi, her er det ingenting", 350, 300);
      break;
  
    case STATE_HELP:
      //println("Din score er: " + level.getScore());
      //println("LagraScore:" + load.getScore());
      break;
  
    case STATE_QUIT:
      inLevelMenu = false;
      gameOver = false;
      inGame = false;
      inPauseMenu = false;
      inMainMenu = false;
      exit();
      break;
  
    case STATE_GAME_OVER:
      inLevelMenu = false;
      gameOver = true;
      inGame = false;
      inPauseMenu = false;
      inMainMenu = false;
      graphic.gameBlackBackground();
      menu.drawGameOverMenu();
      break;  
  
    case STATE_WIN:
      inLevelMenu = true;
      gameOver = false;
      inGame = false;
      inPauseMenu = false;
      inMainMenu = false;
      graphic.gameBlackBackground();
      level.winBoard();
      level.resetAfterWin();
      menu.drawLevelButton();
      //STATE = STATE_LEVEL;
      break;
  
    default:
      // do nothing
      break;
    }
  }
  
  //Starts the game 
  public void play() {
    graphic.drawBackground();
    player.boat();
    menu.drawInGameButton();
    level.levelState();
    if (level.getWinStatus()) {
      STATE = STATE_WIN;
    }
    if (level.getGameOverStatus()) {
      STATE = STATE_GAME_OVER;
    }
  }
  
  //background music function.
  private void playBackgroundMusic(boolean sound) 
  {
    if (sound) {
      minim = new Minim(this);
      audioPlayer = minim.loadFile("lyd/Fishing2.mp3");
      //audioPlayer.play();
    }
    if (sound == false) {
      audioPlayer.close();
      minim.stop();
    }
  }
  
  public void pauseGame() {
    saving.saveGameState( player, level.getArray(), level.getScore());
    level.pauseTimer();
    menu.drawPauseMenu();
  }
  
  // Checks if the use are pressing a button
  public void mousePressed() {
  
    String result2 = menu.isButtonPressed(menu.getInGameMenuHash()) ;
    if (result2.equals("sound")) {
      playBackgroundMusic( menu.getSoundOnOffSwitch());
    }
    if (result2.equals("pause")) {
      STATE = STATE_PAUSE;
    }
  
    // Checks buttons in inGame menu
    if (inMainMenu)
    {
      String result = menu.isButtonPressed(menu.getMainMenuHash()) ;
      if (!result.equals("none")) {
        STATE = result;
      }
    }
  
    // Checks buttons in Pause menu
    if (inPauseMenu) {
      String result = menu.isButtonPressed(menu.getPauseMenuHash()) ;
      if (!result.equals("none")) {
        STATE = result;
      }
    }
  
    // Checks buttons in Game Over menu
    if (gameOver) {
      String result = menu.isButtonPressed(menu.getGameOverMenuHash()) ;
      if (!result.equals("none")) {
        STATE = result;
      }
    }
  
    // Checks buttons in level menu
    if (inLevelMenu) {
      String result = menu.isButtonPressed(menu.getLevelMenuButtonsHash()) ;
      if (!result.equals("none")) {
        // int level = int (Float.valueOf(result));
        for (int i = 0; i <= 4; i++) {
          String iString = "" + i;
          if (iString.equals(result)) {
            level.setLevel(i);
            STATE = STATE_PLAY;
          }
        }
      } else if (result.equals("menu")) {
        STATE = result;
      }
    }
  }
  
  // If the game is true and not in the menu then the game need to be saved.
  public boolean needSaving() {
    return (inGame && (!inPauseMenu));
  }