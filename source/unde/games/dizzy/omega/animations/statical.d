module unde.games.dizzy.omega.animations.statical;

import derelict.opengl3.gl;
import std.math;
import std.stdio;
import unde.games.object;
import unde.games.renderer;
import unde.global_state;

class Statical:StaticGameObject
{
    string model;
    
    this(MainGameObject root, string model)
    {
        this.model = model;
        models[model] = root.models[model];
        super(root);
    }

    override void draw(GlobalState gs)
    {
        glPushMatrix();
        recursive_render(gs, models[model], null, null, true);
        glPopMatrix();
    }
    
    override bool tick(GlobalState gs)
    {
        return true;
    }
}
