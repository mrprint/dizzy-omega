module unde.games.dizzy.omega.animations.stone_02;

import derelict.opengl3.gl;
import std.conv;
import std.stdio;
import unde.games.object;
import unde.games.renderer;
import unde.global_state;

class Stone02:StaticGameObject
{    
    StaticGameObject the_hero;

    this(MainGameObject root, StaticGameObject hero)
    {
        frame = -1;
        the_hero = hero;

        models["stone-02"] = root.models["stone-02"];
        super(root);
    }

    override void draw(GlobalState gs)
    {
        float f = 0.0;   
        if (frame >= 0.0)
        {
            f = root.frame - frame;
        }
        
        glPushMatrix();
        if (f <= 0.0)
        {
            glTranslatef(-32.8, -5.8, 0.0);
        }
        recursive_render(gs, models["stone-02"]);
        glPopMatrix();
    }

    override bool tick(GlobalState gs)
    {
        if (frame < 0 && false)
        {
            frame = root.frame;
        }        
        return true;
    }

    override void load(string[string] s)
    {
        if ("stone-02-frame" in s)
            frame = s["stone-02-frame"].to!(long);
        else
            frame = -1;
    }

    override void save(ref string[string] s)
    {
        if (frame >= 0)
            s["stone-02-frame"] = frame.to!(string);
    }    
}
