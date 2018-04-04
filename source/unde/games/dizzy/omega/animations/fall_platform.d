module unde.games.dizzy.omega.animations.fall_platform;

import derelict.opengl3.gl;
import std.conv;
import std.format;
import std.math;
import unde.games.dizzy.omega.dizzy;
import unde.games.object;
import unde.games.renderer;
import unde.global_state;

class FallPlatform:StaticGameObject
{
    static int num;
    int number;
    Dizzy the_hero;

    this(MainGameObject root, Dizzy hero, float[3] coords, int number)
    {
        frame = -1;
        x = coords[0];
        y = coords[1];
        z = coords[2];
        number = num++;
        models["fall-platform"] = root.models[format("fall-platform-%d", number)];
        the_hero = hero;
        super(root);
    }

    override void draw(GlobalState gs)
    {
        glPushMatrix();
        if (frame < 0)
        {
            glTranslatef(x, y, z);
            recursive_render(gs, models["fall-platform"]);
        }
        else
        {
            float f = root.frame - frame;
            if (f < 100.0)
            {
                glTranslatef(x, y - 20.0*f/100.0, z);
                recursive_render(gs, models["fall-platform"]);
            }
        }
        glPopMatrix();
    }
    
    override bool tick(GlobalState gs)
    {
        if (frame < 0 && abs(x-the_hero.x) < the_hero.bottom_sensor_dx && abs(y-the_hero.y) < 0.2)
        {
            frame = root.frame;
        }

        return true;
    }

    override void load(string[string] s)
    {
        string p = "fall-platform-"~number.to!(string);
        if (p in s)
            frame = s[p].to!(long);
        else
            frame = -1;
    }

    override void save(ref string[string] s)
    {
        if (frame >= 0)
        {
            string p = "fall-platform-"~number.to!(string);
            s[p] = frame.to!(string);
        }
    }    
}
