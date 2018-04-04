module unde.games.dizzy.omega.dizzy;

import derelict.assimp3.assimp;
import derelict.opengl3.gl;
import derelict.sdl2.mixer;
import std.algorithm;
import std.conv;
import std.math;
import std.stdio;
import unde.games.collision_detector;
import unde.games.dizzy.omega.rope;
import unde.games.object;
import unde.games.renderer;
import unde.global_state;

class Dizzy:LiveGameObject
{
    float def_x, def_y, def_z;
    float dx = 0.0, dy = 0.0;
    float force_dx = 0.0;

    bool sounds = true;
    
    Mix_Chunk *step;
    Mix_Chunk *jump_sound;

    this (MainGameObject root, float[3] coords)
    {
        def_x = x = coords[0];
        def_y = y = coords[1];
        def_z = z = coords[2];

        energy = 100.0;
        lives = 3;

        models["dizzy"] = root.models["dizzy"];
        models["dizzy-cosmonaut"] = root.models["dizzy-cosmonaut"];
        if ("kitchen-knife" in root.models)
            models["kitchen-knife"] = root.models["kitchen-knife"];
        if ("branch" in root.models)
            models["branch"] = root.models["branch"];
        if ("bucket-water" in root.models)
            models["bucket-water"] = root.models["bucket-water"];
        if ("spade" in root.models)
            models["spade"] = root.models["spade"];

        step = Mix_LoadWAV("sounds/step.wav");
        if(!step) {
            writefln("Mix_LoadWAV 'sounds/step.wav': %s", Mix_GetError().to!(string)());
        }

        jump_sound = Mix_LoadWAV("sounds/jump.wav");
        if(!jump_sound) {
            writefln("Mix_LoadWAV 'sounds/jump.wav': %s", Mix_GetError().to!(string)());
        }
        
        super(root);
    }
    
    immutable float side_sensor_dx = 0.9;
    immutable float[2] side_sensor_y = [0.7, 2.5];
    
    immutable float top_sensor_dx = 0.8;
    immutable float[2] top_sensor_y = [2.0, 2.8];
    immutable float water_sensor_dx = 0.3;
    immutable float[2] water_sensor_y = [1.1, 1.48];
    
    immutable float bottom_sensor_dx = 0.7;
    immutable float bottom_sensor_dy = 1.0;

    bool jump;
    long stunning;

    enum {
        SPEED = 0.1,
        JUMP_LEN = 8.0,
        JUMP_H = 3.0,

        G = 8*JUMP_H*SPEED^^2 / JUMP_LEN^^2,
        JUMP_V = sqrt(JUMP_H*2*G),
        
        ROTATE_SPEED = 360/(JUMP_V/G),

        MARS_JUMP_LEN = 10.0,
        MARS_JUMP_H = 4.0,

        MARS_G = 8*MARS_JUMP_H*SPEED^^2 / MARS_JUMP_LEN^^2,
        MARS_JUMP_V = sqrt(MARS_JUMP_H*2*MARS_G),
    }

    Rope rope;
    float[3] last_safe;
    bool fall = false;
    bool show_sensors;
    
    private:
    bool cosm = true;
    bool underwater = false;
    bool on_ice = false;
    float ice_start_x;
    bool search_surface;

    string damaged_by;

    enum STATE
    {
        NO_ANIM,
        DIE_ANIM,
        USE_KNIFE,
        CUT_ROPE,
        THROW_BRANCH,
        WATER,
        DIG,
    }

    bool dizzy_stay_anim(GlobalState gs, string name)
    {
        float f = (gframe*2)%120;
        float degree = 0.0;
        float translate = 0.0;
        if (f < 60.0)
        {
            degree = f - 30.0;
            translate = -0.1 + 0.2*f/60.0;
        }
        else if (f < 120.0)
        { 
            degree = 30.0 - (f - 60.0);
            translate = 0.1 - 0.2*(f - 60.0)/60.0;
        }
        
        if (name == "Left_Glove")
        {
            glTranslatef(0.8, 1.4, 0.0);
            glRotatef(-degree, 0.0, 0.0, 1.0);
            glTranslatef(-0.8, -1.4, 0.0);
        }
        
        if (name == "Right_Glove")
        {
            glTranslatef(-0.8, 1.4, 0.0);
            glRotatef(degree, 0.0, 0.0, 1.0);
            glTranslatef(0.8, -1.4, 0.0);
        }
        
        if (name == "Dizzy")
        {
            glTranslatef(0.0, translate, 0.0);
        }

        return true;
    }
    
    bool dizzy_walk_anim(GlobalState gs, string name)
    {
        float f = (gframe*4)%120;
        float f2 = (gframe*4)%240;
        float degree = 0.0;
        float translate = 0.0;
        
        if (f < 60.0)
            translate = -0.1 + 0.2*f/60.0;
        else if (f < 120.0)
            translate = 0.1 - 0.2*(f - 60.0)/60.0;

        if (f2 < 120.0)
            degree = f2/2 - 30.0;
        else if (f2 < 240.0)
            degree = degree = 30.0 - (f2/2 - 60.0);
        
        if (name == "Left_Glove")
        {
            glTranslatef(0.8, 1.4, 0.0);
            glTranslatef(0.0, 0.5, 0.0);
            glRotatef(degree, 1.0, 0.0, 0.0);
            glTranslatef(0.0, -0.5, 0.0);
            glRotatef(-30, 0.0, 0.0, 1.0);
            glRotatef(-90, 1.0, 0.0, 0.0);
            glTranslatef(-0.8, -1.4, 0.0);
        }
        
        if (name == "Right_Glove")
        {
            glTranslatef(-0.8, 1.4, 0.0);
            glTranslatef(0.0, 0.5, 0.0);
            glRotatef(-degree, 1.0, 0.0, 0.0);
            glTranslatef(0.0, -0.5, 0.0);
            glRotatef(30, 0.0, 0.0, 1.0);
            glRotatef(-90, 1.0, 0.0, 0.0);
            glTranslatef(0.8, -1.4, 0.0);
        }

        if (name == "Left_Boot")
        {
            glTranslatef(0.0, 1.0, 0.0);
            glRotatef(-degree, 1.0, 0.0, 0.0);
            glTranslatef(0.0, -1.0, 0.0);
        }

        if (name == "Right_Boot")
        {
            glTranslatef(0.0, 1.2, 0.0);
            glRotatef(degree, 1.0, 0.0, 0.0);
            glTranslatef(0.0, -1.2, 0.0);
        }
        
        if (name == "Dizzy")
        {
            glTranslatef(0.0, translate, 0.0);
        }

        return true;
    }

    bool dizzy_jump_anim(GlobalState gs, string name)
    {
        float f = (frame*ROTATE_SPEED)%360;
        glTranslatef(0.0, 1.4, 0.0);
        glRotatef(-f, 1.0, 0.0, 0.0);
        glTranslatef(0.0, -1.4, 0.0);
        return true;
    }

    bool dizzy_die_anim(GlobalState gs, string name)
    {
        float f = frame*ROTATE_SPEED;
        if (f > 90.0) f = 90.0;
        glTranslatef(0.0, 1.4 - (1.4-1.0)*f/45.0, 0.0);
        glRotatef(f, 1.0, 0.0, 0.0);
        glTranslatef(0.0, -1.4, 0.0);
        return true;
    }

    bool dizzy_cosmonaut_stay_anim(GlobalState gs, string name)
    {
        float f = (gframe*2)%120;
        float degree = 0.0;
        float translate = 0.0;
        if (f < 60.0)
        {
            degree = f;
            translate = -0.1 + 0.2*f/60.0;
        }
        else if (f < 120.0)
        {
            degree = 60.0 - (f - 60.0);
            translate = 0.1 - 0.2*(f - 60.0)/60.0;
        }
        
        if (name == "Left_Hand")
        {
            glTranslatef(0.5, 1.4, 0.0);
            glRotatef(60.0-degree, 0.0, 0.0, 1.0);
            glTranslatef(-0.5, -1.4, 0.0);
        }
        
        if (name == "Right_Hand")
        {
            glTranslatef(-0.5, 1.4, 0.0);
            glRotatef(-(60.0-degree), 0.0, 0.0, 1.0);
            glTranslatef(0.5, -1.4, 0.0);
        }
        
        if (name == "DizzyCosm")
        {
            glTranslatef(0.0, translate, 0.0);
        }

        if (name == "Left_Fire" || name == "Right_Fire" || name == "defaultobject")
        {
            return false;
        }

        return true;
    }

    bool dizzy_cosmonaut_walk_anim(GlobalState gs, string name)
    {
        float f = (gframe*4)%120;
        float f2 = (gframe*4)%240;
        float degree = 0.0;
        float translate = 0.0;
        
        if (on_ice && !(root.keys & (LEFT_KEY | RIGHT_KEY)))
        {
            f = 60;
            f2= 60;
        }
        
        if (f < 60.0)
            translate = -0.1 + 0.2*f/60.0;
        else if (f < 120.0)
            translate = 0.1 - 0.2*(f - 60.0)/60.0;

        if (f2 < 120.0)
            degree = f2/2 - 30.0;
        else if (f2 < 240.0)
            degree = degree = 30.0 - (f2/2 - 60.0);
        
        if (name == "Left_Hand")
        {
            glTranslatef(0.0, 1.5, 0.0);
            glRotatef(degree, 1.0, 0.0, 0.0);
            glTranslatef(0.0, -1.5, 0.0);
        }
        
        if (name == "Right_Hand")
        {
            glTranslatef(0.0, 1.5, 0.0);
            glRotatef(-degree, 1.0, 0.0, 0.0);
            glTranslatef(0.0, -1.5, 0.0);
        }

        if (name == "Left_Leg")
        {
            glTranslatef(0.0, 1.1, 0.0);
            glRotatef(-degree, 1.0, 0.0, 0.0);
            glTranslatef(0.0, -1.1, 0.0);
        }

        if (name == "Right_Leg")
        {
            glTranslatef(0.0, 1.1, 0.0);
            glRotatef(degree, 1.0, 0.0, 0.0);
            glTranslatef(0.0, -1.1, 0.0);
        }
        
        if (name == "DizzyCosm")
        {
            glTranslatef(0.0, translate, 0.0);
        }

        if (name == "Left_Fire" || name == "Right_Fire" || name == "defaultobject")
        {
            return false;
        }

        return true;
    }

    bool dizzy_cosmonaut_jump_anim(GlobalState gs, string name)
    {
        glTranslatef(0.0, 1.4, 0.0);
        glRotatef(-20.0, 1.0, 0.0, 0.0);
        glTranslatef(0.0, -1.4, 0.0);
        return true;
    }

    bool dizzy_cosmonaut_die_anim(GlobalState gs, string name)
    {
        float f = frame*ROTATE_SPEED;
        if (f > 45.0) f = 45.0;
        glTranslatef(0.0, 1.4 - (1.4-1.0)*f/45.0, 0.0);
        glRotatef(f, 1.0, 0.0, 0.0);
        glTranslatef(0.0, -1.4, 0.0);

        if (name == "Left_Fire" || name == "Right_Fire" || name == "defaultobject")
        {
            return false;
        }
        
        return true;
    }

    bool dizzy_cosmonaut_fall_anim(GlobalState gs, string name, ulong frame)
    {
        float f = frame;
        float f2 = f;
        if (f2 > 50.0) f2 = 50.0;

        glTranslatef(0.0, -0.8*f2/50.0, 0.0);

        if (name == "Right_Hand")
        {
            glTranslatef(-0.55, 1.33, 0.0);
            glRotatef(-90.0*f2/50.0, 0.0, 0.0, 1.0);
            glTranslatef(0.55, -1.33, 0.0);
        }

        if (name == "Left_Leg")
        {
            glTranslatef(0.0, 1.2 - 0.2*f2/50.0, 0.0);
            glRotatef(90.0*f2/50.0, 1.0, 0.0, 0.0);
            glTranslatef(0.0, -1.2, 0.0);
        }

        if (name == "Right_Leg")
        {
            glTranslatef(0.0, 1.2 - 0.2*f2/50.0, 0.0);
            glRotatef(90.0*f2/50.0, 1.0, 0.0, 0.0);
            glTranslatef(0.0, -1.2, 0.0);
        }
        
        if (name == "DizzyCosm")
        {
            glTranslatef(0.0, 1.9, 0.0);
            glRotatef(15.0*sin(f/50.0), 0.0, 1.0, 0.0);
            glTranslatef(0.0, -1.9, 0.0);
        }

        if (name == "Left_Fire" || name == "Right_Fire" || name == "defaultobject")
        {
            return false;
        }
        
        return true;
    }

    bool dizzy_cosmonaut_fall_anim(GlobalState gs, string name)
    {
        return dizzy_cosmonaut_fall_anim(gs, name, frame);
    }

    bool dizzy_cosmonaut_on_rope_anim(GlobalState gs, string name)
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
            degree = degree = 30.0 - (f2/2 - 60.0);
        
        if (name == "Left_Hand")
        {
            glTranslatef(1.1, 1.5, 0.0);
            glRotatef(56.0, 0.0, 1.0, 0.0);
            glTranslatef(-0.8, -1.5, 0.0);

            glTranslatef(0.0, 1.5, 0.0);
            glRotatef(90.0+degree, 1.0, 0.0, 0.0);
            glTranslatef(0.0, -1.5, 0.0);
        }
        
        if (name == "Right_Hand")
        {
            glTranslatef(-1.1, 1.5, -0.3);
            glRotatef(-56.0, 0.0, 1.0, 0.0);
            glTranslatef(0.8, -1.5, 0.0);

            glTranslatef(0.0, 1.5, 0.0);
            glRotatef(90.0-degree, 1.0, 0.0, 0.0);
            glTranslatef(0.0, -1.5, 0.0);
        }

        if (name == "Left_Leg")
        {
            glTranslatef(0.0, 1.1+translate, 0.0);
            glRotatef(26.0, 0.0, 1.0, 0.0);
            glTranslatef(0.0, -1.1, 0.0);
        }

        if (name == "Right_Leg")
        {
            glTranslatef(0.0, 1.1+translate, 0.0);
            glRotatef(-54.0, 0.0, 1.0, 0.0);
            glTranslatef(0.0, -1.1, 0.0);
        }

        if (name == "Left_Fire" || name == "Right_Fire" || name == "defaultobject")
        {
            return false;
        }

        return true;
    }
    
    string underwater_anim(GlobalState gs, string name)
    {
        if (name == "dizzy/dizzy.png")
            return "dizzy/dizzy-underwater.png";
        return name;
    }

    bool underwater_jump_anim(GlobalState gs, string name)
    {
        float f = sin(cast(float)frame/25)*30;
        glTranslatef(0.0, 1.4, 0.0);
        glRotatef(-f, 1.0, 0.0, 0.0);
        glTranslatef(0.0, -1.4, 0.0);
        return true;
    }
    
    bool dizzy_used_knife_anim(GlobalState gs, string name)
    {
        float f = frame;

        glRotatef(-130,0,1,0);
        
        if (f < 100.0)
        {
            if (name == "Left_Leg" || name == "Right_Leg")
            {
                glTranslatef(0.0, 0.59*f/100.0, 0.51*f/100.0);
                glRotatef(-123.5*f/100.0, 1.0, 0.0, 0.0);
            }
    
            if (name == "DizzyCosm" || name == "Left_Hand")
            {
                glTranslatef(0.0, 0.0, 0.43*f/100.0);
                glRotatef(-40.0*f/100.0, 1.0, 0.0, 0.0);
            }
    
            if (name == "Right_Hand")
            {
                glTranslatef(-2.0*f/100.0, 0.2*f/100.0, 0.2*f/100.0);
                glRotatef(-109.2*f/100.0, 0.413*f/100.0, 0.882*f/100.0, 0.226*f/100.0);
            }
        }
        else if (f < 400.0)
        {
            float s = (sin((f-100.0)/25.0)+1.0)/2.0;
    
            if (name == "Left_Leg" || name == "Right_Leg")
            {
                glTranslatef(0.0, 0.59, 0.51);
                glRotatef(-123.5, 1.0, 0.0, 0.0);
            }
    
            if (name == "DizzyCosm" || name == "Left_Hand")
            {
                glTranslatef(0.0, 0.0, 0.43);
                glRotatef(-40.0, 1.0, 0.0, 0.0);
            }
    
            if (name == "Right_Hand")
            {
                glTranslatef(-2.0+0.2*s, 0.2-0.3*s, 0.2-0.5*s);
                glRotatef(-109.2-0.9*s, 0.413-0.199*s, 0.882+0.053*s, 0.226+0.055*s);
    
                //glTranslatef(-1.8, -0.1, -0.3);
                //glRotatef(-110.1, 0.214, 0.936, 0.281);
            }
        }

        if (name == "Left_Fire" || name == "Right_Fire" || name == "defaultobject")
        {
            return false;
        }
        
        return true;
    }

    bool knife_used_by_dizzy_anim(GlobalState gs, string name)
    {   
        float f = frame;

        glRotatef(-130,0,1,0);

        if (f < 50.0)
        {
            glTranslatef(-1.2, 0.6, -0.3 - 1.0*f/50.0);
            glRotatef(-92.9 + 37.9*f/50.0, 0.284 - 0.072*f/100.0, -0.868 + 0.167*f/100.0, 0.408 + 0.287*f/100.0);
        }
        else if (f < 100.0)
        {
            glTranslatef(-1.2 + 0.2*(f-50.0)/50.0, 0.6 - 0.4*(f-50.0)/50.0, -1.3 + 0.1*(f-50.0)/50.0);
            glRotatef(-55.0 - 10.0*(f-50.0)/50.0, 0.212 - 0.032*(f-50.0)/50.0, -0.701 + 0.566*(f-50.0)/50.0, 0.681 + 0.293*(f-50.0)/50.0);
        }
        else if (f < 400.0)
        {
            float s = (sin((f-100.0)/25.0)+1.0)/2.0;
            glTranslatef(-1.0+0.3*s, 0.2+0.1*s, -1.2-0.2*s);
            glRotatef(-65.0+13.8*s, 0.180-0.262*s, -0.135+0.003*s, 0.974+0.014*s);
        }
        else return false;
        
        //glTranslatef(-0.7, 0.3, -1.4);
        //glRotatef(-51.2, -0.082, -0.132, 0.988);

        glScalef(0.4, 0.4, 0.4);

        return true;
    }

    bool dizzy_cuts_rope_anim(GlobalState gs, string name)
    {
        float f = frame;
        glTranslatef(0, 0, 1.0);
        glRotatef(-130,0,1,0);
        
        if (f < 50.0)
        {
            if (name == "Right_Hand")
            {
                glTranslatef(-0.5, 1.5, -0.3);
                glRotatef(130.0*f/50.0, -1.0, -0.5, 0.0);
                glTranslatef(0.5, -1.5, 0.3);
                
                glTranslatef(0.0, 1.5, 0.0);
                glRotatef(180.0, 1.0, 0.0, 0.0);
                glTranslatef(0.0, -1.5, 0.0);
            }
        }

        if (name == "Left_Fire" || name == "Right_Fire" || name == "defaultobject")
        {
            return false;
        }
        
        return true;
    }

    bool knife_cuts_rope_anim(GlobalState gs, string name)
    {
        float f = frame;
        glTranslatef(0, 0, 1.0);
        glRotatef(-130,0,1,0);

        if (f < 50.0)
        {
            glTranslatef(-0.5, 1.5, -0.3);
            glRotatef(130.0*f/50.0, -1.0, -0.5, 0.0);
            glTranslatef(0.5, -1.5, 0.3);
        }

        glTranslatef(-1.1, 1.9, -0.5);
        glRotatef(90.0, 0.0, 1.0, 0.0);
        glScalef(0.4, 0.4, 0.4);
        
        return true;
    }

    bool dizzy_throw_branch_anim(GlobalState gs, string name)
    {
        float f = frame;
        float degree = 0.0;

        glRotatef(-90,0,1,0);
        
        if (f < 45.0)
            degree = f*2;
        else if (f < 90.0)
            degree = 90.0 - (f-45.0)*2;
        
        if (name == "Right_Hand")
        {
            glTranslatef(0.0, 1.9, 0.0);
            glRotatef(degree, 1.0, 0.0, 0.0);
            glTranslatef(0.0, -1.9, 0.0);
        }
        
        if (name == "Left_Fire" || name == "Right_Fire" || name == "defaultobject")
        {
            return false;
        }

        return true;
    }

    bool branch_thrown_by_dizzy_anim(GlobalState gs, string name)
    {
        float f = frame;
        
        float degree = 0.0, degree2 = 0.0;
        float dx = 0.0, dy = 0.0;
        if (f < 45.0)
            degree = f*2;
        else return false;

        glRotatef(-90,0,1,0);

        glTranslatef(0.0, 1.9, 0.0);
        glRotatef(degree, 1.0, 0.0, 0.0);
        glTranslatef(0.0, -1.9, 0.0);
        f = 0.0;
        glTranslatef(-0.9, 0.5, -0.1);

        glRotatef(55.0, 0.0, 1.0, 0.0);
        glRotatef(-60.0, 0.0, 0.0, 1.0);
        glScalef(0.5, 0.5, 0.5);
        
        return true;
    }

    bool dizzy_water_anim(GlobalState gs, string name)
    {
        glRotatef(-130.0, 0.0, 1.0, 0.0);
        
        if (name == "Left_Hand")
        {
            glTranslatef(-0.76, 0.54, -1.80);
            glRotatef(148, 0.512, 0.781, 0.357);
        }

        if (name == "Right_Hand")
        {
            glTranslatef(0.0, 0.34, -0.92);
            glRotatef(38, 1.0, 0.0, 0.0);
        }

        if (name == "Left_Fire" || name == "Right_Fire" || name == "defaultobject")
        {
            return false;
        }
        
        return true;
    }
    
    bool bucket_of_water_water_anim(GlobalState gs, string name)
    {
        glRotatef(-130.0, 0.0, 1.0, 0.0);

        glTranslatef(-1.1, 1.3, -0.54);
        glRotatef(-85, 1.0, 0.0, 0.0);
        glScalef(0.6, 0.6, 0.6);
                
        return true;
    }

    void trarot(float[][] pt, float[][] pr, int p1, int p2, float pos)
    {
        glTranslatef(pt[p1][0] + (pt[p2][0]-pt[p1][0])*pos,
                     pt[p1][1] + (pt[p2][1]-pt[p1][1])*pos,
                     pt[p1][2] + (pt[p2][2]-pt[p1][2])*pos);
                     
        glRotatef(pr[p1][0] + (pr[p2][0]-pr[p1][0])*pos,
                  pr[p1][1] + (pr[p2][1]-pr[p1][1])*pos,
                  pr[p1][2] + (pr[p2][2]-pr[p1][2])*pos,
                  pr[p1][3] + (pr[p2][3]-pr[p1][3])*pos);
    }

    bool dizzy_dig_anim(GlobalState gs, string name)
    {
        float f = frame%100.0;

        glRotatef(-90,0,1,0);

        // Left Hand Phases
        float[][] lhpt = [[-0.34, 0.7, -0.37],
                          [-0.34, 0.65, 0.0],
                          [-0.54, 0.64, -0.48],];
        float[][] lhpr = [[-123, -0.680, -0.719, 0.146],
                          [-98, -0.521, -0.725, 0.450],
                          [-82.9, -0.682, -0.620, 0.389],];
                          
        // Right Hand Phases
        float[][] rhpt = [[0.26, 0.43, -0.17],
                          [0.26, 0.52, 0.32],
                          [0.58, 0.52, 0.21],];
        float[][] rhpr = [[-131, -0.436, 0.871, -0.226],
                          [-120, -0.327, 0.828, -0.455],
                          [-120, -0.327, 0.828, -0.455],];

        // Right Leg Phases
        float[][] rlpt = [[0.34, 0.44, -1.06],
                          [0.33, -0.01, -1.40],
                          [0.0, 0.0, -0.2],];
        float[][] rlpr = [[37, 1.0, 0.0, 0.0],
                          [37, 1.0, 0.0, 0.0],
                          [0.0, 1.0, 0.0, 0.0]];
        
        if (f < 25.0)
        {
            if (name == "Left_Hand")
            {
                glTranslatef(lhpt[0][0], lhpt[0][1], lhpt[0][2]);
                glRotatef(lhpr[0][0], lhpr[0][1], lhpr[0][2], lhpr[0][3]);
            }
            else if (name == "Right_Hand")
            {
                glTranslatef(rhpt[0][0], rhpt[0][1], rhpt[0][2]);
                glRotatef(rhpr[0][0], rhpr[0][1], rhpr[0][2], rhpr[0][3]);
            }
            else if (name == "Right_Leg")
            {
                glTranslatef(rlpt[0][0]*f/25.0, rlpt[0][1]*f/25.0, rlpt[0][2]*f/25.0);
                glRotatef(rlpr[0][0]*f/25.0, rlpr[0][1], rlpr[0][2], rlpr[0][3]);
            }
        }
        else if (f < 50.0)
        {
            if (name == "Left_Hand")
            {
                trarot(lhpt, lhpr, 0, 1, (f-25.0)/25.0);
            }
            else if (name == "Right_Hand")
            {
                trarot(rhpt, rhpr, 0, 1, (f-25.0)/25.0);
            }
            else if (name == "Right_Leg")
            {
                trarot(rlpt, rlpr, 0, 1, (f-25.0)/25.0);
            }
            else
            {
                glTranslatef(0.0, 0.0, -0.2*(f-25.0)/25.0);
            }
        }
        else if (f < 75.0)
        {
            if (name == "Left_Hand")
            {
                trarot(lhpt, lhpr, 1, 2, (f-50.0)/25.0);
            }
            else if (name == "Right_Hand")
            {
                trarot(rhpt, rhpr, 1, 2, (f-50.0)/25.0);
            }
            else if (name == "Right_Leg")
            {
                trarot(rlpt, rlpr, 1, 2, (f-50.0)/25.0);
            }
            else
            {
                glTranslatef(0.0, 0.0, -0.2);
            }
        }
        else
        {
            if (name == "Left_Hand")
            {
                trarot(lhpt, lhpr, 2, 0, (f-75.0)/25.0);
            }
            else if (name == "Right_Hand")
            {
                trarot(rhpt, rhpr, 2, 0, (f-75.0)/25.0);
            }
            else if (name == "Right_Leg")
            {
                trarot(rlpt, rlpr, 2, 0, 0);
            }
            else
            {
                glTranslatef(0.0, 0.0, -0.2);
            }
        }
        
        if (name == "Left_Fire" || name == "Right_Fire" || name == "defaultobject")
        {
            return false;
        }

        return true;
    }

    bool spade_dig_anim(GlobalState gs, string name)
    {
        float f = frame%100.0;

        // Phases
        float[][] pt = [[-0.08, 0.08, -1.12],
                        [-0.08, -0.42, -1.42],
                        [1.17, 0.18, -2.07]];
        float[][] pr = [[-61, -0.170, -0.884, 0.436],
                        [-61, -0.170, -0.884, 0.436],
                        [-42, -0.948, -0.110, -0.297]];

        glRotatef(-90,0,1,0);

        if (f < 25.0)
        {
            glTranslatef(pt[0][0], pt[0][1], pt[0][2]);
            glRotatef(pr[0][0], pr[0][1], pr[0][2], pr[0][3]);
        }
        else if (f < 50.0)
        {
            trarot(pt, pr, 0, 1, (f-25.0)/25.0);
        }
        else if (f < 75.0)
        {
            trarot(pt, pr, 1, 2, (f-50.0)/25.0);
        }
        else
        {
            trarot(pt, pr, 2, 0, (f-75.0)/25.0);
        }
        
        glScalef(0.8, 0.8, 0.8);
        
        return true;
    }

    public:
    override void draw(GlobalState gs)
    {
        glPushMatrix();
        glTranslatef(x, y, z);

        //Dizzy
        if (state == STATE.USE_KNIFE)
        {
            recursive_render(gs, models["dizzy-cosmonaut"], &dizzy_used_knife_anim);
            recursive_render(gs, models["kitchen-knife"], &knife_used_by_dizzy_anim);
        }
        else if (state == STATE.CUT_ROPE)
        {
            recursive_render(gs, models["dizzy-cosmonaut"], &dizzy_cuts_rope_anim);
            recursive_render(gs, models["kitchen-knife"], &knife_cuts_rope_anim);
        }
        else if (state == STATE.THROW_BRANCH)
        {
            recursive_render(gs, models["dizzy-cosmonaut"], &dizzy_throw_branch_anim);
            recursive_render(gs, models["branch"], &branch_thrown_by_dizzy_anim);
        }
        else if (state == STATE.WATER)
        {
            recursive_render(gs, models["dizzy-cosmonaut"], &dizzy_water_anim);
            recursive_render(gs, models["bucket-water"], &bucket_of_water_water_anim);
        }
        else if (state == STATE.DIG)
        {
            recursive_render(gs, models["dizzy-cosmonaut"], &dizzy_dig_anim);
            recursive_render(gs, models["spade"], &spade_dig_anim);
        }
        else if (!cosm)
        {            
            if (state == STATE.DIE_ANIM)
            {
                recursive_render(gs, models["dizzy"], &dizzy_die_anim);
            }
            else if (dx == 0.0)
            {
                if (jump) recursive_render(gs, models["dizzy"],
                    underwater ? &underwater_jump_anim: &dizzy_jump_anim,
                    underwater ? &underwater_anim : null);
                else recursive_render(gs, models["dizzy"], &dizzy_stay_anim, underwater ? &underwater_anim : null);
            }
            else
            {
                if (dx < 0) glRotatef(90,0,1,0);
                else if (dx > 0) glRotatef(-90,0,1,0);
                if (jump) recursive_render(gs, models["dizzy"],
                    underwater ? &underwater_jump_anim: &dizzy_jump_anim, 
                    underwater ? &underwater_anim : null);
                else recursive_render(gs, models["dizzy"],
                    &dizzy_walk_anim, underwater ? &underwater_anim : null);
            }
        }
        else
        {
            bool on_rope = rope !is null &&
                abs(rope.x - x) < 1.0 &&
                y < rope.rope[rope.static_segments][1] &&
                y > rope.rope[rope.cut_segm-1][1];

            if (state == STATE.DIE_ANIM)
            {
                recursive_render(gs, models["dizzy-cosmonaut"],
                    &dizzy_cosmonaut_die_anim);
            }
            else if (fall) recursive_render(gs, models["dizzy-cosmonaut"],
                    &dizzy_cosmonaut_fall_anim);
            else if (on_rope)
            {
                if (x > rope.x) glRotatef(90,0,1,0);
                else if (x < rope.x) glRotatef(-90,0,1,0);

                recursive_render(gs, models["dizzy-cosmonaut"],
                    &dizzy_cosmonaut_on_rope_anim);
            }
            else if (dx == 0.0 && force_dx == 0.0)
            {
                if (jump) recursive_render(gs, models["dizzy-cosmonaut"],
                    underwater ? &underwater_jump_anim: &dizzy_cosmonaut_jump_anim);
                else recursive_render(gs, models["dizzy-cosmonaut"],
                    &dizzy_cosmonaut_stay_anim);
            }
            else
            {
                if (dx < 0 || force_dx > 0) glRotatef(90,0,1,0);
                else if (dx > 0 || force_dx < 0) glRotatef(-90,0,1,0);
                
                if (force_dx != 0.0)
                {
                    glTranslatef(0.0, 1.4, 0.0);
                    glRotatef(30.0, 1.0, 0.0, 0.0);
                    glTranslatef(0.0, -1.4, 0.0);
                }

                if (jump && force_dx == 0.0) recursive_render(gs, models["dizzy-cosmonaut"],
                    underwater ? &underwater_jump_anim: &dizzy_cosmonaut_jump_anim);
                else recursive_render(gs, models["dizzy-cosmonaut"],
                    &dizzy_cosmonaut_walk_anim);
            }
        }
        glPopMatrix();

        if (show_sensors)
        {
            glEnable(GL_COLOR_MATERIAL);
            glDisable(GL_LIGHTING);
            glDisable(GL_CULL_FACE);
            glBindTexture(GL_TEXTURE_2D, 0);
            glColor4f(0.0, 0.0, 1.0, 0.5);
            render_box([x-side_sensor_dx, y+side_sensor_y[0], z-side_sensor_dx, x, y+side_sensor_y[1], z+side_sensor_dx]);
            render_box([x, y+side_sensor_y[0], z-side_sensor_dx, x+side_sensor_dx, y+side_sensor_y[1], z+side_sensor_dx]);
            glColor4f(0.0, 1.0, 0.0, 0.5);
            render_box([x-top_sensor_dx, y+top_sensor_y[0], z-top_sensor_dx, x+top_sensor_dx, y+top_sensor_y[1], z+top_sensor_dx]);
            glColor4f(0.0, 1.0, 1.0, 0.5);
            render_box([x-bottom_sensor_dx, y, z-bottom_sensor_dx, x+bottom_sensor_dx, y+bottom_sensor_dy, z+bottom_sensor_dx]);
            glColor4f(1.0, 1.0, 0.0, 0.5);
            render_box([x-water_sensor_dx, y+water_sensor_y[0], z-1.0, x+water_sensor_dx, y+water_sensor_y[1], z+1.0]);
            glColor4f(1.0, 1.0, 1.0, 1.0);
            glDisable(GL_COLOR_MATERIAL);
            glEnable(GL_LIGHTING);
            glEnable(GL_CULL_FACE);
        }
    }

    override bool tick(GlobalState gs)    
    {
        if (state == STATE.USE_KNIFE)
        {
            frame++;
            if (frame >= 400)
                return false;
        }
        else if (state == STATE.CUT_ROPE)
        {
            frame++;
            if (frame >= 50)
                return false;
        }
        else if (state == STATE.THROW_BRANCH)
        {
            frame++;
            if (frame >= 90)
                return false;
        }
        else if (state == STATE.DIG)
        {
            frame++;
                        
            if (frame > 0 && frame%100 == 0)
            {
                x += 0.5;
                y -= 0.5;
            }
            if (frame >= 300)
                return false;
        }
        else if (state == STATE.DIE_ANIM)
        {
            frame++;
        }
        else
        {
            if (stunning > 0)
                stunning--;
            
            bool on_rope = rope !is null &&
                abs(rope.x - x) < 1.0 &&
                y < rope.rope[rope.static_segments][1] &&
                y > rope.rope[rope.cut_segm-1][1];

            if (!on_rope)
            {
                frame++;
                if (root.keys & UP_KEY && !jump && !fall)
                {
                    if (!cosm) dy = JUMP_V;
                    else dy = MARS_JUMP_V;
                    search_surface = false;
                    jump = true;
                    frame = 0;

                    if(sounds && cosm && jump_sound && Mix_PlayChannel(0, jump_sound, -1)==-1)
                    {
                        writefln("Mix_PlayChannel jump_sound: %s\n",
                            Mix_GetError().to!(string)());
                    }
                }
            }
            else
            {
                if (jump)
                {
                    jump = false;
                    if(sounds && cosm && jump_sound) Mix_HaltChannel(0);
                }
                
                if (root.keys & UP_KEY && !(root.keys & DOWN_KEY))
                {
                    frame++;
                    dy = SPEED;
                }
                else if (root.keys & DOWN_KEY && !(root.keys & UP_KEY))
                {
                    frame--;
                    dy = -SPEED;
                }
                else
                    dy = 0.0;
            }

            float sdx = dx + force_dx;

            if (stunning > 0 && !jump)
            {
                sdx *= sin(gframe/100.0f)*.5+1.0;
            }

            x += sdx;
            
            if (sdx < 0 && (if_intersect (root.collision_objects["solid"], [x-side_sensor_dx, y+side_sensor_y[0], z-side_sensor_dx, x, y+side_sensor_y[1], z+side_sensor_dx]) > 0 ||
                 on_ice && root.keys & LEFT_KEY && ice_start_x - x > 1.5))
            {
                if (on_ice && root.keys & LEFT_KEY)
                    x -= sdx*0.9;
                else
                    x -= sdx;
            }
            
            if (sdx > 0 && (if_intersect (root.collision_objects["solid"], [x, y+side_sensor_y[0], z-side_sensor_dx, x+side_sensor_dx, y+side_sensor_y[1], z+side_sensor_dx]) > 0 ||
                on_ice && root.keys & RIGHT_KEY && x - ice_start_x > 1.5))
            {
                if (on_ice && root.keys & RIGHT_KEY)
                    x -= sdx*0.9;
                else
                    x -= sdx;
            }
        
            y += dy;

            if (dy > 0 && if_intersect (root.collision_objects["solid"], [x-top_sensor_dx, y+top_sensor_y[0], z-top_sensor_dx, x+top_sensor_dx, y+top_sensor_y[1], z+top_sensor_dx]) > 0)
            {
                y -= dy;
            }

            Intersect in_water = if_intersect (root.collision_objects["water"], [x-water_sensor_dx, y+water_sensor_y[0], z-1.0, x+water_sensor_dx, y+water_sensor_y[1], z+1.0]);
            underwater = (in_water == Intersect.In);

            Intersect on_danger =
                max(if_intersect (root.collision_objects["dangers"], [x-bottom_sensor_dx, y, z-bottom_sensor_dx, x+bottom_sensor_dx, y+bottom_sensor_dy, z+bottom_sensor_dx]),
                if_intersect (root.collision_objects["dangers"], [x-side_sensor_dx, y+side_sensor_y[0], z-side_sensor_dx, x+side_sensor_dx, y+side_sensor_y[1], z+side_sensor_dx]),
                if_intersect (root.collision_objects["dangers"], [x-top_sensor_dx, y+top_sensor_y[0], z-top_sensor_dx, x+top_sensor_dx, y+top_sensor_y[1], z+top_sensor_dx]));

            if (on_danger > 0 || damaged_by !is null)
            {
                energy -= 1.0;

                if ((last_intersect.startsWith("Acid") || 
                     last_intersect.startsWith("Lava")) &&
                    if_intersect (root.collision_objects["dangers"],
                        [x-side_sensor_dx, y, z-bottom_sensor_dx, x+side_sensor_dx,
                         y+top_sensor_y[1], z+bottom_sensor_dx]) == Intersect.In)
                {
                    energy = 0.0;
                }

                if (last_intersect.startsWith("Pin"))
                {
                    damaged_by = last_intersect;
                }
                    
                if (energy <= 0.0)
                {
                    die(on_danger > 0 ? last_intersect : damaged_by);
                }
            }

            Intersect on_the_ground =
                if_intersect (root.collision_objects["solid"], [x-bottom_sensor_dx, y, z-bottom_sensor_dx, x+bottom_sensor_dx, y+bottom_sensor_dy, z+bottom_sensor_dx]);

            bool ice = stunning == 0 && (on_the_ground > 0 && last_intersect.startsWith("Ice.") ||
                    on_ice && on_the_ground == 0 && dy <= 0.0 && dy > -JUMP_V);
            if (on_ice && !ice)
            {
                dx = 0.0;
                if (root.keys & LEFT_KEY) dx -= SPEED;
                if (root.keys & RIGHT_KEY) dx += SPEED;
            }
            
            if (ice && !on_ice)
            {
                if (jump)
                {
                    fall = true;
                    if (dx > 0.0) ice_start_x = x - 2.0;
                    else ice_start_x = x + 2.0;
                    dx = 0.0;
                }
                else ice_start_x = x;
                frame = 0;
            }

            if (on_ice && abs(ice_start_x-x) < 1.5)
            {
                frame = 0;
            }

            if (on_ice && !fall && frame > 100)
            {
                fall = true;
                frame = 0;
                dx = 0.0;
            }

            if (fall && frame > 500)
            {
                fall = false;
                frame = 0;
                if (root.keys & LEFT_KEY) dx -= SPEED;
                if (root.keys & RIGHT_KEY) dx += SPEED;
            }
            
            on_ice = ice;

            if (!on_rope && !cosm ? dy > -JUMP_V : dy > -MARS_JUMP_V)
            {
                if (!cosm) dy -= G;
                else dy -= MARS_G;
            }

            Intersect on_cloud =
                if_intersect (root.collision_objects["clouds"], [x-bottom_sensor_dx, y, z-bottom_sensor_dx, x+bottom_sensor_dx, y+0.1, z+bottom_sensor_dx]);

            if (on_cloud > 0)
            {
                if (dy < -JUMP_V/15.0)
                    dy = -JUMP_V/15.0;
            }

            if (search_surface && on_the_ground == 0)
            {
                dy = 0;
                search_surface = false;
            }

            if (on_the_ground > 0 && dx != 0.0 && (gframe*4)%120 == 0)
            {
                if(sounds && step && Mix_PlayChannel(1, step, 1)==-1)
                {
                    writefln("Mix_PlayChannel step: %s\n",
                        Mix_GetError().to!(string)());
                }
            }
            
            if ((on_the_ground > 0 || on_cloud > 0) && (dy <= 0 || search_surface))
            {
                if (if_intersect (root.collision_objects["solid"], [x-bottom_sensor_dx, y+SPEED, z-bottom_sensor_dx, x+bottom_sensor_dx, y+SPEED+bottom_sensor_dy, z+bottom_sensor_dx]) > 0)
                {
                    search_surface = true;
                    dy = SPEED;
                }
                else if (on_the_ground > 0) dy = 0;

                float rotate = (frame*ROTATE_SPEED)%360;
                if ((rotate < 15 || rotate > 345 || cosm || underwater))
                {
                    force_dx = 0.0;
                    
                    bool bug_place = (x >= 239.1 && x <= 265.3 &&
                                      y >= -7.2  && y <= -4.4);
                    if (!on_danger && damaged_by is null && !underwater && !on_ice && !bug_place)
                    {
                        last_safe = [x, y, z];
                    }
                    if (jump)
                    {
                        if(sounds && cosm && jump_sound) Mix_HaltChannel(0);

                        jump = false;
                        if (!on_ice)
                        {
                            dx = 0;
                            if (root.keys & LEFT_KEY) dx -= SPEED;
                            if (root.keys & RIGHT_KEY) dx += SPEED;
                        }
                    }
                }
            }
        }
        
        return true;
    }

    void use_knife()
    {
        state = STATE.USE_KNIFE;
        frame = 0;
    }

    void cut_rope()
    {
        state = STATE.CUT_ROPE;
        frame = 0;
    }

    void throw_branch()
    {
        state = STATE.THROW_BRANCH;
        frame = 0;
    }

    void water_with_bucket_of_water()
    {
        state = STATE.WATER;
        frame = 0;
    }

    void dig()
    {
        state = STATE.DIG;
        frame = 0;
    }

    void start_fall()
    {
        fall = true;
        frame = 0;
    }

    void reset_anim()
    {
        state = STATE.NO_ANIM;
    }

    void die(string by)
    {
        energy = 0.0;
        frame = 0;
        lives--;
        killed_by = by;
        state = STATE.DIE_ANIM;
    }

    void rise()
    {
        reset_anim();
        energy = 100.0;
        fall = false;
        damaged_by = null;
        x = last_safe[0];
        y = last_safe[1];
        z = last_safe[2];
    }

    void start_left(GlobalState gs)
    {
        if ((!jump || cosm || underwater) && !fall)
        {
            dx -= SPEED;
        }
    }

    void stop_left(GlobalState gs)
    {
        if ((!jump || cosm || underwater) && !on_ice)
        {
            if (dx < 0.0) dx += SPEED;
            if (abs(dx) < 0.01) dx = 0.0;
        }
    }

    void
    start_right(GlobalState gs)
    {
        if ((!jump || cosm || underwater) && !fall)
        {
            dx += SPEED;
        }
    }

    void stop_right(GlobalState gs)
    {
        if ((!jump || cosm || underwater) && !on_ice)
        {
            if (dx > 0.0) dx -= SPEED;
            if (abs(dx) < 0.01) dx = 0.0;
        }
    }

    void change_costume(GlobalState gs)
    {
        cosm = !cosm;
    }

    override void load(string[string] s)
    {
        if ("dizzy-x" in s)
            x = s["dizzy-x"].to!(float);
        else
            x = def_x;
            
        if ("dizzy-y" in s)
            y = s["dizzy-y"].to!(float);
        else
            y = def_y;
            
        if ("dizzy-z" in s)
            z = s["dizzy-z"].to!(float);
        else
            z = def_z;

        if ("dizzy-last-safe-x" in s)
            last_safe[0] = s["dizzy-last-safe-x"].to!(float);
        else
            last_safe[0] = def_x;
            
        if ("dizzy-last-safe-y" in s)
            last_safe[1] = s["dizzy-last-safe-y"].to!(float);
        else
            last_safe[1] = def_y;
            
        if ("dizzy-last-safe-z" in s)
            last_safe[2] = s["dizzy-last-safe-z"].to!(float);
        else
            last_safe[2] = def_z;

        if ("dizzy-dx" in s)
            dx = s["dizzy-dx"].to!(float);
        else
            dx = 0.0;
            
        if ("dizzy-dy" in s)
            dy = s["dizzy-dy"].to!(float);
        else
            dy = 0.0;

        jump = ("dizzy-jump" in s) !is null;

        if ("dizzy-energy" in s)
            energy = s["dizzy-energy"].to!(float);
        else
            energy = 100.0;

        if ("dizzy-lives" in s)
            lives = s["dizzy-lives"].to!(int);
        else
            lives = 3;

        if (lives > 3) lives = 3;
        if (energy > 100.0) energy = 100.0;

        if ("dizzy-frame" in s)
            frame = s["dizzy-frame"].to!(long);

        if ("dizzy-stunning" in s)
            stunning = s["dizzy-stunning"].to!(long);
        else
            stunning = 0;
    }

    override void save(ref string[string] s)
    {
        s["dizzy-x"] = x.to!(string);
        s["dizzy-y"] = y.to!(string);
        s["dizzy-z"] = z.to!(string);

        s["dizzy-dx"] = dx.to!(string);
        s["dizzy-dy"] = dy.to!(string);

        s["dizzy-last-safe-x"] = last_safe[0].to!(string);
        s["dizzy-last-safe-y"] = last_safe[1].to!(string);
        s["dizzy-last-safe-z"] = last_safe[2].to!(string);

        if (jump)
        {
            s["dizzy-jump"] = "yes";
            s["dizzy-frame"] = frame.to!(string);
        }

        if (energy < 100.0)
            s["dizzy-energy"] = energy.to!(string);

        if (lives < 3)
            s["dizzy-lives"] = lives.to!(string);

        if (stunning > 0)
            s["dizzy-stunning"] = stunning.to!(string);
    }    
}
