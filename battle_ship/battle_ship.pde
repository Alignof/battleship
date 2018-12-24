import controlP5.*;
import java.util.*;
//https://qiita.com/7of9/items/5aa617be2eb338bd6ba7
//https://qiita.com/7of9/items/be4a059faa7f4954817c
ControlP5 cp5,Textbox,Row,Column;
Textarea myTextarea;

PImage bg,cr,op,se,su,ba;

Button  Next,Attack,Select,Right;
Ship    Submarine,Cruiser,Battleship;

int[]  grid_x={145,215,285,355,425};
int[]  grid_y={108,178,248,318,388};
int phase=0;
int myCurrentIndex = 0;
String[] tokens;
String[] rows;
String[] columns;

void setup(){
        size(1200,675);
        smooth();
        noStroke();
        ellipseMode(CENTER);
        imageMode(CENTER);
        Next=new Button(1000,600,100,color(255,255,0),color(255,255,100));
        Attack=new Button(750,600,100,color(255,0,0),color(255,100,100));
        Select=new Button(1000,600,100,color(0,255,0),color(100,255,100));
        Right=new Button(500,600,100,color(0,255,255),color(100,255,255));

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
                        Next.display(Next.overCircle());
                        break;
                case 2:
                        background(bg);
                        Attack.display(Attack.overCircle());
                        Select.display(Select.overCircle());
                        Right.display(Right.overCircle());
                        Submarine.display(0);
                        Cruiser.display(1);
                        Battleship.display(2);
                        break;
        }
}

void mousePressed(){
        if(Next.overCircle()){
                if(phase==0){Set_textbox();}
                if(phase==1){Set_textarea();}
                phase++;
        }
}

void dropdown(int n) {
        myCurrentIndex = n;  
}

void row_list(int n) {
        myCurrentIndex = n;  
}

void column_list(int n) {
        myCurrentIndex = n;  
}

void Set_textbox(){
        tokens = new String[3];
        tokens[0] = "Submarine";
        tokens[1] = "cruiser";
        tokens[2] = "Battleship";

        List l = Arrays.asList(tokens[0], tokens[1], tokens[2]);

        Textbox.addScrollableList("dropdown")
                .setPosition(600, 100)
                .setSize(200, 200)
                .setBarHeight(50)
                .setItemHeight(50)
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
                .setPosition(900, 100)
                .setSize(80, 400)
                .setBarHeight(50)
                .setItemHeight(50)
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
                .setPosition(1080, 100)
                .setSize(80, 400)
                .setBarHeight(50)
                .setItemHeight(50)
                .addItems(n)
                // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
                ;
}

void Set_textarea(){

        myTextarea = cp5.addTextarea("txt")
                .setPosition(650,25)
                .setSize(500,300)
                .setFont(createFont("arial",12))
                .setLineHeight(14)
                .setColor(color(100,255,100))
                .setColorBackground(color(255,100))
                .setColorForeground(color(255,100));
        ;
        myTextarea.setText("Lorem Ipsum is simply dummy text of the printing and typesetting"
                        +" industry. Lorem Ipsum has been the industry's standard dummy text"
                        +" ever since the 1500s, when an unknown printer took a galley of type"
                        +" PageMaker including versions of Lorem Ipsum."
                        );

}

void Set_ship(){
        //Ship(x,y,HP,atk,mov);
        Submarine=new Ship(2,1,1,1,3);
        Cruiser=new Ship(3,3,2,2,2);
        Battleship=new Ship(5,2,3,3,1);
}

class Button{
        float x,y,diameter;
        color col,col_over;

        //Constructor
        Button(float  _x,float _y,float _d,color _col,color _over){
                x=_x;
                y=_y;
                diameter=_d;
                col=_col;
                col_over=_over;
        }

        //method
        void display(boolean over){
                if(over){
                        fill(col_over);
                }else{
                        fill(col);
                }
                ellipse(x,y,diameter,diameter);
        }

        boolean overCircle(){
                float disX=int(x)-mouseX;
                float disY=int(y)-mouseY;
                if(sqrt(sq(disX)+sq(disY))<diameter/2){
                        return true;
                }else{
                        return false;
                }
        }
}

class Ship{
        int x,y;
        int HP,atk,mov;

        //Constructor
        Ship(int _x,int _y,int _HP,int _atk,int _mov){
                x=_x-1;
                y=_y-1;
                HP=_HP;
                atk=_atk;
                mov=_mov;
        }

        //method
        void display(int type){
                switch(type){
                        case 0:
                                image(su,grid_x[x],grid_y[y]);
                                break;
                        case 1:
                                image(cr,grid_x[x],grid_y[y]);
                                break;
                        case 2:
                                image(ba,grid_x[x],grid_y[y]);
                                break;
                }
        }

        void move(int direction,int n){
                switch(direction){
                        //up
                        case 0: 
                                if(y-n>=0&&n<=mov){y-=n;}
                                break;
                                //down
                        case 1:
                                if(y+n<5&&n<=mov){y+=n;}
                                break;
                                //right
                        case 2:
                                if(y+n<5&&n<=mov){x+=n;}
                                break;
                                //left
                        case 3:
                                if(y-n>=0&&n<=mov){x-=n;}
                                break;
                }
        }

}
