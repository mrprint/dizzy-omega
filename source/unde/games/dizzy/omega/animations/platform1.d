module unde.games.dizzy.omega.animations.platform1;

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

class Platform1:StaticGameObject
{
    this(MainGameObject root, float[3] coords)
    {
        frame = -1;
        x = coords[0];
        y = coords[1];
        z = coords[2];
        models["platform1"] = root.models["platform1"];
        super(root);
    }

    override void draw(GlobalState gs)
    {
        glPushMatrix();
        if (frame < 0)
        {
            glTranslatef(x, y, z);
            recursive_render(gs, models["platform1"]);
        }
        else
        {
            float f = root.frame - frame;
            if (f < 100.0)
            {
                glTranslatef(x + f/10.0, y + f/10.0, z);
                recursive_render(gs, models["platform1"]);
            }
        }
        glPopMatrix();
    }
    
    override bool tick(GlobalState gs)
    {
        DizzyOmega dz = cast(DizzyOmega) root;
        if (frame < 0 && dz.star0.taken)
        {
            frame = root.frame;
            dz.collision_objects["solid"]["Platform1"] = null;
            dz.collision_objects["solid"].remove("Platform1");
            reset_collision_cache();
        }

        return true;
    }

    override void load(string[string] s)
    {
        string p = "platform1";
        if (p in s)
            frame = s[p].to!(long);
        else
            frame = -1;

        DizzyOmega dz = cast(DizzyOmega) root;
        if (frame < 0)
        {
            dz.collision_objects["solid"]["Platform1"] = 
                dz.collision_objects["temp-solid"]["Platform1"];
            reset_collision_cache();
        }
        else
        {
            dz.collision_objects["solid"]["Platform1"] = null;
            dz.collision_objects["solid"].remove("Platform1");
            reset_collision_cache();
        }
    }

    override void save(ref string[string] s)
    {
        if (frame >= 0)
        {
            string p = "platform1";
            s[p] = frame.to!(string);
        }
    }                    
}
