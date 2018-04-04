module unde.games.dizzy.omega.animations.light_drop;

import derelict.opengl3.gl;
import unde.games.object;
import unde.games.renderer;
import unde.global_state;

class LightDrop:StaticGameObject
{    
    this(MainGameObject root)
    {
        models["light-drop"] = root.models["light-drop"];
        super(root);
    }

    override void draw(GlobalState gs)
    {
        float f = root.frame%500;   

        glPushMatrix();
        if (f <= 0.0) {}
        else if (f <= 300.0)
        {
            glTranslatef(12.3, -1.8 - (2.2-1.8)*f/300.0, 1.0);
            recursive_render(gs, models["light-drop"]);
        }
        else if (f <= 400.0)
        {
            glTranslatef(12.3, -2.2 - (5.0-2.2)*(f-300.0)/100.0, 1.0);
            recursive_render(gs, models["light-drop"]);
        }
        else {}
        glPopMatrix();
    }
    
    override bool tick(GlobalState gs)
    {
        return true;
    }
}
