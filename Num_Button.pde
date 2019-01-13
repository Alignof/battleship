class Num_Button{
        float x,y,rect_x,rect_y;
        color col,col_over,col_select;
        boolean select;
        
        //Constructor
        Num_Button(float  _x,float _y,float _rect_x,float _rect_y,color _select,color _over,color _col){
                x=_x;
                y=_y;
                rect_x=_rect_x;
                rect_y=_rect_y;
                col=_col;
                col_over=_over;
                col_select=_select;
        }

        //method
        void display(boolean over){
                if(over){
                        fill(col_over);
                }else if(select){
                        fill(col_select);
                }else{
                        fill(col);
                }
                rect(x,y,rect_x,rect_y);
        }
        boolean overRect(){
                if (mouseX >= x && mouseX <= x+rect_x && 
                                mouseY >= y && mouseY <= y+rect_y) {
                        return true;
                } else {
                        return false;
                }
        }
}
