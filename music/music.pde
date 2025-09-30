import processing.sound.*;  

SoundFile file;             
boolean isPlaying = false;  
float pausePos = 0;         

float barX = 50, barY = 100, barW = 400, barH = 10;
float btnX = 50, btnY = 30, btnW = 260, btnH = 28;

void setup() {
  size(500, 200);
  frameRate(30);
  file = new SoundFile(this, "Windows XP Startup.wav");
}

void draw() {
  background(0);
  fill(255);
  textSize(16);

  float currentSec = file.position();
  float totalDuration = file.duration();

  // ✅ 再生終了を検知
  if (isPlaying && !file.isPlaying()) {
    isPlaying = false;
    pausePos = 0;  // 次回は頭から再生
  }

  // 再生時間の表示
  text("Time: " + formatTime(currentSec) + " / " + formatTime(totalDuration), 50, 150);

  // 再生/一時停止ボタン
  stroke(180);
  noFill();
  rect(btnX, btnY, btnW, btnH, 6);
  noStroke();
  fill(255);
  if (isPlaying) text("■ Pause (Click or Space)", btnX + 8, btnY + 20);
  else text("▶ Play (Click or Space)", btnX + 8, btnY + 20);

  // プログレスバー背景
  noStroke();
  fill(100);
  rect(barX, barY, barW, barH);

  // 進行部分
  if (totalDuration > 0) {
    float progress = map(currentSec, 0, totalDuration, 0, barW);
    progress = constrain(progress, 0, barW);
    fill(215, 0, 0);
    rect(barX, barY, progress, barH);
  }
}

void mousePressed() {
  float totalDuration = file.duration();

  if (mouseY > barY && mouseY < barY + barH && mouseX > barX && mouseX < barX + barW) {
    float newTime = map(mouseX, barX, barX + barW, 0, totalDuration);
    pausePos = constrain(newTime, 0, totalDuration - 0.001);
    if (isPlaying) file.jump(pausePos);
    else file.cue(pausePos);
    return;
  }

  if (mouseX > btnX && mouseX < btnX + btnW && mouseY > btnY && mouseY < btnY + btnH) {
    togglePlay();
  }
}

void keyPressed() {
  if (key == ' ') togglePlay();
}

void togglePlay() {
  if (!isPlaying) {
    if (file.position() >= file.duration() - 0.001) pausePos = 0;
    file.cue(pausePos);
    file.play();
    isPlaying = true;
  } else {
    pausePos = file.position();
    file.stop();
    isPlaying = false;
  }
}

String formatTime(float s) {
  if (s <= 0 || Float.isNaN(s)) return "0:00";
  int total = floor(s);
  int m = total / 60;
  int sec = total % 60;
  return str(m) + ":" + nf(sec, 2);
}
