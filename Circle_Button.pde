class Circle_Button{
        float x,y,diameter;
        color col,col_over;

        //Constructor
        Circle_Button(float  _x,float _y,float _d,color _col,color _over){
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
