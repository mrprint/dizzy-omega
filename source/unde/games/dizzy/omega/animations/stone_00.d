module unde.games.dizzy.omega.animations.stone_00;

import derelict.opengl3.gl;
import std.conv;
import std.math;
import unde.games.collision_detector;
import unde.games.object;
import unde.games.renderer;
import unde.global_state;

class Stone00:StaticGameObject
{    
    StaticGameObject the_hero;

    this(MainGameObject root, StaticGameObject hero)
    {
        frame = -1;
        the_hero = hero;

        models["stone-00"] = root.models["stone-00"];
        models["small-stone-00"] = root.models["small-stone-00"];
        super(root);
    }

    override void draw(GlobalState gs)
    {
        if (abs(root.scrx-0.0) > 16.0 ||
            abs(root.scry-0.0) > 9.0) return;
        
        float f = 0.0;
        if (frame >= 0)
        {
            f = root.frame - frame;
        }
        
        glPushMatrix();
        if (f <= 0.0)
        {
            glTranslatef(9.9, 1.2, 0.7);
        }
        else if (f < 100.0)
        {
            glTranslatef(9.9 - (9.9-6.7)*f/100.0, 1.2 - (1.2-0.7)*f/100.0, 0.7);
            glRotatef(83.0*f/100.0, 0.0, 0.0, 1.0);
        }
        else if (f < 200.0)
        {
            glTranslatef(6.7 - (6.7-4.1)*(f-100.0)/100.0, 0.7 - (0.7+3.6)*(f-100.0)/100.0, 0.7);
            glRotatef(83.0+(222.0-83.0)*(f-100.0)/100.0, 0.0, 0.0, 1.0);
            root.collision_objects["solid"]["Stone"] = root.collision_objects["temp-solid"]["Stone"];
            reset_collision_cache();
        }
        else if (f < 250.0)
        {
            glTranslatef(4.1, -3.6 - (-3.6+6.1)*(f-200.0)/50.0, 0.7);
            glRotatef(222.0, 0.0, 0.0, 1.0);
        }
        else
        {
            glTranslatef(4.1, -6.1, 0.7);
            glRotatef(222.0, 0.0, 0.0, 1.0);
        }
        recursive_render(gs, models["stone-00"]);
        glPopMatrix();

        glPushMatrix();
        if (f <= 0.0)
        {
            glTranslatef(8.7, -0.6, 0.7);
            recursive_render(gs, models["small-stone-00"]);
        }
        else if (f < 300.0)
        {
            glTranslatef(8.7-f/5.0, -0.6-f/10.0, 0.7);
            recursive_render(gs, models["small-stone-00"]);  
        }
        glPopMatrix();
    }
    
    override bool tick(GlobalState gs)
    {
        if (frame < 0 && the_hero.x > 6.6)
        {
            frame = root.frame;
        }
        
        return true;
    }

    override void load(string[string] s)
    {
        if ("stone00-frame" in s)
            frame = s["stone00-frame"].to!(long);
        else
            frame = -1;

        float f = 0.0;
        if (frame >= 0)
        {
            f = root.frame - frame;
        }
        
        if (f > 100.0)
        {
            root.collision_objects["solid"]["Stone"] = root.collision_objects["temp-solid"]["Stone"];
            reset_collision_cache();
        }
        else
        {
            root.collision_objects["solid"]["Stone"] = null;
            root.collision_objects["solid"].remove("Stone");
            reset_collision_cache();
        }
    }

    override void save(ref string[string] s)
    {
        if (frame >= 0)
        {
            s["stone00-frame"] = frame.to!(string);
        }
    }    
}
