module unde.games.dizzy.omega.animations.ground_castle;

import derelict.opengl3.gl;
import std.conv;
import std.format;
import std.math;
import std.stdio;
import unde.games.collision_detector;
import unde.games.dizzy.omega.dizzy;
import unde.games.dizzy.omega.main;
import unde.games.object;
import unde.games.renderer;
import unde.global_state;

class GroundCastle:StaticGameObject
{
    this(MainGameObject root)
    {
        frame = -1;
        models["ground-castle"] = root.models["ground-castle"];
        models["ground-castle-1"] = root.models["ground-castle-1"];

        super(root);
    }

    override void draw(GlobalState gs)
    {
        DizzyOmega dz = cast(DizzyOmega) root;

        if (abs(root.scrx - 16*30.0) > 35.0 || root.scry != -9*17.0)
            return;

        glPushMatrix();
        if (frame < 0)
        {
            recursive_render(gs, models["ground-castle"]);
        }
        else
        {
            recursive_render(gs, models["ground-castle-1"]);
        }
        glPopMatrix();
    }
    
    override bool tick(GlobalState gs)
    {
        DizzyOmega dz = cast(DizzyOmega) root;
        
        if (frame >= 0 && root.frame - frame == 1)
        {
            dz.collision_objects["solid"]["Wall1"] = null;
            dz.collision_objects["solid"].remove("Wall1");
            reset_collision_cache();
        }
        return true;
    }

    override void load(string[string] s)
    {
        string p = "groundcastle";
        if (p in s)
            frame = s[p].to!(long);
        else
            frame = -1;

        DizzyOmega dz = cast(DizzyOmega) root;
        if (frame < 0 || root.frame - frame < 1)
        {
            dz.collision_objects["solid"]["Wall1"] =
                dz.collision_objects["temp-solid"]["Wall1"];
            reset_collision_cache();
        }
        else
        {
            dz.collision_objects["solid"]["Wall1"] = null;
            dz.collision_objects["solid"].remove("Wall1");
            reset_collision_cache();
        }
    }

    override void save(ref string[string] s)
    {
        if (frame >= 0)
        {
            string p = "groundcastle";
            s[p] = frame.to!(string);
        }
    }    
}
