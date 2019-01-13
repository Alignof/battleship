import oscP5.*;
import netP5.*;
//http://www.everykz.com/blog/2013/08/24/157
import controlP5.*;
import java.util.*;
//https://qiita.com/7of9/items/5aa617be2eb338bd6ba7
//https://qiita.com/7of9/items/be4a059faa7f4954817c

OscP5 oscP5;
NetAddress myRemoteLocation;
ControlP5 cp5,Textbox,Row,Column;
Textarea myTextarea,Info;

PImage bg,cr,op,se,su,ba;

Direction_Button[]      dirB=new Direction_Button[4];
Num_Button[]            numB=new Num_Button[3];
Ship[]                  ship=new Ship[3];
Circle_Button  		Next,Attack,Select;

boolean My_turn;
int[] grid_x={145,215,285,355,425};
int[] grid_y={118,188,258,328,398};
int ship_type;
int direction;
int n;
int tmp_x;
int tmp_y;
int Turn=0;
int phase=0;
int myCurrentIndex = 0;
String[] tokens;
String[] rows;
String[] columns;
String[] result_word={"nothing","spray","hit","sink"};
String[] direction_word={"Up","Down","Right","Left"};

void setup(){
        size(1200,675);
        smooth();
        noStroke();
        ellipseMode(CENTER);
        imageMode(CENTER);

        oscP5 = new OscP5(this,1234);//my port num
        oscP5.plug(this,"check_Attack","/Check/Attack");
        oscP5.plug(this,"check_Move","/Check/Move");
        oscP5.plug(this,"disp_Result","/Return/Attack");
        oscP5.plug(this,"set_turn","/Turn/first");
        oscP5.plug(this,"turn_check","/Turn/your");
        myRemoteLocation = new NetAddress("127.0.0.1", 4321);//IPaddress

        Next=new Circle_Button(1000,600,100,color(255,255,0),color(255,255,100));
        Attack=new Circle_Button(900,600,100,color(255,0,0),color(255,100,100));
        Select=new Circle_Button(1000,480,100,color(0,255,0),color(100,255,100));

        dirB[0]=new Direction_Button(660,350,40,110,color(255,255,0),color(255,255,100),color(127,127,0));
        dirB[1]=new Direction_Button(dirB[0].x , (dirB[0].y + dirB[0].rect_x + dirB[0].rect_y) , dirB[0].rect_x , dirB[0].rect_y ,dirB[0].col_select,dirB[0].col_over,dirB[0].col);
        dirB[2]=new Direction_Button(dirB[0].x+dirB[0].rect_x , dirB[0].y+dirB[0].rect_y , dirB[0].rect_y , dirB[0].rect_x ,dirB[0].col_select,dirB[0].col_over,dirB[0].col);
        dirB[3]=new Direction_Button(dirB[0].x-dirB[0].rect_y , dirB[2].y , dirB[0].rect_y , dirB[0].rect_x ,dirB[0].col_select,dirB[0].col_over,dirB[0].col);

        numB[0]=new Num_Button(480,500,50,40,color(255,0,255),color(255,100,255),color(127,0,127));
        numB[1]=new Num_Button(480,545,100,40,color(255,0,255),color(255,100,255),color(127,0,127));
        numB[2]=new Num_Button(480,590,150,40,color(255,0,255),color(255,100,255),color(127,0,127));

        Set_ship();

        cp5 = new ControlP5(this);
        Textbox = new ControlP5(this);
        Row = new ControlP5(this);
        Column = new ControlP5(this);

        bg=loadImage("background_resize.png");
        op=loadImage("opening_resize.png");
        se=loadImage("set_battleship_resize.png");
        su=loadImage("submarine_resize.png");
        cr=loadImage("cruiser_resize.png");
        ba=loadImage("battleship_resize.png");

}

void draw(){
        switch(phase){
                case 0:
                        background(op);
                        Next.display(Next.overCircle());
                        break;
                case 1: 
                        background(se);
                        set_display();
                        Select.display(Select.overCircle());
                        Next.display(Next.overCircle());
                        break;
                case 2:
                        background(bg);
                        Attack.display(Attack.overCircle());
                        Select.display(Select.overCircle());

                        dirB[0].display(dirB[0].overRect());
                        dirB[1].display(dirB[1].overRect());
                        dirB[2].display(dirB[2].overRect());
                        dirB[3].display(dirB[3].overRect());
                        fill(0,255,50);
                        ellipse(dirB[2].x-dirB[0].rect_x/2,dirB[2].y+dirB[0].rect_x/2,dirB[0].rect_x*1.3,dirB[0].rect_x*1.3);

                        numB[0].display(numB[0].overRect());
                        numB[1].display(numB[1].overRect());
                        numB[2].display(numB[2].overRect());

                        ship[0].display(0);
                        ship[1].display(1);
                        ship[2].display(2);

                        fill(0,255,0);
                        ellipse(grid_x[tmp_x]+18,grid_y[tmp_y]-17,7,7);
                        break;
        }
}

void mousePressed(){
        if(Next.overCircle()){
                if(phase==0){
                        if(Turn==0){
                                OscMessage Im_first=new OscMessage("/Turn/first");
                                oscP5.send(Im_first,myRemoteLocation);
                                My_turn=true;
                        }
                        Set_textbox();
                }
                if(phase==1){
                        Set_textarea();
                        Select.y=600;
                        Select.x=1075;
                }
                phase++;
        }else if(Select.overCircle()){
                if(phase==1){
                        ship[ship_type].x=tmp_x;
                        ship[ship_type].y=tmp_y;
                }else if(phase==2){
                        if(My_turn){
                                ship[ship_type].move(direction,n);
                        }
                }
        }else if(Attack.overCircle()){
                if(My_turn){
                        if(ship[ship_type].around(tmp_x,tmp_y)&&n<=ship[ship_type].atk){
                                OscMessage Attack_msg=new OscMessage("/Check/Attack");
                                Attack_msg.add(tmp_x);
                                Attack_msg.add(tmp_y);
                                Attack_msg.add(ship[ship_type].atk);
                                oscP5.send(Attack_msg,myRemoteLocation);
                                update();
                        }
                }
        }
  
        for(int i=0;i<4;i++){
                if(dirB[i].overRect()){
                        direction=i;
                        this_true(direction);
                        break;
                }
        }
        
        if(numB[0].overRect()){
                n=1;
                numB[0].select=true;
                numB[1].select=false;
                numB[2].select=false;
        }else if(numB[1].overRect()){
                n=2;
                numB[0].select=false;
                numB[1].select=true;
                numB[2].select=false;
        }else if(numB[2].overRect()){
                n=3;
                numB[0].select=false;
                numB[1].select=false;
                numB[2].select=true;
        }
}

public void check_Attack(int x, int y,int atk) {
        println(x+","+y);
        println("atk>>"+atk);
        
        for(int i=0;i<3;i++){
                if(ship[i].hit(x,y)){
                        OscMessage Return_atk=new OscMessage("/Return/Attack");
                        if(atk<ship[i].HP){
                                Return_atk.add(2);
                                oscP5.send(Return_atk,myRemoteLocation);
                        }else{
                                Return_atk.add(3);
                                oscP5.send(Return_atk,myRemoteLocation);
                                ship[i].alive=false;
                        }
                        ship[i].HP-=atk;
                }
        }
        if(ship[0].around(x,y)||ship[1].around(x,y)||ship[2].around(x,y)){
                OscMessage Return_atk=new OscMessage("/Return/Attack");
                Return_atk.add(1);
                oscP5.send(Return_atk,myRemoteLocation);
        }else{
                OscMessage Return_atk=new OscMessage("/Return/Attack");
                Return_atk.add(0);
                oscP5.send(Return_atk,myRemoteLocation);

        }
}

public void disp_Result(int result){
        println(result_word[result]);
}

public void turn_check(){
        My_turn=true;
}

public void set_turn(){
        My_turn=false;
}

public void check_Move(int type,int direction){
        println(tokens[type]+">>"+direction_word[direction]);
}

void update(){
        Turn++;
        Info.setText("Turn:"+Turn+"\n");
        OscMessage Your_turn=new OscMessage("/Turn/your");
        oscP5.send(Your_turn,myRemoteLocation);
        My_turn=false;
}

void this_true(int direction){
        dirB[0].select=false;
        dirB[1].select=false;
        dirB[2].select=false;
        dirB[3].select=false;
        dirB[direction].select=true;
}
void set_display(){
        image(su,155+95*ship[0].x,175+95*ship[0].y);
        image(cr,155+95*ship[1].x,175+95*ship[1].y);
        image(ba,155+95*ship[2].x,175+95*ship[2].y);
}

void dropdown(int n) {
        println(n);
        myCurrentIndex = n;
        ship_type=n;
}

void row_list(int o) {
        println(o);
        myCurrentIndex = o;
        tmp_y=o;
}

void column_list(int p) {
        println(p);
        myCurrentIndex = p; 
        tmp_x=p;
}

void Set_textbox(){
        tokens = new String[3];
        tokens[0] = "submarine";
        tokens[1] = "cruiser";
        tokens[2] = "battleship";

        List l = Arrays.asList(tokens[0], tokens[1], tokens[2]);

        Textbox.addScrollableList("dropdown")
                .setPosition(550, 210)
                .setFont(createFont("arial",18))
                .setSize(250, 200)
                .setBarHeight(35)
                .setItemHeight(30)
                .addItems(l)
                // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
                ;

        rows = new String[5];
        rows[0] = "1";
        rows[1] = "2";
        rows[2] = "3";
        rows[3] = "4";
        rows[4] = "5";

        List m = Arrays.asList(rows[0], rows[1], rows[2], rows[3], rows[4]);

        Textbox.addScrollableList("row_list")
                .setPosition(820, 210)
                .setFont(createFont("arial",18))
                .setSize(150, 400)
                .setBarHeight(35)
                .setItemHeight(30)
                .addItems(m)
                // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
                ;

        columns = new String[5];
        columns[0] = "A";
        columns[1] = "B";
        columns[2] = "C";
        columns[3] = "D";
        columns[4] = "E";

        List n = Arrays.asList(columns[0], columns[1], columns[2], columns[3], columns[4]);

        Textbox.addScrollableList("column_list")
                .setPosition(990, 210)
                .setFont(createFont("arial",18))
                .setSize(150, 400)
                .setBarHeight(35)
                .setItemHeight(30)
                .addItems(n)
                // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
                ;
}

void Set_textarea(){

        myTextarea = cp5.addTextarea("txt")
                .setPosition(500,10)
                .setSize(700,200)
                .setFont(createFont("arial",22))
                .setLineHeight(25)
                .setColor(color(100,255,100))
                .setColorBackground(color(255,100))
                .setColorForeground(color(255,100));
        ;
        myTextarea.setText("Your Battle ship HP:"+ship[2].HP+"\n"
                        +"Your Cruiser HP:"+ship[1].HP+"\n"
                        +"Your Submarine HP:"+ship[0].HP
                        );

        //-------------------------------------------------------------------

        Info = cp5.addTextarea("txt_Info")
                .setPosition(10,450)
                .setSize(450,200)
                .setFont(createFont("arial",18))
                .setLineHeight(20)
                .setColor(color(255,100,100))
                .setColorBackground(color(255,100))
                .setColorForeground(color(255,100));
        ;

        Info.setText("Turn:"+Turn+"\n");
}

void Set_ship(){
        //Ship(x,y,HP,atk,mov);
        ship[0]=new Ship(1,1,1,1,3);
        ship[1]=new Ship(3,3,2,2,2);
        ship[2]=new Ship(2,2,3,3,1);
}
