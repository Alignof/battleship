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

        Type.addScrollableList("dropdown")
                .setPosition(600, 210)
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

        Rows.addScrollableList("row_list")
                .setPosition(860, 210)
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

        Columns.addScrollableList("column_list")
                .setPosition(1020, 210)
                .setFont(createFont("arial",18))
                .setSize(150, 400)
                .setBarHeight(35)
                .setItemHeight(30)
                .addItems(n)
                // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
                ;
}

void Set_textarea(){

        log_area = cp5.addTextarea("txt")
                .setPosition(500,10)
                .setSize(700,200)
                .setFont(createFont("arial",22))
                .setLineHeight(25)
                .setColor(color(100,255,100))
                .setColorBackground(color(255,100))
                .setColorForeground(color(255,100));
        ;
        log_area.setText("Attack log\n");

        //-------------------------------------------------------------------

        Info = cp5.addTextarea("txt_Info")
                .setPosition(10,450)
                .setSize(450,200)
                .setFont(createFont("arial",22))
                .setLineHeight(25)
                .setColor(color(100,255,255))
                .setColorBackground(color(255,100))
                .setColorForeground(color(255,100));
        ;

        Info.setText("Turn:"+Turn+"\n");
        Info.append("Your Battle ship HP:"+ship[2].HP+"\n"
                        +"Your Cruiser HP:"+ship[1].HP+"\n"
                        +"Your Submarine HP:"+ship[0].HP
                   );
}
