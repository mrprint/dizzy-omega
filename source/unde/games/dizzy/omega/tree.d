module unde.games.dizzy.omega.tree;

import derelict.opengl3.gl;
import std.conv;
import std.format;
import unde.games.object;
import unde.games.renderer;
import unde.global_state;

class Tree:StaticGameObject
{
    float height;
    float max_height;    
    
    this(MainGameObject root, float h, float[3] coords, int number)
    {
        height = h;
        max_height = h;
        
        x = coords[0];
        y = coords[1];
        z = coords[2];
        
        models["tree"] = root.models[format("tree-%02d", number)];
        
        super(root);
    }

    override void draw(GlobalState gs)
    {
        if (x-root.scrx >= -15 && x-root.scrx < 15 &&
            y-root.scry >= -8.5 && y-root.scry < 8.5)
        {
            glPushMatrix();
            glTranslatef(x, y, z);
            glTranslatef(0.0, height - max_height, 0.0);
            recursive_render(gs, models["tree"]);
            glPopMatrix();
        }
    }    

    override bool tick(GlobalState gs)
    {
        return true;
    }
}
