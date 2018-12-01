module unde.games.dizzy.omega.animations.stone_01;

import derelict.opengl3.gl;
import std.conv;
import std.math;
import std.stdio;
import unde.games.object;
import unde.games.renderer;
import unde.global_state;

class Stone01:StaticGameObject
{    
    StaticGameObject the_hero;

    this(MainGameObject root, StaticGameObject hero)
    {
        frame = -1;
        the_hero = hero;

        models["stone-01"] = root.models["stone-01"];
        super(root);
    }

    override void draw(GlobalState gs)
    {
        if (abs(root.scrx-20.6) > 16.0 ||
            abs(root.scry-0.0) > 9.0) return;
            
        float f = 0.0;   
        if (frame >= 0.0)
        {
            f = root.frame - frame;
        }
        
        glPushMatrix();
        if (f <= 0.0)
        {
            glTranslatef(20.6, 4.5, 2.0);
        }
        else if (f < 200.0)
        {
            glTranslatef(20.6 + (25.1-20.6)*f/200.0, 4.5 - (4.5-1.9)*f/200.0, 2.0);
            glRotatef(-228.0*f/200.0, 0.0, 0.0, 1.0);
        }
        else if (f < 250.0)
        {
            glTranslatef(25.1 + (25.2-25.1)*(f-200.0)/50.0, 1.9 - (1.9-0.05)*(f-200.0)/50.0, 2.0);
            glRotatef(-228.0-(263.0-228.0)*(f-200.0)/50.0, 0.0, 0.0, 1.0);
        }
        else
        {
            glTranslatef(25.2, 0.05, 2.0);
            glRotatef(-263.0, 0.0, 0.0, 1.0);
        }
        recursive_render(gs, models["stone-01"]);
        glPopMatrix();
    }

    override bool tick(GlobalState gs)
    {
        if (frame < 0 && the_hero.x > 34.6)
        {
            frame = root.frame;
        }        
        return true;
    }

    override void load(string[string] s)
    {
        if ("stone-01-frame" in s)
            frame = s["stone-01-frame"].to!(long);
        else
            frame = -1;
    }

    override void save(ref string[string] s)
    {
        if (frame >= 0)
            s["stone-01-frame"] = frame.to!(string);
    }    
}
