module unde.games.dizzy.omega.animations.ground_cave;

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

class GroundCave:StaticGameObject
{
    this(MainGameObject root)
    {
        frame = -1;
        models["ground-cave"] = root.models["ground-cave"];
        models["ground-cave-1"] = root.models["ground-cave-1"];

        super(root);
    }

    override void draw(GlobalState gs)
    {
        DizzyOmega dz = cast(DizzyOmega) root;

        if (root.scrx != 30 || root.scry != 68)
            return;

        glPushMatrix();
        if (frame < 0)
        {
            recursive_render(gs, models["ground-cave"]);
        }
        else
        {
            recursive_render(gs, models["ground-cave-1"]);
        }
        glPopMatrix();
    }
    
    override bool tick(GlobalState gs)
    {
        return true;
    }

    override void load(string[string] s)
    {
        string p = "groundcave";
        if (p in s)
            frame = s[p].to!(long);
        else
            frame = -1;
    }

    override void save(ref string[string] s)
    {
        if (frame >= 0)
        {
            string p = "groundcave";
            s[p] = frame.to!(string);
        }
    }    
}
