module unde.games.dizzy.omega.fish;

import derelict.opengl3.gl;
import std.conv;
import std.math;
import std.format;
import std.stdio;
import unde.games.object;
import unde.games.renderer;
import unde.global_state;

class Fish:StaticGameObject
{
    static int num;
    int number;
    
    int hidden;

    enum SPEED = 0.1;
    enum MAX_V = 0.3;
    enum JUMP_V = 0.2;
    enum A = 0.01;
    enum G = 0.004;

    float def_x, def_y, def_z;
    float dx = 0.0, dy = 0.0;
    float lx, rx, ty, gy;
    float size;
    float kspeed;

    ulong delay;
    
    this(MainGameObject root, float[3] coords, float lx, float rx,
        float size, float speed, float gy = float.nan, ulong delay = 0)
    {
        def_x = x = coords[0];
        def_y = y = coords[1];
        def_z = z = coords[2];

        this.lx = lx;
        this.rx = rx;
        this.size = size;
        this.gy = gy;
        this.delay = delay;
        kspeed = speed;
        number = num++;
        dx = SPEED*kspeed;

        if (!gy.isNaN) dy = JUMP_V;
        
        super(root);
    }

    void hide()
    {
        hidden = true;
    }

    override void draw(GlobalState gs)
    {
        if (!hidden && abs(x-root.scrx) < 32.0 &&
            abs(root.scry-y) < 18.0)
        {
            uint rf = cast(uint)(root.frame/7.5);
            uint frame = 0;
            if (rf % 8 == 1)
                frame = 1;
            if (rf % 8 == 2)
                frame = 2;
            if (rf % 8 == 3)
                frame = 1;
            if (rf % 8 == 5)
                frame = 3;
            if (rf % 8 == 6)
                frame = 4;
            if (rf % 8 == 7)
                frame = 3;

            glPushMatrix();
            glTranslatef(x, y, z);
            if (dx < 0.0) glRotatef(180,0,1,0);
            glRotatef(atan2(dy, 0.1f)*180/PI,0,0,1);
            glScalef(size, size, size);
            recursive_render(gs, root.models["fish-"~frame.to!(string)]);
            glPopMatrix();
        } 
    }    

    override bool tick(GlobalState gs)
    {
        if ( hidden || abs(root.scrx-x) > 16.0 &&
             abs(root.scrx-def_x) > 16.0 ||
             abs(root.scry-y) > 18.0 )
            return true;

        frame++;
        if (frame < delay) return true;
            
        x += dx;
        y += dy;

        if (!gy.isNaN)
        {
            if (y > gy) dy -= G;
            if (dy < -MAX_V) dy = -MAX_V;
            if (dy < 0 && y <= gy+.2)
                dy = (gy - y)*MAX_V;
        }
        else
        {
            if (x > rx)
                dx = -SPEED*kspeed;
            if (x < lx)
                dx = SPEED*kspeed;
        }
        return true;
    }

    override void load(string[string] s)
    {
        string p = "fish"~number.to!(string);
        if (p~"-x" in s)
            x = s[p~"-x"].to!(float);
        else
            x = def_x;
            
        if (p~"-y" in s)
            y = s[p~"-y"].to!(float);
        else
            y = def_y;
            
        if (p~"-z" in s)
            z = s[p~"-z"].to!(float);
        else
            z = def_z;

        if (p~"-dx" in s)
            dx = s[p~"-dx"].to!(float);
        else
            dx = SPEED*kspeed;

        if (p~"-dy" in s)
            dy = s[p~"-dy"].to!(float);
        else
        {
            dy = 0.0;
            if (!gy.isNaN) dy = JUMP_V;
        }

        frame = 0;

        if (p in s)
        {
            hidden = (s[p] == "hidden")?1:0;
        }
        else
        {
            hidden = 0;
        }
    }

    override void save(ref string[string] s)
    {
        string p = "fish"~number.to!(string);
        if (hidden == 1)
            s[p] = "hidden";

        s[p~"-x"] = x.to!(string);
        s[p~"-y"] = y.to!(string);
        s[p~"-z"] = z.to!(string);
        s[p~"-dx"] = dx.to!(string);
        s[p~"-dy"] = dy.to!(string);
        s[p~"-state"] = state.to!(string);

    }    
}
