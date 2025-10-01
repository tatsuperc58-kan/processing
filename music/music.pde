import processing.sound.*;  // Processingのサウンドライブラリを読み込む

SoundFile file;             // 再生する音声ファイルを扱う変数
boolean isPlaying = false;  // 再生中かどうかのフラグ
float pausePos = 0;         // 一時停止した位置（秒数）

// プログレスバーの位置とサイズ
float barX = 50, barY = 100, barW = 400, barH = 10;
// 再生/一時停止ボタンの位置とサイズ
float btnX = 50, btnY = 30, btnW = 260, btnH = 28;

void setup() {
  size(500, 200);                  // ウィンドウサイズを500x200に設定
  frameRate(30);                   // フレームレートを30fpsに設定
  file = new SoundFile(this, "Windows XP Startup.wav");  // 音声ファイルを読み込む
}

void draw() {
  background(0);       // 背景を黒で塗りつぶす
  fill(255);           // 描画色を白に設定
  textSize(16);        // テキストサイズを16ptに設定

  float currentSec = file.position();   // 現在の再生位置（秒）
  float totalDuration = file.duration(); // 音声ファイル全体の長さ（秒）

  // ✅ 再生終了を検知
  if (isPlaying && !file.isPlaying()) {
    isPlaying = false;   // 再生フラグをオフにする
    pausePos = 0;        // 次回は頭から再生できるようにリセット
  }

  // 再生時間の表示（現在時間 / 全体時間）
  text("Time: " + formatTime(currentSec) + " / " + formatTime(totalDuration), 50, 150);

  // 再生/一時停止ボタンの枠
  stroke(180);         // 薄いグレーの枠線
  noFill();
  rect(btnX, btnY, btnW, btnH, 6);   // 角丸の矩形を描画
  noStroke();
  fill(255);
  if (isPlaying) 
    text("■ Pause (Click or Space)", btnX + 8, btnY + 20);  // 再生中は「Pause」表示
  else 
    text("▶ Play (Click or Space)", btnX + 8, btnY + 20);   // 停止中は「Play」表示

  // プログレスバー（背景部分）
  noStroke();
  fill(100);  // グレー
  rect(barX, barY, barW, barH);

  // プログレスバー（進行部分）
  if (totalDuration > 0) {
    float progress = map(currentSec, 0, totalDuration, 0, barW); // 再生位置を幅に変換
    progress = constrain(progress, 0, barW);  // 範囲外に出ないように制限
    fill(215, 0, 0); // 赤色
    rect(barX, barY, progress, barH); // 再生済み部分を描画
  }
}

void mousePressed() {
  float totalDuration = file.duration();

  // プログレスバー上をクリックした場合
  if (mouseY > barY && mouseY < barY + barH && mouseX > barX && mouseX < barX + barW) {
    float newTime = map(mouseX, barX, barX + barW, 0, totalDuration); // クリック位置を時間に変換
    pausePos = constrain(newTime, 0, totalDuration - 0.001); // 範囲を制限
    if (isPlaying) file.jump(pausePos); // 再生中ならその位置にジャンプ
    else file.cue(pausePos);           // 停止中なら再生準備だけする
    return; // 他の処理をスキップ
  }

  // ボタン上をクリックした場合
  if (mouseX > btnX && mouseX < btnX + btnW && mouseY > btnY && mouseY < btnY + btnH) {
    togglePlay(); // 再生/停止を切り替える
  }
}

void keyPressed() {
  if (key == ' ') togglePlay(); // スペースキーで再生/停止切り替え
}

void togglePlay() {
  if (!isPlaying) { // 停止中なら再生開始
    if (file.position() >= file.duration() - 0.001) pausePos = 0; // 終了していたら最初から
    file.cue(pausePos); // 一時停止位置から再生準備
    file.play();        // 再生開始
    isPlaying = true;   // 再生中フラグをオン
  } else { // 再生中なら停止
    pausePos = file.position(); // 現在位置を保存
    file.stop();                // 停止
    isPlaying = false;          // 再生中フラグをオフ
  }
}

// 秒数を「分:秒」形式に変換する関数
String formatTime(float s) {
  if (s <= 0 || Float.isNaN(s)) return "0:00"; // 不正な値は0:00で返す
  int total = floor(s); // 小数点以下を切り捨て
  int m = total / 60;   // 分
  int sec = total % 60; // 秒
  return str(m) + ":" + nf(sec, 2); // "分:秒"（秒は2桁表示）
}
