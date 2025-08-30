Ball ball;
Paddle leftPaddle, rightPaddle; // UP,DOWN,LEFT
Trampoline leftTramp, rightTramp; // W,S,D

float gravity = 800; // pixels/s^2
float restitution = 0.8; // bounciness factor
float dt; // delta time in seconds
int lastTime;

int leftScore = 0;
int rightScore = 0;

boolean[] keys = new boolean[512]; // array of pressed keys needed, as processing normally only supports one key pressed at a time

void setup()
{
  size(800, 600);
  frameRate(60);
  
  ball = new Ball(width/2, 200, 15);
  
  leftPaddle = new Paddle(60, height/2, true);
  rightPaddle = new Paddle(width-80, height/2, false);
  
  leftTramp = new Trampoline(0, height-20, width/2, 20, true);
  rightTramp = new Trampoline(width/2, height-20, width/2, 20, false);
  
  lastTime = millis();
}

void draw()
{
  background(30);

  int now = millis();
  dt = (now - lastTime) / 1000.0;
  lastTime = now;

  // UI
  fill(255);
  textAlign(CENTER, TOP);
  textSize(32);
  text(leftScore, width/4, 10);
  text(rightScore, 3*width/4, 10);

  // Update
  leftPaddle.update();
  rightPaddle.update();
  ball.update(dt);

  // Collisions
  ball.checkPaddle(leftPaddle);
  ball.checkPaddle(rightPaddle);
  ball.checkTrampoline(leftTramp);
  ball.checkTrampoline(rightTramp);

  // Draw
  leftPaddle.display();
  rightPaddle.display();
  leftTramp.display();
  rightTramp.display();
  ball.display();
}

void keyPressed()
{
  if (keyCode < keys.length)
    keys[keyCode] = true;
}
void keyReleased()
{
  if (keyCode < keys.length)
    keys[keyCode] = false;
}
