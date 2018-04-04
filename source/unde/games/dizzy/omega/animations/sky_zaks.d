module unde.games.dizzy.omega.animations.sky_zaks;

import derelict.opengl3.gl;
import derelict.sdl2.mixer;
import std.conv;
import std.math;
import std.stdio;
import unde.games.object;
import unde.games.renderer;
import unde.global_state;

class SkyZaks:StaticGameObject
{    
    StaticGameObject the_hero;

    Mix_Chunk *laugh;

    this(MainGameObject root, StaticGameObject hero)
    {
        frame = -1;
        the_hero = hero;

        models["zaks-face"] = root.models["zaks-face"];

        laugh = Mix_LoadWAV("sounds/zaks-laugh.wav");
        if(!laugh) {
            writefln("Mix_LoadWAV 'sounds/zaks-laugh.wav': %s", Mix_GetError().to!(string)());
        }
        super(root);
    }

    override void draw(GlobalState gs)
    {
        float f = 0.0;   
        if (frame >= 0)
        {
            f = root.frame - frame;
        }

        glPushMatrix();
        if (f <= 0.0) {}
        else if (f <= 100.0)
        {
            glTranslatef(32.6, 20.0 - (20.0-3.1)*f/100.0, 2.0);
            recursive_render(gs, models["zaks-face"]);
        }
        else if (f <= 500.0)
        {
            glTranslatef(32.6, 3.1 + sin((f-100.0)/50), 2.0);
            recursive_render(gs, models["zaks-face"]);
        }
        else if (f <= 600.0)
        {
            glTranslatef(32.6, 3.1 + (20.0-3.1)*(f-500.0)/100.0, 2.0);
            recursive_render(gs, models["zaks-face"]);
        }
        else {}
        glPopMatrix();
    }

    override bool tick(GlobalState gs)
    {
        if (frame >= 0 && root.frame - frame == 100)
        {
            if(laugh && Mix_PlayChannel(2, laugh, 0)==-1)
            {
                writefln("Mix_PlayChannel laugh: %s\n",
                    Mix_GetError().to!(string)());
            }
        }

        if (frame < 0 && the_hero.x > 37.6)
        {
            frame = root.frame;
        }        
        return true;
    }

    override void load(string[string] s)
    {
        if ("sky-zaks-frame" in s)
            frame = s["sky-zaks-frame"].to!(long);
        else
            frame = -1;
    }

    override void save(ref string[string] s)
    {
        if (frame >= 0)
            s["sky-zaks-frame"] = frame.to!(string);
    }
}
