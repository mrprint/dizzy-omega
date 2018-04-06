module unde.games.dizzy.omega.bug;

import derelict.opengl3.gl;

import std.conv;
import unde.games.object;
import unde.games.renderer;
import unde.games.collision_detector;
import unde.games.object;
import unde.global_state;

class Bug:StaticGameObject
{
    static int num;
    int number;

    bool killed;
    
    enum SPEED = 0.05;
    enum G = 0.03;
    enum MAX_V = 0.05;

    float def_x, def_y, def_z;
    float dx = SPEED, dy = 0.0;
    long frame;

    bool search_surface;

    this(MainGameObject root, float[3] coords, string bug_solid)
    {
        def_x = x = coords[0];
        def_y = y = coords[1];
        def_z = z = coords[2];
        number = num++;
        models["bug"] = root.models["bug"];
        collision_objects["solid"] = root.collision_objects[bug_solid];
        super(root);
    }

    bool walk_anim(GlobalState gs, string name)
    {
        float f = (frame*4)%120;
        float f2 = (frame*4)%240;
        float degree = 0.0;
        float translate = 0.0;
        
        if (f < 60.0)
            translate = -0.1 + 0.2*f/60.0;
        else if (f < 120.0)
            translate = 0.1 - 0.2*(f - 60.0)/60.0;

        if (f2 < 120.0)
            degree = f2/2 - 30.0;
        else if (f2 < 240.0)
            degree = 30.0 - (f2/2 - 60.0);
        
        if (name == "Bug-FL_Leg")
        {
            glTranslatef(0.5, 0.4, 0.0);
            glRotatef(degree, 0.0, 0.0, 1.0);
            glTranslatef(-0.5, -0.4, 0.0);
        }
        
        if (name == "Bug-FR_Leg")
        {
            glTranslatef(0.5, 0.4, 0.0);
            glRotatef(-degree, 0.0, 0.0, 1.0);
            glTranslatef(-0.5, -0.4, 0.0);
        }

        if (name == "Bug-BL_Leg")
        {
            glTranslatef(-0.5, 0.4, 0.0);
            glRotatef(-degree, 0.0, 0.0, 1.0);
            glTranslatef(0.5, -0.4, 0.0);
        }

        if (name == "Bug-BR_Leg")
        {
            glTranslatef(-0.5, 0.4, 0.0);
            glRotatef(degree, 0.0, 0.0, 1.0);
            glTranslatef(0.5, -0.4, 0.0);
        }
        
        if (name == "Bug-Head")
        {
            glTranslatef(0.8, 0.4, 0.0);
            glRotatef(degree/2, 0.0, 1.0, 0.0);
            glTranslatef(-0.8, -0.4, 0.0);
        }

        return true;
    }

    void kill()
    {
        killed = true;
    }

    override void draw(GlobalState gs)
    {
        glPushMatrix();
        glTranslatef(x, y, z);
        if (dx < 0) glRotatef(180,0,1,0);
        recursive_render(gs, models["bug"], &walk_anim);
        glPopMatrix();
    }

    immutable float side_sensor_dx = 1.0;
    immutable float[2] side_sensor_y = [0.5, 0.8];
    
    immutable float bottom_sensor_dx = 0.6;
    immutable float bottom_sensor_dy = 0.5;

    override bool tick(GlobalState gs)
    {
        frame++;
        x += dx;
        y += dy;

        if (dx < 0 && (if_intersect (collision_objects["solid"], [x-side_sensor_dx, y+side_sensor_y[0], z-side_sensor_dx, x, y+side_sensor_y[1], z+side_sensor_dx]) > 0))
        {
            dx = SPEED;
        }

        if (dx > 0 && (if_intersect (collision_objects["solid"], [x, y+side_sensor_y[0], z-side_sensor_dx, x+side_sensor_dx, y+side_sensor_y[1], z+side_sensor_dx]) > 0))
        {
            dx = -SPEED;
        }
        
        Intersect on_the_ground =
            if_intersect (collision_objects["solid"], [x-bottom_sensor_dx, y, z-bottom_sensor_dx, x+bottom_sensor_dx, y+bottom_sensor_dy, z+bottom_sensor_dx]);

        if (dy > -MAX_V)
        {
            dy -= G;
        }

        if (search_surface && on_the_ground == 0)
        {
            dy = 0;
            search_surface = false;
        }
        
        if (on_the_ground > 0 && (dy <= 0 || search_surface))
        {
            if (if_intersect (collision_objects["solid"], [x-bottom_sensor_dx, y+SPEED, z-bottom_sensor_dx, x+bottom_sensor_dx, y+SPEED+bottom_sensor_dy, z+bottom_sensor_dx]) > 0)
            {
                search_surface = true;
                dy = SPEED;
            }
            else if (on_the_ground > 0) dy = 0;
        }

        return true;
    }    

    override void load(string[string] s)
    {
        string p = "bug"~number.to!(string);
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
            dx = SPEED;

        if (p~"-dy" in s)
            dy = s[p~"-dy"].to!(float);
        else
            dy = 0.0;

        if (p in s)
        {
            killed = (s[p] == "killed");
        }
    }

    override void save(ref string[string] s)
    {
        string p = "bug"~number.to!(string);
        if (killed)
            s[p] = "killed";

        s[p~"-x"] = x.to!(string);
        s[p~"-y"] = y.to!(string);
        s[p~"-z"] = z.to!(string);
        s[p~"-dx"] = dx.to!(string);
        s[p~"-dy"] = dy.to!(string);
    }    
}
