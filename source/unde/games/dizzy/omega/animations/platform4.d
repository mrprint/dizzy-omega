module unde.games.dizzy.omega.animations.platform4;

import derelict.opengl3.gl;
import std.conv;
import std.format;
import std.math;
import unde.games.collision_detector;
import unde.games.dizzy.omega.dizzy;
import unde.games.dizzy.omega.main;
import unde.games.object;
import unde.games.renderer;
import unde.global_state;

class Platform4:StaticGameObject
{
    this(MainGameObject root, float[3] coords)
    {
        frame = -1;
        x = coords[0];
        y = coords[1];
        z = coords[2];
        models["platform4"] = root.models["platform4"];
        super(root);
    }

    override void draw(GlobalState gs)
    {
        glPushMatrix();
        if (frame < 0)
        {
            glTranslatef(x, y, z);
            recursive_render(gs, models["platform4"]);
        }
        else
        {
            float f = root.frame - frame;
            if (f < 100.0)
            {
                glTranslatef(x + f/10.0, y + f/10.0, z);
                recursive_render(gs, models["platform4"]);
            }
        }
        glPopMatrix();
    }
    
    override bool tick(GlobalState gs)
    {
        DizzyOmega dz = cast(DizzyOmega) root;
        if (frame < 0 && dz.star1.taken)
        {
            frame = root.frame;
            dz.collision_objects["solid"]["Platform4"] = null;
            dz.collision_objects["solid"].remove("Platform4");
            reset_collision_cache();
        }

        return true;
    }

    override void load(string[string] s)
    {
        string p = "platform4";
        if (p in s)
            frame = s[p].to!(long);
        else
            frame = -1;

        DizzyOmega dz = cast(DizzyOmega) root;
        if (frame < 0)
        {
            dz.collision_objects["solid"]["Platform4"] = 
                dz.collision_objects["temp-solid"]["Platform4"];
            reset_collision_cache();
        }
        else
        {
            dz.collision_objects["solid"]["Platform4"] = null;
            dz.collision_objects["solid"].remove("Platform4");
            reset_collision_cache();
        }
    }

    override void save(ref string[string] s)
    {
        if (frame >= 0)
        {
            string p = "platform4";
            s[p] = frame.to!(string);
        }
    }    
}
