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

Direction_Button 	Up,Down,Right,Left;
Num_Button  		One,Two,Three;
Circle_Button  		Next,Attack,Select;
Ship    		Submarine,Cruiser,Battleship;

int[] grid_x={145,215,285,355,425};
int[] grid_y={118,188,258,328,398};
int ship_type;
int direction;
int n;
int tmp_x;
int tmp_y;
int turn=1;
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
        myRemoteLocation = new NetAddress("127.0.0.1", 4321);//IPaddress

        Next=new Circle_Button(1000,600,100,color(255,255,0),color(255,255,100));
        Attack=new Circle_Button(900,600,100,color(255,0,0),color(255,100,100));
        Select=new Circle_Button(1000,480,100,color(0,255,0),color(100,255,100));

        Up=new Direction_Button(660,350,40,110,color(255,255,0),color(255,255,100),color(127,127,0));
        Down=new Direction_Button(Up.x , (Up.y + Up.rect_x + Up.rect_y) , Up.rect_x , Up.rect_y ,Up.col_select,Up.col_over,Up.col);
        Right=new Direction_Button(Up.x+Up.rect_x , Up.y+Up.rect_y , Up.rect_y , Up.rect_x ,Up.col_select,Up.col_over,Up.col);
        Left=new Direction_Button(Up.x-Up.rect_y , Right.y , Up.rect_y , Up.rect_x ,Up.col_select,Up.col_over,Up.col);

        One=new Num_Button(480,500,50,40,color(255,0,255),color(255,100,255),color(127,0,127));
        Two=new Num_Button(480,545,100,40,color(255,0,255),color(255,100,255),color(127,0,127));
        Three=new Num_Button(480,590,150,40,color(255,0,255),color(255,100,255),color(127,0,127));

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
                        //                        println(mouseX);
                        //                        println(mouseY);
                        break;
                case 2:
                        background(bg);
                        Attack.display(Attack.overCircle());
                        Select.display(Select.overCircle());

                        Up.display(Up.overRect());
                        Down.display(Down.overRect());
                        Right.display(Right.overRect());
                        Left.display(Left.overRect());
                        fill(0,255,50);
                        ellipse(Right.x-Up.rect_x/2,Right.y+Up.rect_x/2,Up.rect_x*1.3,Up.rect_x*1.3);

                        One.display(One.overRect());
                        Two.display(Two.overRect());
                        Three.display(Three.overRect());

                        Submarine.display(0);
                        Cruiser.display(1);
                        Battleship.display(2);

                        fill(0,255,0);
                        ellipse(grid_x[tmp_x]+18,grid_y[tmp_y]-17,7,7);
                        break;
        }
}

void mousePressed(){
        if(Next.overCircle()){
                if(phase==0){
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
                        switch(ship_type){
                                case 0:
                                        Submarine.x=tmp_x;
                                        Submarine.y=tmp_y;
                                        break;
                                case 1:
                                        Cruiser.x=tmp_x;
                                        Cruiser.y=tmp_y;
                                        break;
                                case 2:
                                        Battleship.x=tmp_x;
                                        Battleship.y=tmp_y;
                                        break;
                        }        
                }else if(phase==2){
                        switch(ship_type){
                                case 0:
                                        Submarine.move(direction,n);
                                        break;
                                case 1:
                                        Cruiser.move(direction,n);
                                        break;
                                case 2:
                                        Battleship.move(direction,n);
                                        break;
                        } 
                }
        }else if(Attack.overCircle()){
                switch(ship_type){
                        case 0:
                                if(Submarine.around(tmp_x,tmp_y)&&n<=Submarine.atk){
                                        println("Submarine");
                                        OscMessage Attack_msg=new OscMessage("/Check/Attack");
                                        Attack_msg.add(tmp_x);
                                        Attack_msg.add(tmp_y);
                                        Attack_msg.add(Submarine.atk);
                                        oscP5.send(Attack_msg,myRemoteLocation);
                                        update();
                                }
                                break;
                        case 1:
                                if(Cruiser.around(tmp_x,tmp_y)&&n<=Cruiser.atk){
                                        //Attack
                                        OscMessage Attack_msg=new OscMessage("/Check/Attack");
                                        Attack_msg.add(tmp_x);
                                        Attack_msg.add(tmp_y);
                                        Attack_msg.add(Cruiser.atk);
                                        oscP5.send(Attack_msg,myRemoteLocation);
                                        update();
                                }
                                break;
                        case 2:
                                if(Battleship.around(tmp_x,tmp_y)&&n<=Battleship.atk){
                                        //Attack
                                        OscMessage Attack_msg=new OscMessage("/Check/Attack");
                                        Attack_msg.add(tmp_x);
                                        Attack_msg.add(tmp_y);
                                        Attack_msg.add(Battleship.atk);
                                        oscP5.send(Attack_msg,myRemoteLocation);
                                        update();
                                }
                                break;
                } 
        }else if(Right.overRect()){
                direction=2;
                this_true(direction);
        }else if(Left.overRect()){
                direction=3;
                this_true(direction);
        }else if(Up.overRect()){
                direction=0;
                this_true(direction);
        }else if(Down.overRect()){
                direction=1;
                this_true(direction);
        }else if(One.overRect()){
                n=1;
                One.select=true;
                Two.select=false;
                Three.select=false;
        }else if(Two.overRect()){
                n=2;
                Two.select=true;
                One.select=false;
                Three.select=false;
        }else if(Three.overRect()){
                n=3;
                Three.select=true;
                Two.select=false;
                One.select=false;
        }
}

public void check_Attack(int x, int y,int atk) {
        println(x+","+y);
        println("atk>>"+atk);
        if(Submarine.hit(x,y)){
                OscMessage Return_atk=new OscMessage("/Return/Attack");
                if(atk<Submarine.HP){
                        Return_atk.add(2);
                        oscP5.send(Return_atk,myRemoteLocation);
                }else{
                        Return_atk.add(3);
                        oscP5.send(Return_atk,myRemoteLocation);
                        Submarine.alive=false;
                }
                Submarine.HP-=atk;
        }else if(Cruiser.hit(x,y)){
                OscMessage Return_atk=new OscMessage("/Return/Attack");
                if(atk<Cruiser.HP){
                        Return_atk.add(2);
                        oscP5.send(Return_atk,myRemoteLocation);
                }else{
                        Return_atk.add(3);
                        oscP5.send(Return_atk,myRemoteLocation);
                        Cruiser.alive=false;
                }
                Cruiser.HP-=atk;
        }else if(Battleship.hit(x,y)){
                OscMessage Return_atk=new OscMessage("/Return/Attack");
                if(atk<Battleship.HP){
                        Return_atk.add(2);
                        oscP5.send(Return_atk,myRemoteLocation);
                }else{
                        Return_atk.add(3);
                        oscP5.send(Return_atk,myRemoteLocation);
                        Battleship.alive=false;
                }
                Battleship.HP-=atk;
        }else if(Submarine.around(x,y)||Cruiser.around(x,y)||Battleship.around(x,y)){
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

public void check_Move(int type,int direction){
        println(tokens[type]+">>"+direction_word[direction]);
}

void update(){
        turn++;
        Info.setText("Turn:"+turn+"\n");
}

void this_true(int direction){
        Right.select=false;
        Left.select=false;
        Up.select=false;
        Down.select=false;
        switch(direction){
                case 0:
                        Up.select=true;
                        break;
                case 1:
                        Down.select=true;
                        break;
                case 2:
                        Right.select=true;
                        break;
                case 3:
                        Left.select=true;
                        break;
        }
}

void set_display(){
        image(su,155+95*Submarine.x,175+95*Submarine.y);
        image(cr,155+95*Cruiser.x,175+95*Cruiser.y);
        image(ba,155+95*Battleship.x,175+95*Battleship.y);
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
        tokens[0] = "Submarine";
        tokens[1] = "cruiser";
        tokens[2] = "Battleship";

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
        myTextarea.setText("Your Battleship HP:"+Battleship.HP+"\n"
                        +"Your Cruiser HP:"+Cruiser.HP+"\n"
                        +"Your Submarine HP:"+Submarine.HP
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

        Info.setText("Turn:"+turn+"\n");
}

void Set_ship(){
        //Ship(x,y,HP,atk,mov);
        Submarine=new Ship(1,1,1,1,3);
        Cruiser=new Ship(3,3,2,2,2);
        Battleship=new Ship(2,2,3,3,1);
}
