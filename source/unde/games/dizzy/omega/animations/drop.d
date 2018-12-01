module unde.games.dizzy.omega.animations.drop;

import derelict.opengl3.gl;
import std.math;
import unde.games.object;
import unde.games.renderer;
import unde.global_state;

class Drop:StaticGameObject
{    
    float y1, y2, y3;
    int offset;

    this(MainGameObject root, float x, float y1, float y2, float y3, float z, int offset)
    {
        this.x = x;
        this.y1 = y1;
        this.y2 = y2;
        this.y3 = y3;
        this.z = z;
        this.offset = offset;

        models["drop"] = root.models["drop"];
        super(root);
    }

    override void draw(GlobalState gs)
    {
        if (abs(root.scrx-x) > 32.0 ||
            abs(root.scry-y) > 18.0) return;
        
        float f = (root.frame+offset)%500;   

        glPushMatrix();
        if (f <= 0.0) {}
        else if (f <= 300.0)
        {
            glTranslatef(x, y1 - (y1-y2)*f/300.0, z);
            recursive_render(gs, models["drop"]);
        }
        else if (f <= 400.0)
        {
            glTranslatef(x, y2 - (y2-y3)*(f-300.0)/100.0, z);
            recursive_render(gs, models["drop"]);
        }
        else {}
        glPopMatrix();
    }
    
    override bool tick(GlobalState gs)
    {
        return true;
    }
}

