module unde.games.dizzy.omega.grasshopper;

import derelict.opengl3.gl;

import std.conv;
import std.math;
import std.algorithm;
import std.stdio;
import unde.games.object;
import unde.games.renderer;
import unde.games.collision_detector;
import unde.games.object;
import unde.global_state;

class Grasshopper:StaticGameObject
{
    static int num;
    int number;

    bool killed;
    bool sprayed;
    
    enum SPEED = 0.1;
    enum G = 0.01;
    enum MAX_V = 0.1;
    enum JUMP_V = 0.25;

    float def_x, def_y, def_z;
    int dir = 1;
    float dx = 0.0, dy = 0.0;
    long frame;
    long start_jump_frame;
    long end_jump_frame;
    long stopped_frame = 1;

    bool solid;

    LiveGameObject the_hero;

    string grasshopper_solid, grasshopper_solid1;

    this(MainGameObject root, float[3] coords, string grasshopper_solid,
        string grasshopper_solid1, LiveGameObject the_hero)
    {
        def_x = x = coords[0];
        def_y = y = coords[1];
        def_z = z = coords[2];
        number = num++;
        for (int i=0; i < 6; i++)
        {
            models["grasshopper-"~i.to!(string)] = root.models["grasshopper-"~i.to!(string)];
        }
        collision_objects["solid"] = root.collision_objects[grasshopper_solid];

        this.grasshopper_solid = grasshopper_solid;
        this.grasshopper_solid1 = grasshopper_solid1;
        
        this.the_hero = the_hero;
        super(root);
    }

    void change_solid(bool i)
    {
        solid = i;
        if (i) collision_objects["solid"] = root.collision_objects[grasshopper_solid1];
        else collision_objects["solid"] = root.collision_objects[grasshopper_solid];
    }

    void kill()
    {
        killed = true;
    }

    void spray()
    {
        sprayed = true;
    }

    override void draw(GlobalState gs)
    {
        if (killed) return;
        
        glPushMatrix();
        glTranslatef(x, y, z);
        if (dir < 0) glRotatef(180,0,1,0);
        long fr;
        if (start_jump_frame > 0)
            fr = (cast(long)min((frame - start_jump_frame)/2, 5));
        if (end_jump_frame > 0)
            fr = (cast(long)max(5 - (frame - end_jump_frame)/2, 0));
        //writefln("grasshopper (%s, %s, %s)", x, y, z);
        recursive_render(gs, models["grasshopper-"~fr.to!(string)]);
        glPopMatrix();
    }

    immutable float side_sensor_dx = 1.0;
    immutable float[2] side_sensor_y = [0.5, 0.8];
    
    immutable float bottom_sensor_dx = 0.6;
    immutable float bottom_sensor_dy = 0.5;

    immutable float jump_sensor_dx = 0.6;
    immutable float jump_sensor_dy = 1.0;

    override bool tick(GlobalState gs)
    {
        if (killed) return true;
        
        frame++;
        x += dx;
        y += dy;

        if (collision_objects["solid"] is null) return true;

        if (the_hero is null)
        {
            if (if_intersect (collision_objects["solid"], [x, y+side_sensor_y[0], z-5*side_sensor_dx, x+side_sensor_dx, y+side_sensor_y[1], z+5*side_sensor_dx]) > 0 ||
                (the_hero !is null && the_hero.x - 1.5 < x+side_sensor_dx && x+side_sensor_dx < the_hero.x + 1.5 &&
                    the_hero.y < y && y < the_hero.y + 2.5))
            {
                dx = SPEED/10;
                dir = 1;
            }
        }
        else
        {
            if (dx < 0 && (if_intersect (collision_objects["solid"], [x-side_sensor_dx, y+side_sensor_y[0], z-side_sensor_dx, x, y+side_sensor_y[1], z+side_sensor_dx]) > 0 ||
                (the_hero !is null && the_hero.x - 1.5 < x-side_sensor_dx && x-side_sensor_dx < the_hero.x + 1.5 &&
                    the_hero.y < y && y < the_hero.y + 2.5)))
            {
                dx = SPEED;
                dir = 1;
            }
            else if (dx > 0 && (if_intersect (collision_objects["solid"], [x, y+side_sensor_y[0], z-side_sensor_dx, x+side_sensor_dx, y+side_sensor_y[1], z+side_sensor_dx]) > 0 ||
                (the_hero !is null && the_hero.x - 1.5 < x+side_sensor_dx && x+side_sensor_dx < the_hero.x + 1.5 &&
                    the_hero.y < y && y < the_hero.y + 2.5)))
            {
                dx = -SPEED;
                dir = -1;
            }
        }

        Intersect on_the_ground =
            if_intersect (collision_objects["solid"], [x-bottom_sensor_dx, y, z-5*bottom_sensor_dx, x+bottom_sensor_dx, y+bottom_sensor_dy, z+5*bottom_sensor_dx]);

        Intersect ground_soon =
            if_intersect (collision_objects["solid"], [x-jump_sensor_dx, y-jump_sensor_dy, z-5*jump_sensor_dx, x+jump_sensor_dx, y, z+5*jump_sensor_dx]);

        if (stopped_frame == 0 && dy > -MAX_V)
        {
            dy -= G;
        }

        if (stopped_frame > 0 && frame - stopped_frame > 150)
        {
            stopped_frame = 0;
            start_jump_frame = frame;
            dx = SPEED * dir;
            dy = JUMP_V;
        }
        
        if (start_jump_frame > 0 && dy < 0 && ground_soon > 0)
        {
            start_jump_frame = 0;
            end_jump_frame = frame;
        }

        if (end_jump_frame > 0 && on_the_ground > 0)
        {
            dx = 0;
            dy = 0;
            end_jump_frame = 0;
            stopped_frame = frame;
        }
        
        return true;
    }    

    override void load(string[string] s)
    {
        string p = "grasshopper"~number.to!(string);
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
            dx = 0.0;

        if (dx < 0) dir = -1;
        else if (dx > 0) dir = 1;

        if (p~"-dy" in s)
            dy = s[p~"-dy"].to!(float);
        else
            dy = 0.0;

        if (p~"-frame" in s)
            frame = s[p~"-frame"].to!(long);
        else
            frame = 0;

        if (p~"-start_jump_frame" in s)
            start_jump_frame = s[p~"-start_jump_frame"].to!(long);
        else
            start_jump_frame = 0;

        if (p~"-end_jump_frame" in s)
            end_jump_frame = s[p~"-end_jump_frame"].to!(long);
        else
            end_jump_frame = 0;

        if (p~"-stopped_frame" in s)
            stopped_frame = s[p~"-stopped_frame"].to!(long);
        else
            stopped_frame = 1;

        if (p~"-solid" in s)
            solid = (s[p~"-solid"] == "pit");
        else
            solid = false;

        change_solid(solid);

        if (p in s)
        {
            killed = (s[p] == "killed");
        }
        else
            killed = false;

        if (p~"-s" in s)
        {
            sprayed = (s[p~"-s"] == "sprayed");
        }
        else
            sprayed = false;
    }

    override void save(ref string[string] s)
    {
        string p = "grasshopper"~number.to!(string);
        if (killed)
            s[p] = "killed";

        if (sprayed)
            s[p~"-s"] = "sprayed";

        s[p~"-x"] = x.to!(string);
        s[p~"-y"] = y.to!(string);
        s[p~"-z"] = z.to!(string);
        s[p~"-dx"] = dx.to!(string);
        s[p~"-dy"] = dy.to!(string);
        s[p~"-frame"] = frame.to!(string);
        s[p~"-start_jump_frame"] = start_jump_frame.to!(string);
        s[p~"-end_jump_frame"] = end_jump_frame.to!(string);
        s[p~"-stopped_frame"] = stopped_frame.to!(string);
        if (solid)
            s[p~"-solid"] = "pit";
    }    
}
