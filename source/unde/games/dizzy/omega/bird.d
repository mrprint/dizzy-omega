module unde.games.dizzy.omega.bird;

import derelict.opengl3.gl;

import std.algorithm;
import std.conv;
import std.math;
import std.stdio;
import unde.games.dizzy.omega.dizzy;
import unde.games.dizzy.omega.main;
import unde.games.object;
import unde.games.renderer;
import unde.games.collision_detector;
import unde.games.object;
import unde.global_state;

class Bird:StaticGameObject
{
    static int num;
    int number;

    int hidden;
    
    enum SPEED = 0.1;
    enum G = 0.02;
    enum MAX_V = 0.3;
    enum A = 0.01;

    float def_x, def_y, def_z;
    float dx = 0.0, dy = 0.0;
    float rx;

    int fly;

    float[7][3] flame_coords;

    Dizzy the_hero;

    bool search_surface;
    static GLuint rope_texture;
    ulong delay;

    this(MainGameObject root, float[3] coords, float rx, Dizzy hero, ulong delay = 0)
    {
        def_x = x = coords[0];
        def_y = y = coords[1];
        def_z = z = coords[2];
        this.rx = rx;
        this.delay = delay;
        the_hero = hero;
        number = num++;
        models["bird"] = root.models["bird"];
        models["flame"] = root.models["flame"];
        dx = SPEED;

        collision_objects["solid"] = root.collision_objects["solid"];
        super(root);
    }

    void start_fly()
    {
        fly = 1;
    }

    void fall()
    {
        fly = 2;
    }

    bool fly_anim(GlobalState gs, string name)
    {
        float f = (frame*4)%240;
        float degree = 0.0;
        float translate = 0.0;
        
        if (f < 120.0)
            translate = 0.2 - 0.4*f/120.0;
        else if (f < 240.0)
            translate = -0.2 + 0.4*(f - 120.0)/120.0;

        if (f < 120.0)
            degree = f/2 - 30.0;
        else if (f < 240.0)
            degree = 30.0 - (f/2 - 60.0);

        glTranslatef(0.0, translate, 0.0);
        
        if (name == "BirdLeftWing")
        {
            glRotatef(degree, -1.0, 0.0, 0.0);
        }
        
        if (name == "BirdRightWing")
        {
            glRotatef(-degree, -1.0, 0.0, 0.0);
        }
        
        return true;
    }

    void hide()
    {
        hidden++;
    }

    override void draw(GlobalState gs)
    {
        if ( abs(root.scrx-x) > 32.0 &&
             abs(root.scry-y) > 18.0 )
            return;

        if (!hidden)
        {
            glPushMatrix();
            glTranslatef(x, y, z);
            glRotatef(atan2(dy, dx)*180/PI,0,1,0);
            recursive_render(gs, models["bird"], &fly_anim);
            glPopMatrix();

            foreach(flame; flame_coords)
            {
                if (!flame[0].isNaN())
                {
                    glPushMatrix();
                    glTranslatef(flame[0], flame[1], flame[2]);
                    glScalef(flame[3], flame[3], flame[3]);
                    recursive_render(gs, models["flame"]);
                    glPopMatrix();
                }
            }
        }
    }

    override bool tick(GlobalState gs)
    {
        if ( hidden || abs(root.scrx-x) > 32.0 &&
                abs(root.scry-y) > 18.0 )
            return true;

        frame++;

        if (frame < delay) return true;
        
        x += dx;
        y += dy;

        if (the_hero is null) return true;        

        foreach (ref flame; flame_coords)
        {
            if (!flame[0].isNaN())
            {
                flame[0..3] += flame[4..7];
                flame[3] += 0.02;

                if (abs(the_hero.x - flame[0]) < 1.5 &&
                    flame[1] > the_hero.y &&
                    flame[1] < the_hero.y+2.5)
                {
                    the_hero.energy -= 1;
                    if (the_hero.energy <= 0.0)
                    {
                        the_hero.die("Flame");
                    }
                }
            }
        }

        if (!flame_coords[0][0].isNaN() && 
             flame_coords[0][3] > 1.0)
        {
            flame_coords[2] = flame_coords[1];
            flame_coords[1] = flame_coords[0];
            flame_coords[0] = flame_coords[0].init;
        }
        else if (!flame_coords[1][0].isNaN() && 
             flame_coords[1][3] > 1.5)
        {
            flame_coords[2] = flame_coords[1];
            flame_coords[1] = flame_coords[1].init;
        }
        else if (!flame_coords[2][0].isNaN() && 
             flame_coords[2][3] > 2.0)
        {
            flame_coords[2] = flame_coords[2].init;
        }

        if ((dx > 0 && the_hero.x > (x+3.0) &&
            the_hero.x - (x+3.0) < 7.0 ||
             dx < 0 && the_hero.x < (x-3.0) &&
            (x-3.0) - the_hero.x < 7.0) &&
            abs(the_hero.y - y) < 3.0 )
        {
            if (flame_coords[0][0].isNaN())
            {
                flame_coords[0] = [x + dx*36, y, z,
                    0.5, 2*dx, 2*dy, 0];
            }
        }

        if (fly == 1)
        {
            dx = the_hero.x - x;
            dy = the_hero.y+2.0 - y;
            float l = sqrt(dx^^2 + dy^^2);
            float s = SPEED * (l/20.0);
            if (s > 2.0*SPEED) s = 2.0*SPEED;
            if (s < 0.5*SPEED) s = 0.5*SPEED;
            l /= s;
            dx /= l;
            dy /= l;
            z = -5.0;
        }
        else if (fly == 2)
        {
            dy -= G;
            if (dy < -MAX_V) dy = -MAX_V;

            float x0 = x-0.5;
            float x1 = x+0.5;
            float y0 = y-0.5;
            float y1 = y+0.5;
            float z0 = z-8.0;
            float z1 = z+8.0;

            auto mb = if_intersect (collision_objects["solid"], [x0, y0, z0, x1, y1, z1]);
            if (mb > 0 || y < -6.0)
            {
                DizzyOmega dz = cast(DizzyOmega) root;
                dz.bird_item.x = x;
                dz.bird_item.y = y;
                dz.bird_item.z = 0;
                dz.track = 1;
                dz.play_music();
                hide();
            }
        }
        else
        {
            if (x > rx)
                dx = -SPEED;
            if (x < def_x)
                dx = SPEED;
        }

        return true;
    }    

    override void load(string[string] s)
    {
        string p = "bird"~number.to!(string);
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

        if (p~"-fly" in s)
            fly = s[p~"-fly"].to!(int);
        else
            fly = 0;

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
        string p = "bird"~number.to!(string);
        if (hidden == 1)
            s[p] = "hidden";
        if (fly > 0)
            s[p~"-fly"] = fly.to!(string);

        s[p~"-x"] = x.to!(string);
        s[p~"-y"] = y.to!(string);
        s[p~"-z"] = z.to!(string);
        s[p~"-dx"] = dx.to!(string);
        s[p~"-dy"] = dy.to!(string);
        s[p~"-state"] = state.to!(string);
    }    
}

