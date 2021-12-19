
hpos, vpos = 0, 0
x_ac, y_ac = 0, 0
cont_y = 0

while(hpos <= 250 and vpos <= 250):
    if(hpos == 250 and vpos == 250):
        x_ac = 0
        y_ac = 0
    elif hpos == 250:
        x_ac += 1
        y_ac = 0
    elif cont_y == 5:
        y_ac += 1
        cont_y = 0
    else: 
        cont_y += 1
    
    if hpos == 250:
        vpos += 1
        hpos = 0
    hpos += 1
    print(x_ac, y_ac)