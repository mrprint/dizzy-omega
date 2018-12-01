module unde.games.dizzy.omega.animations.stones;

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

class Stones:StaticGameObject
{
    this(MainGameObject root)
    {
        frame = -1;
        
        models["stones-1"] = root.models["stones-1"];
        models["stones-2"] = root.models["stones-2"];
        
        DizzyOmega dz = cast(DizzyOmega) root;
        dz.collision_objects["solid"]["Stones1"] =
            dz.collision_objects["temp-solid"]["Stones1"];

        super(root);
    }

    override void draw(GlobalState gs)
    {
        DizzyOmega dz = cast(DizzyOmega) root;

        if (abs(root.scrx - 434.0) > 35.0 || abs(root.scry + 70.0) > 16.0)
            return;

        glPushMatrix();
        if (frame < 0)
        {
            recursive_render(gs, models["stones-1"]);
        }
        else
        {
            recursive_render(gs, models["stones-2"]);
        }
        glPopMatrix();
    }
    
    override bool tick(GlobalState gs)
    {
        DizzyOmega dz = cast(DizzyOmega) root;
        
        if (frame >= 0 && root.frame - frame == 0)
        {
            dz.collision_objects["solid"]["Stones2"] =
                dz.collision_objects["temp-solid"]["Stones2"];
            dz.collision_objects["solid"]["Stones1"] = null;
            dz.collision_objects["solid"].remove("Stones1");
            reset_collision_cache();
        }

        return true;
    }

    override void load(string[string] s)
    {
        string p = "stones";
        if (p in s)
            frame = s[p].to!(long);
        else
            frame = -1;

        DizzyOmega dz = cast(DizzyOmega) root;
        if (frame < 0)
        {
            dz.collision_objects["solid"]["Stones1"] =
                dz.collision_objects["temp-solid"]["Stones1"];
            dz.collision_objects["solid"]["Stones2"] = null;
            dz.collision_objects["solid"].remove("Stones2");
            reset_collision_cache();
        }
        else
        {
            dz.collision_objects["solid"]["Stones2"] =
                dz.collision_objects["temp-solid"]["Stones2"];
            dz.collision_objects["solid"]["Stones1"] = null;
            dz.collision_objects["solid"].remove("Stones1");
            reset_collision_cache();
        }
    }

    override void save(ref string[string] s)
    {
        if (frame >= 0)
        {
            string p = "stones";
            s[p] = frame.to!(string);
        }
    }    
}
