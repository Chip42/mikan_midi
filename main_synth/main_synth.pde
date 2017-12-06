// orgソース配布元
// http:// nakayasu.com/lecture/processing-midi%E3%83%97%E3%83%AD%E3%82%B0%E3%83%A9%E3%83%9F%E3%83%B3%E3%82%B0/4860

// synth
// makey makeyで別インターフェースにする。
// rwMidiの改造ライブラリを利用　http:// web.t-factory.jp/nicotech/applet/rwmidi_patch/rwmidi.zip
// RWMidi本家　http:// ruinwesen.com/support-files/rwmidi/documentation/RWMidi.html
 
import rwmidi.*;  // RWMidi改造ライブラリの読み込み
import themidibus.*; // The Midibusライブラリの読み込み
MidiOutput output;
MidiBus myBus;

int ch = 3;  // Midi Chの設定　ここ変えるとKontakt Playerの別のラックの音出せる
int note_on = 60;  // NoteOnナンバー（変数） 60でC2
int note_off = 60; // NoteOffナンバー（変数）
int vel = 127;  // Velocity（音の強さ）の設定0〜127
int program = 0; // プログラムチェンジ（音色）の設定
int dev = 1;  // 音源の設定　Kontaktをport a（=0）にした時はJavaは2
int devLength = 1; // デバイスの数

int A_cc_number = 0; // CCナンバー
int B_cc_number = 1; // CCナンバー
int C_cc_number = 2; // CCナンバー
int D_cc_number = 3; // CCナンバー

int A_cc_value = 10, B_cc_value = 10, C_cc_value = 10, D_cc_value = 10; // CCの値

void setup () {
  size (1000, 600); // ウィンドウサイズ
  frameRate (60);
  devLength = RWMidi.getOutputDevices ().length; // デバイスの数
  output = RWMidi.getOutputDevices () [dev].createOutput(); // デバイスの設定
  output.sendProgramChange (program); // プログラムチェンジの設定
  // デバイスリストの表示
  for (int i = 0; i < devLength; i++) {
    println ("Output Device " + i + " : " + RWMidi.getOutputDevices () [i].getName() );
  }
  MidiBus.list(); // midibusのリスト、RWmidiのリスト（setup内、上の記述）両方出す様にしてる
  myBus = new MidiBus(this, 0, 1);
}

void controllerChange(int ch, int cc_number, int cc_value) {
  // Receive a controllerChange
  println();
  println("Controller Change:");
  println("Ch: "+ch+" CC_Number: "+cc_number+" CC_Value: "+cc_value);
}

void draw () {
  background (247, 137, 0);
  text ("Device Name: " + output.getName (), 15, 20);
  text ("Program Change: " + program, 15, 40);
  text ("Push Keys!", 15, 80);
}


// mouse click event
void mousePressed(MouseEvent e ){
  if( e.getButton() == LEFT ){
    note_on = 48;
  } else if( e.getButton() == RIGHT ){
    note_on = 50;
  } else {
    note_on = 0;
  }
  output.sendNoteOn(ch, note_on, vel); // NoteOnの送信
  println ( "keyPressed  Ch: " + ch + " Note: " + note_on + " Vel: " + vel);
}

void mouseReleased(MouseEvent e ){
  if( e.getButton() == LEFT ){
    note_off = 48;
  } else if( e.getButton() == RIGHT ){
    note_off = 50;
  } else {
    note_off = 0;
  }
  output.sendNoteOff(ch, note_off, vel); // NoteOffの送信
}

// keyCode event
// https:// help.adobe.com/ja_JP/AS2LCR/Flash_10.0/help.html?content=00000525.html
// ↓caps lockに注意↓
void keyPressed () { // キーを押した時
  if(key == CODED){
    switch(keyCode) {
      case UP: A_cc_value+=12; myBus.sendControllerChange(ch, A_cc_number, A_cc_value); break;
      case DOWN: A_cc_value-=12; myBus.sendControllerChange(ch, A_cc_number, A_cc_value); break;
      case LEFT: B_cc_value-=12; myBus.sendControllerChange(ch, B_cc_number, B_cc_value); break;
      case RIGHT: B_cc_value+=12; myBus.sendControllerChange(ch, B_cc_number, B_cc_value); break;
    }
  }else{
    switch(key) {
      case 'w': note_on = 36; break; // space key
      case 'a': note_on = 38; break; // dorian_C_key
      case 's': note_on = 39; break; // w, a, s, d, f, g, space, L_click, R_click
      case 'd': note_on = 40; break;
      case 'f': note_on = 42; break;
      case 'g': note_on = 44; break;
      case ' ': note_on = 45; break;
      default: note_on = 0; break;
    }
    output.sendNoteOn ( ch, note_on, vel ); // NoteOnの送信
    println ( "keyPressed  Ch: " + ch + " Note: " + note_on + " Vel: " + vel);
  }
}

void keyReleased () { // キーを離した時 ↑Pressedのnote_onと同じnoteをnote_offに含めているか注意
  switch(key) {
    case 'w': note_off = 36; break; // space key
    case 'a': note_off = 38; break; // dorian_C_key
    case 's': note_off = 39; break; // w, a, s, d, f, g, space, L_click, R_click
    case 'd': note_off = 40; break;
    case 'f': note_off = 42; break;
    case 'g': note_off = 44; break;
    case ' ': note_off = 45; break;
    default: note_off = 0; break;
  }
  output.sendNoteOff(ch, note_off, vel); // NoteOffの送信
}