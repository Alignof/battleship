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
Textarea log_area,Info;

PImage bg,cr,op,se,su,ba;

Direction_Button[]      dirB=new Direction_Button[4];
Num_Button[]            numB=new Num_Button[3];
Ship[]                  ship=new Ship[3];
Circle_Button  		Next,Attack,Select;

boolean My_turn;
boolean Is_first=true;
int[] grid_x={145,215,285,355,425};
int[] grid_y={118,188,258,328,398};
int ship_type;
int direction=0;
int n=1;
int tmp_x;
int tmp_y;
int Turn=1;
int phase=0;
int myCurrentIndex=0;
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
        oscP5.plug(this,"end_turn","/Turn/end");
        oscP5.plug(this,"give_up","/Turn/give_up");
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

        numB[0].select=true;
        dirB[0].select=true;
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

                        if(My_turn){
                                fill(200,200,200);
                        }else{
                                fill(60,60,60);
                        }

                        ellipse(505,250,50,50);

                        break;
        }
}

void mousePressed(){
        if(Next.overCircle()){
                if(phase==0){
                        if(Is_first){
                                OscMessage Im_first=new OscMessage("/Turn/first");
                                oscP5.send(Im_first,myRemoteLocation);
                                My_turn=true;
                                Is_first=true;
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
        log_area.append("[Rival] "+rows[y]+"-"+columns[x]+" atk:"+atk+"\n");

        for(int i=0;i<3;i++){
                if(ship[i].hit(x,y)){
                        OscMessage Return_atk=new OscMessage("/Return/Attack");
                        if(atk<ship[i].HP){
                                //hit
                                Return_atk.add(2);
                                oscP5.send(Return_atk,myRemoteLocation);
                                ship[i].HP-=atk;
                        }else{
                                //sink
                                Return_atk.add(3);
                                oscP5.send(Return_atk,myRemoteLocation);
                                ship[i].alive=false;
                                ship[i].HP=0;
                        }
                        return;
                }
        }

        if(ship[0].around(x,y)||ship[1].around(x,y)||ship[2].around(x,y)){
                OscMessage Return_atk=new OscMessage("/Return/Attack");
                //spray
                Return_atk.add(1);
                oscP5.send(Return_atk,myRemoteLocation);
        }else{
                OscMessage Return_atk=new OscMessage("/Return/Attack");
                //nothing
                Return_atk.add(0);
                oscP5.send(Return_atk,myRemoteLocation);

        }
}

public void disp_Result(int result){
        println(result_word[result]);
        log_area.append("[Your] "+rows[tmp_y]+"-"+columns[tmp_x]+" atk:"+n+" ----> "+result_word[result]+"\n");
}

public void turn_check(){
        My_turn=true;
}

public void end_turn(){
        //first player turn ++
        Turn++;
        Info.setText("Turn:"+Turn+"\n");
        Info.append("Your Battle ship HP:"+ship[2].HP+"\n"
                        +"Your Cruiser HP:"+ship[1].HP+"\n"
                        +"Your Submarine HP:"+ship[0].HP
                   );
}

public void set_turn(){
        My_turn=false;
        Is_first=false;
}

public void check_Move(int type,int direction){
        println(tokens[type]+">>"+direction_word[direction]);
        log_area.append("[Rival] "+tokens[type]+">>"+direction_word[direction]+"\n");
}

void move_data(int type,int direction){
        log_area.append("[Your] "+tokens[type]+">>"+n+direction_word[direction]+"\n");
        println("move_data");
        OscMessage Move_data=new OscMessage("/Check/Move");
        Move_data.add(type);
        Move_data.add(direction);
        oscP5.send(Move_data,myRemoteLocation);
}

void update(){
        if(!(Is_first)){
                Turn++;
                OscMessage Turn_end=new OscMessage("/Turn/end");
                oscP5.send(Turn_end,myRemoteLocation);
                Info.setText("Turn:"+Turn+"\n");
                Info.append("Your Battle ship HP:"+ship[2].HP+"\n"
                                +"Your Cruiser HP:"+ship[1].HP+"\n"
                                +"Your Submarine HP:"+ship[0].HP
                           );
        }
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
void Set_ship(){
        //Ship(x,y,HP,atk,mov);
        ship[0]=new Ship(1,1,1,1,3);
        ship[1]=new Ship(3,3,2,2,2);
        ship[2]=new Ship(2,2,3,3,1);
}
