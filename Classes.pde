class Ball
{
  PVector pos, vel, acc; // position, velocity, acceleration
  float maxSpeed = 700, radius;
  
  Ball(float x, float y, float r)
  {
    pos = new PVector(x, y);
    vel = new PVector(random(-200,200), 0);
    acc = new PVector(0, gravity); // acceleration == gravity
    radius = r;
  }
  
  void update(float dt)
  {
    // Apply physical motion
    vel.add(PVector.mult(acc, dt));
    pos.add(PVector.mult(vel, dt));
    
    // Clamp ball to maximum/terminal velocity
    if (vel.mag() > maxSpeed)
      vel.normalize().mult(maxSpeed);
    
    // Top wall (soft collision, no bounce)
    if (pos.y - radius < 0)
    {
      pos.y = radius;
      // Instead of bouncing, reduce upward velocity strongly
      vel.y = 50;  // small downward push so it starts falling
    }
    
    // Side walls = scoring
    if (pos.x - radius < 0)
    {
      rightScore++;
      reset();
    }
    if (pos.x + radius > width)
    {
      leftScore++;
      reset();
    }
  }
  
  void checkPaddle(Paddle p)
  {
    if (pos.x + radius > p.pos.x && pos.x - radius < p.pos.x + p.w &&
        pos.y + radius > p.pos.y && pos.y - radius < p.pos.y + p.h)
        {
          // Paddle restitution (harder bounce)
          float paddleRestitution = 1.2;  // slightly more bouncy
          PVector normal = new PVector(p.isLeft ? 1 : -1, 0);
          float dot = vel.dot(normal);
          vel.sub(PVector.mult(normal, (1 + paddleRestitution) * dot));
          
          // Angle-based vertical boost
          float hitPos = (pos.y - (p.pos.y + p.h/2)) / (p.h/2);
          vel.y += hitPos * 400;  // stronger vertical bounce
          
          // Dash impulse
          if (p.isDashing) {
            vel.add(new PVector((p.isLeft ? 1 : -1) * p.dashImpulse, 0));
        }
      
      // Push ball out of paddle
      if (p.isLeft) pos.x = p.pos.x + p.w + radius;
      else pos.x = p.pos.x - radius;
      
      // Slight horizontal speed boost
      vel.x *= 1.01;
    }
  }
  
  void checkTrampoline(Trampoline t)
  {
    if (pos.x > t.x && pos.x < t.x + t.w)
    {
      if (pos.y + radius > t.y)
      {
        pos.y = t.y - radius;
  
        // Physics-based bounce
        float incomingVel = vel.y;
        vel.y = -abs(incomingVel) * restitution;  // realistic bounce
       
        // Add small fun boost for gamified effect
        float extraHeight = 80;  // pixels
        float extraVel = sqrt(2 * gravity * extraHeight);
        vel.y -= extraVel;
  
        // Maximum bounce velocity
        vel.y = max(vel.y, -maxSpeed);
  
        // Horizontal randomness
        vel.x += random(70,70);
  
        t.squash(); // trampoline animation
      }
    }
    else if (pos.y - radius > height)
    {
      reset();  // fell below bottom
    }
  }
  
  void display()
  {
    fill(200,50,50);
    ellipse(pos.x, pos.y, radius*2, radius*2);
  }
  
  void reset()
  {
    pos.set(width/2, 200);
    vel.set(random(-200,200), 0);
  }
}

class Paddle
{
  PVector pos;
  float w = 20, h = 100;
  boolean isLeft;
  float speed=300; // px/s
  boolean isDashing = false;
  float dashImpulse = 300;
  int dashTimer = 0, dashDuration = 10;
  
  Paddle(float x, float y, boolean left)
  {
    pos = new PVector(x,y);
    isLeft = left;
  }
  
  void update()
  {
    if (isLeft)
    {
      if (keys['W']) pos.y -= speed*dt;
      if (keys['S']) pos.y += speed*dt;
      if (keys['D'] && !isDashing) dash();
    }
    else
    {
      if (keys[UP]) pos.y -= speed*dt;
      if (keys[DOWN]) pos.y += speed*dt;
      if (keys[LEFT] && !isDashing) dash();
    }
    
    pos.y = constrain(pos.y, 0, height-h-20);
    
    if (isDashing)
    {
      dashTimer--;
      if (dashTimer<=0)
        isDashing=false;
    }
  }
  
  void dash()
  {
    isDashing = true;
    dashTimer = dashDuration;
  }
  
  void display()
  {
    fill(isDashing ? color(250,200,50) : 200);
    rect(pos.x, pos.y, w, h);
  }
}

class Trampoline
{
  float x,y,w,h;
  boolean isLeft;
  float squashScale = 1;
  
  Trampoline(float x,float y,float w,float h,boolean left)
  {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.isLeft = left;
  }
  
  void squash()
  {
    squashScale=0.7;
  }
  
  void display()
  {
    squashScale = lerp(squashScale, 1, 0.1);
    fill(100,200,100);
    rect(x, y, w, h*squashScale);
  }
}
