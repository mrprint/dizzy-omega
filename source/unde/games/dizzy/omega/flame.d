module unde.games.dizzy.omega.flame;

import derelict.opengl3.gl;
import std.conv;
import std.math;
import std.format;
import unde.games.object;
import unde.games.renderer;
import unde.global_state;

class Flame:StaticGameObject
{
    static int num;
    int number;
    
    int hidden;

    float def_x, def_y, def_z;
    int froffset;
    
    this(MainGameObject root, float[3] coords, int froffset)
    {
        def_x = x = coords[0];
        def_y = y = coords[1];
        def_z = z = coords[2];

        this.froffset = froffset;
        
        super(root);
    }

    override void draw(GlobalState gs)
    {
        if (x-root.scrx >= -15 && x-root.scrx < 15 &&
            y-root.scry >= -8.5 && y-root.scry < 8.5)
        {
            uint rf = cast(uint)(root.frame/7.5) + froffset;
            uint frame = rf%4;

            glPushMatrix();
            glTranslatef(x, y, z);
            recursive_render(gs, root.models["flame-"~frame.to!(string)]);
            glPopMatrix();
        } 
    }    

    override bool tick(GlobalState gs)
    {
        return true;
    }
}
