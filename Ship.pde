class Ship{
        int x,y;
        int HP,atk,mov;
        boolean alive=true;

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
                if(alive){
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
        }

        void move(int direction,int n){
                if(alive){
                        switch(direction){
                                //up
                                case 0: 
                                        if(y-n>=0&&n<=mov){y-=n;update();}
                                        break;
                                        //down
                                case 1:
                                        if(y+n<5&&n<=mov){y+=n;update();}
                                        break;
                                        //right
                                case 2:
                                        if(x+n<5&&n<=mov){x+=n;update();}
                                        break;
                                        //left
                                case 3:
                                        if(x-n>=0&&n<=mov){x-=n;update();}
                                        break;
                        }
                }
        }

        boolean around(int xx,int yy){
                if(alive){
                        if(abs(xx-x)<=1){
                                if(abs(yy-y)<=1){
                                        if(!(x==xx&&y==yy)){
                                                println("around true");
                                                return true;
                                        }
                                }
                        }
                }
                println("around false");
                return false;
        }

        boolean hit(int xx,int yy){
                if(alive){
                        if(x==xx&&y==yy){
                                return true;
                        }
                }
                return false;
        }

}
