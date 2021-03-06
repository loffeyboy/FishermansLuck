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
  private int picNr;
  private boolean playMusic = true;
  private boolean sound;
  private boolean inGame;
  private boolean inPauseMenu;
  private boolean gameOver;
  private boolean inLevelMenu;
  private boolean inMainMenu;
  private boolean inTutorialMenu;
  private boolean inHelpMenu;
  private boolean haveSavedAfterWin = false;
  private boolean haveSavedAfterStart = false;
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
    
    load = new Load();
    //time = CountdownTimerService.getNewCountdownTimer(this);
    level = new Level(player);
    saving = new Saving();
    // level.setLevel(1);
    sound = true;
    gameOver = false;
    inGame = false;
    inPauseMenu = false;
    inLevelMenu = false;
    inMainMenu = true;
    picNr = 1;
    //spawner = 300; //How often fish are spawning. The lower the number, the ofter fish are spawn
    //saving.saveGameState( player, level.getArray(), level.getScore(), level);
    this.savingThread = new SaveThread(saving, this, player, level);
    this.savingThread.start();
  }
  
  void draw () {
    println(level.getLevel());
    println("hei");
    run();
    //play();
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
      inTutorialMenu = false;
      inHelpMenu = false;
      graphic.drawBackground();
      graphic.drawLogo();
      menu.drawMenuButton();
      
      //to avoid loop
      if(playMusic){
      playBackgroundMusic(sound);
      playMusic = false;
      }
      break;
  
    case STATE_PAUSE:
      inLevelMenu = false;
      gameOver = false;
      inGame = false;
      inPauseMenu = true;
      inMainMenu = false;
      inTutorialMenu = false;
      inHelpMenu = false;
      pauseGame();
      break;
  
  
    case STATE_CONTINUE:  // check with the got catch
      gameOver = false;
      inLevelMenu = false;
      inGame = true;
      inPauseMenu = false;
      inMainMenu = false;
      inTutorialMenu = false;
      inHelpMenu = false;
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
      inTutorialMenu = false;
      inHelpMenu = false;
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
      inTutorialMenu = false;
      inHelpMenu = false;
      play();
      break;
  
    case STATE_LEVEL:
      // setup();
      inGame = false;
      inLevelMenu = true;
      gameOver = false;
      inPauseMenu = false;
      inMainMenu = false;
      inTutorialMenu = false;
      inHelpMenu = false;
      graphic.drawBackground();
      graphic.drawLogo();
      menu.drawLevelButton();
      break;
  
    case STATE_TUTUROIAL:
      inGame = false;
      inLevelMenu = false;
      gameOver = false;
      inPauseMenu = false;
      inMainMenu = false;
      inTutorialMenu = true;
      inHelpMenu = false;
      
      graphic.drawTutorialButtonBackground();
      graphic.tutorialPic(picNr);
      menu.drawTutorialMenu();   
      break;
  
    case STATE_HELP:
      inHelpMenu = true;
      graphic.help();
      menu.drawHelpMenu();  
      break;
  
    case STATE_QUIT:
      inLevelMenu = false;
      gameOver = false;
      inGame = false;
      inPauseMenu = false;
      inMainMenu = false;
      inTutorialMenu = false;
      inHelpMenu = false;
      exit();
      break;
  
    case STATE_GAME_OVER:
      inLevelMenu = false;
      gameOver = true;
      inGame = false;
      inPauseMenu = false;
      inMainMenu = false;
      inTutorialMenu = false;
      inHelpMenu = false;
      graphic.gameBlackBackground();
      menu.drawGameOverMenu();
      break;  
  
    case STATE_WIN:
    if (!haveSavedAfterWin) {
    saving.saveGameState( player, level.getArray(), level.getScore(), level); // to save when you win the game
    haveSavedAfterWin = true;
    }
      inLevelMenu = true;
      gameOver = false;
      inGame = false;
      inPauseMenu = false;
      inMainMenu = false;
      inTutorialMenu = false;
      inHelpMenu = false;
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
      //soundsource: http://www.bensound.com/royalty-free-music/track/cute
      audioPlayer = minim.loadFile("lyd/bensound-cute.mp3");
      audioPlayer.loop();
    }
    if (sound == false) {
      audioPlayer.close();
      minim.stop();
    }
  }
  
   public void pauseGame() {
    saving.saveGameState( player, level.getArray(), level.getScore(),level);
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
      if (result.equals("menu")) {
        STATE = result;
      }
      if (!result.equals("none")) {
        // int level = int (Float.valueOf(result));
        for (int i = 1; i <= 4; i++) {
          String iString = "" + i;
          if (iString.equals(result)) {
            level.setLevel(i);
            STATE = STATE_PLAY;
          }
        }
      } 
    }
  
    if (inTutorialMenu)
    {
      String result = menu.isButtonPressed(menu.getTutorialMenuButtonsHash());
      if (!result.equals("none")) {
  
        if (result.equals("next")&&(picNr<10))
        {
          picNr++;  
          println(picNr);
        } else if (result.equals("back")&&(picNr>1))
        {     
          picNr--; 
          println(picNr);
        }
        graphic.tutorialPic(picNr);
        STATE = result;
      }
    }
    if (inHelpMenu){
      String result = menu.isButtonPressed(menu.getHelpMenuButtonsHash()) ;
      if (!result.equals("none")) {
        STATE = result;
      }
    }
  }
  
  // If the game is true and not in the menu then the game need to be saved.
  public boolean needSaving() {
    return (inGame && (!inPauseMenu));
  }