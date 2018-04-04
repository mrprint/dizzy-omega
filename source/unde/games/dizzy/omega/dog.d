module unde.games.dizzy.omega.dog;

import derelict.assimp3.assimp;
import derelict.opengl3.gl;

import std.algorithm;
import std.conv;
import std.math;
import std.stdio;
import unde.games.dizzy.omega.main;
import unde.games.dizzy.omega.rope;
import unde.games.object;
import unde.games.renderer;
import unde.games.collision_detector;
import unde.games.object;
import unde.global_state;

class Dog:StaticGameObject
{
    static int num;
    int number;

    int hidden;
    
    enum SPEED = 0.1;
    enum MAX_V = 0.3;
    enum A = 0.01;
    enum STATE
    {
        WATCH,
        GO_UP,
        GO_RIGHT,
        CLOSE_MOUTH,
        GO_LEFT,
        GO_DOWN,
        OPEN_MOUTH,
        FLY_AWAY,
    }

    STATE state;

    float def_x, def_y, def_z;
    float dx = 0.0, dy = 0.0;
    long frame;
    long start_anim;
    int mouth;

    Rope rope;

    LiveGameObject the_hero;

    bool search_surface;
    static GLuint rope_texture;
    
    this(MainGameObject root, float[3] coords, float[3] rope_start, float by, uint length, float segl, LiveGameObject hero)
    {
        def_x = x = coords[0];
        def_y = y = coords[1];
        def_z = z = coords[2];
        the_hero = hero;
        number = num++;
        models["dog"] = root.models["dog"];
        //collision_objects["solid"] = root.collision_objects["solid"];

        rope = new Rope(root, rope_start, [x-1.4, y, z], by, length, segl);
        
        super(root);
    }

    void cut_rope()
    {
        rope.cut(2);
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
        
        if (name == "Dog-LeftWing")
        {
            glTranslatef(0.0, 0.4, 0.5);
            glRotatef(degree, 1.0, 0.0, 0.0);
            glTranslatef(0.0, -0.4, -0.5);
        }
        
        if (name == "Dog-RightWing")
        {
            glTranslatef(0.0, 0.4, -0.5);
            glRotatef(-degree, 1.0, 0.0, 0.0);
            glTranslatef(0.0, -0.4, 0.5);
        }
        
        if (name.startsWith("Dog-Head"))
        {
            if ((name[8] - '1') != mouth)
            {
                return false;
            }
        }

        return true;
    }

    void hide()
    {
        hidden++;
    }

    override void draw(GlobalState gs)
    {
        if ( abs(root.scrx-x) > 16.0 &&
             abs(root.scrx-def_x) > 16.0 ||
             abs(root.scry-y) > 9.0 )
            return;

        if (!hidden)
        {
            glPushMatrix();
            glTranslatef(x, y, z);
            if (dx > 0.0) glRotatef(180,0,1,0);
            recursive_render(gs, models["dog"], &fly_anim);
            glPopMatrix();
            
            rope.draw(gs);
        }
        else if (hidden == 1)
        {
            rope.draw_part(gs, 0, rope.cut_segm);
        }
    }

    immutable float side_sensor_dx = 1.0;
    immutable float[2] side_sensor_y = [0.5, 0.8];
    
    immutable float bottom_sensor_dx = 0.6;
    immutable float bottom_sensor_dy = 0.5;

    override bool tick(GlobalState gs)
    {
        if ( hidden || abs(root.scrx-x) > 16.0 &&
             abs(root.scrx-def_x) > 16.0 ||
             abs(root.scry-y) > 9.0 )
            return true;

        float speedfactor = 1.0;
        
        if (state != STATE.FLY_AWAY)
        {
            if (the_hero.x < x)
            {
                speedfactor = 0.5;
            }
            else if (the_hero.x < x+1.5)
            {
                speedfactor = the_hero.x - x;
            }
            else
                speedfactor = 2.0;
        }
        
        frame++;
        x += dx * speedfactor;
        y += dy * speedfactor;

        final switch (state)
        {
            case STATE.WATCH:
                float dhy = the_hero.y + 1.0 - y;
                if (dhy > 0.0 && dy < dhy/2.0 && dy < MAX_V)
                    dy += A;
                else if (dhy < 0.0 && dy > dhy/2.0 && dy > -MAX_V)
                    dy -= A;
                else dy = 0.0;
        
                if (the_hero.x + 4.5 > x)
                    the_hero.x = x - 4.5;

                if (abs(the_hero.x - x) < 7.0)
                {
                    long f = frame%200;
                    if (f < 10)
                        mouth = 1;
                    else if (f < 20)
                        mouth = 0;
                    else if (f < 30)
                        mouth = 1;
                    else if (f < 40)
                        mouth = 2;
                    else if (f < 50)
                        mouth = 1;
                    else if (f < 60)
                        mouth = 0;
                    else if (f < 70)
                        mouth = 1;
                    else
                        mouth = 2;
                }
                else mouth = 2;

                DizzyOmega dz = cast(DizzyOmega) root;
                if (dz.dizzy_throw_branch_quest_state == 2)
                {
                    mouth = 2;
                    dx = 0.000001;
                    dy = SPEED;
                    state = STATE.GO_UP;
                }
                
                if (rope.cut_segm >= 0)
                {
                    dx = -SPEED*1.5;
                    dy = SPEED*1.5/10;
                    z = -2.0;
                    state = STATE.FLY_AWAY;
                }
                
                break;
                
            case STATE.GO_UP:
                if (y > 0.9)
                {
                    state = STATE.GO_RIGHT;
                    dy = 0;
                    dx = SPEED;
                }
                break;
                
            case STATE.GO_RIGHT:
                if (x > 364.5)
                {
                    state = STATE.CLOSE_MOUTH;
                    start_anim = frame;
                    dy = 0;
                    dx = 0.00001;
                }
                else if (x > 364.2)
                {
                    mouth = 0;
                }
                else if (x > 364.0)
                {
                    mouth = 1;
                }

                break;

            case STATE.CLOSE_MOUTH:
                long f = frame - start_anim;
                if (f < 10)
                {
                    mouth = 1;
                    dx = -SPEED;
                    dy = 0;
                    state = STATE.GO_LEFT;
                }
                break;
                
            case STATE.GO_LEFT:
                if (x <= def_x)
                {
                    state = STATE.GO_DOWN;
                    dx = 0;
                    dy = -SPEED;
                }
                break;

            case STATE.GO_DOWN:
                if (y <= def_y)
                {
                    state = STATE.OPEN_MOUTH;
                    start_anim = frame;
                    dx = 0;
                    dy = 0;
                }
                break;

            case STATE.OPEN_MOUTH:
                long f = frame - start_anim;
                if (f < 20)
                {
                    mouth = 0;
                }
                else if (f < 30)
                {
                    mouth = 1;
                }
                else if (f < 40)
                {
                    mouth = 2;
                    if (rope.cut_segm < 0)
                        state = STATE.WATCH;
                    else
                    {
                        dx = -SPEED*1.5;
                        dy = SPEED*1.5/10;
                        z = -2.0;
                        state = STATE.FLY_AWAY;
                    }
                }
                break;
            case STATE.FLY_AWAY:
                if (x < 270.0)
                {
                    state = STATE.WATCH;
                    hide();
                }
        }

        if (rope.rope.length > 1)
        {
            float f = (frame*4)%240;
            float translate = 0.0;
            
            if (f < 120.0)
                translate = 0.2 - 0.4*f/120.0;
            else if (f < 240.0)
                translate = -0.2 + 0.4*(f - 120.0)/120.0;

            rope.rope[$-1] = [x-1.4, y+translate, z];
            rope.tick(gs);
        }

        return true;
    }    

    override void load(string[string] s)
    {
        string p = "dog"~number.to!(string);
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

        if (p~"-dy" in s)
            dy = s[p~"-dy"].to!(float);
        else
            dy = 0.0;

        if (p~"-state" in s)
            state = s[p~"-state"].to!(STATE);
        else
            state = STATE.WATCH;

        if (p in s)
        {
            hidden = (s[p] == "hidden-rope")?2:(s[p] == "hidden")?1:0;
        }
        else
        {
            hidden = 0;
        }

        rope.rope[$-1] = [x-1.4, y, z];
        rope.load(s);
    }

    override void save(ref string[string] s)
    {
        string p = "dog"~number.to!(string);
        if (hidden == 1)
            s[p] = "hidden";
        else if (hidden == 2)
            s[p] = "hidden-rope";

        s[p~"-x"] = x.to!(string);
        s[p~"-y"] = y.to!(string);
        s[p~"-z"] = z.to!(string);
        s[p~"-dx"] = dx.to!(string);
        s[p~"-dy"] = dy.to!(string);
        s[p~"-state"] = state.to!(string);

        rope.save(s);
    }    
}

