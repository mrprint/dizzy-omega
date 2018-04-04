module unde.games.dizzy.omega.animations.stalagmite;

import derelict.opengl3.gl;
import unde.games.object;
import unde.games.renderer;
import unde.global_state;

class Stalagmite:StaticGameObject
{    
    StaticGameObject the_hero;

    this(MainGameObject root, StaticGameObject hero)
    {
        frame = -1;
        the_hero = hero;

        models["stalagmite"] = root.models["stalagmite"];
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
        }
        else if (f < 50.0)
        {
            glTranslatef(237.2, -6.0 + (6.0-4.0)*f/50.0, 0.0);
            recursive_render(gs, models["stalagmite"]);
        }
        else
        {
            glTranslatef(237.2, -4.0, 0.0);
            recursive_render(gs, models["stalagmite"]);
        }
        
        glPopMatrix();

    }
    
    override bool tick(GlobalState gs)
    {
        if (frame < 0 && the_hero.x > 235.8 && -6.0 < the_hero.y && the_hero.y < -1.9)
        {
            frame = root.frame;
        }
        
        return true;
    }
}

