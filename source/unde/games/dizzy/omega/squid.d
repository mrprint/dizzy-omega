module unde.games.dizzy.omega.squid;

import derelict.opengl3.gl;
import std.conv;
import std.math;
import std.format;
import unde.games.object;
import unde.games.renderer;
import unde.global_state;

class Squid:StaticGameObject
{
    static int num;
    int number;
    
    int hidden;

    enum SPEED = 0.1;
    enum MAX_V = 0.02;
    enum A = 0.00075;

    float def_x, def_y, def_z;
    float dx = 0.0, dy = 0.0;
    float by, sy;
    ulong delay;
    
    this(MainGameObject root, float[3] coords, float by,
        float sy = float.nan, float dx = 0.0, ulong delay = 0)
    {
        def_x = x = coords[0];
        def_y = y = coords[1];
        def_z = z = coords[2];

        this.by = by;
        number = num++;
        dy = 0.0;
        this.dx = dx;
        this.delay = delay;
        this.sy = sy;
        if (!sy.isNaN) y = sy;
        
        super(root);
    }

    override void draw(GlobalState gs)
    {
        if (!hidden && abs(x-root.scrx) < 32 &&
            abs(y-root.scry) < 18)
        {
            uint frame = 0;
            float dy = by - def_y;
            if (y - def_y < dy/11)
                frame = 0;
            if (y - def_y < dy/11*2)
                frame = 1;
            if (y - def_y < dy/11*3)
                frame = 2;
            if (y - def_y < dy/11*4)
                frame = 3;
            if (y - def_y < dy/11*5)
                frame = 4;
            if (y - def_y < dy/11*6)
                frame = 5;
            if (y - def_y < dy/11*7)
                frame = 6;
            if (y - def_y < dy/11*8)
                frame = 7;
            if (y - def_y < dy/11*9)
                frame = 8;
            if (y - def_y < dy/11*10)
                frame = 9;
            if (y - def_y < dy)
                frame = 10;

            glDisable(GL_DEPTH_TEST);
            glDisable(GL_CULL_FACE);
            glPushMatrix();
            glTranslatef(x, y, z);
            recursive_render(gs, root.models["squid-"~frame.to!(string)], null, null, false, true);
            glPopMatrix();
            glEnable(GL_DEPTH_TEST);
            glEnable(GL_CULL_FACE);
        } 
    }

    void hide()
    {
        hidden = true;
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

        dy -= A;
        if (sy.isNaN && dy < -MAX_V) dy = -MAX_V;
        
        if (y < by)
            dy = SPEED;
        return true;
    }

    override void load(string[string] s)
    {
        string p = "squid"~number.to!(string);
        if (p~"-x" in s)
            x = s[p~"-x"].to!(float);
        else
            x = def_x;
            
        if (p~"-y" in s)
            y = s[p~"-y"].to!(float);
        else
        {
            y = def_y;
            if (!sy.isNaN) y = sy;
        }
            
        if (p~"-z" in s)
            z = s[p~"-z"].to!(float);
        else
            z = def_z;

        /*if (p~"-dx" in s)
            dx = s[p~"-dx"].to!(float);
        else
            dx = 0.0;*/

        if (p~"-dy" in s)
            dy = s[p~"-dy"].to!(float);
        else
            dy = 0.0;

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
        string p = "squid"~number.to!(string);
        if (hidden == 1)
            s[p] = "hidden";

        s[p~"-x"] = x.to!(string);
        s[p~"-y"] = y.to!(string);
        s[p~"-z"] = z.to!(string);
        //s[p~"-dx"] = dx.to!(string);
        s[p~"-dy"] = dy.to!(string);
        s[p~"-state"] = state.to!(string);
    }    
}
