module unde.games.dizzy.omega.animations.ground_garden;

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

class GroundGarden:StaticGameObject
{
    this(MainGameObject root)
    {
        frame = -1;
        models["ground-garden"] = root.models["ground-garden"];
        models["ground-garden-1"] = root.models["ground-garden-1"];
        models["ground-garden-2"] = root.models["ground-garden-2"];
        models["ground-garden-3"] = root.models["ground-garden-3"];

        super(root);
    }

    override void draw(GlobalState gs)
    {
        DizzyOmega dz = cast(DizzyOmega) root;

        if (abs(root.scrx - 330.0) > 35.0 || root.scry != 0)
            return;

        glPushMatrix();
        if (frame < 0)
        {
            recursive_render(gs, models["ground-garden"]);
        }
        else
        {
            float f = root.frame - frame;
            if (f < 100.0)
            {
                recursive_render(gs, models["ground-garden"]);
            }
            else if (f < 200.0)
            {
                recursive_render(gs, models["ground-garden-1"]);
            }
            else if (f < 300.0)
            {
                recursive_render(gs, models["ground-garden-2"]);
            }
            else
            {
                recursive_render(gs, models["ground-garden-3"]);
            }
        }
        glPopMatrix();
    }
    
    override bool tick(GlobalState gs)
    {
        DizzyOmega dz = cast(DizzyOmega) root;
        
        if (frame >= 0 && root.frame - frame == 300)
        {
            dz.collision_objects["solid"]["GroundGarden"] = null;
            dz.collision_objects["solid"].remove("GroundGarden");
            reset_collision_cache();
        }

        return true;
    }

    override void load(string[string] s)
    {
        string p = "groundgarden";
        if (p in s)
            frame = s[p].to!(long);
        else
            frame = -1;

        DizzyOmega dz = cast(DizzyOmega) root;
        if (frame < 0 || root.frame - frame < 300)
        {
            dz.collision_objects["solid"]["GroundGarden"] =
                dz.collision_objects["temp-solid"]["GroundGarden"];
            reset_collision_cache();
        }
        else
        {
            dz.collision_objects["solid"]["GroundGarden"] = null;
            dz.collision_objects["solid"].remove("GroundGarden");
            reset_collision_cache();
        }
    }

    override void save(ref string[string] s)
    {
        if (frame >= 0)
        {
            string p = "groundgarden";
            s[p] = frame.to!(string);
        }
    }    
}
