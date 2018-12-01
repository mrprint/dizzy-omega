module unde.games.dizzy.omega.animations.water;

import derelict.opengl3.gl;
import std.math;
import std.stdio;
import unde.games.object;
import unde.games.renderer;
import unde.global_state;

class Water:StaticGameObject
{
    float[3][][] dup_vertices;
    float surface;
    string model;

    float min_x, min_y, max_x, max_y;
    
    this(MainGameObject root, string model, float surface)
    {
        this.surface = surface;
        this.model = model;
        models[model] = root.models[model];
        foreach(ref object; models[model].objects)
        {
            dup_vertices ~= cast(float[3][]) object.vertices.dup();
            
            foreach(i, ref vertice; object.vertices)
            {
                if (-vertice[0] < min_x || min_x.isNaN) min_x = -vertice[0];
                if (-vertice[0] > max_x || max_x.isNaN) max_x = -vertice[0];
                if (vertice[1] < min_y || min_y.isNaN) min_y = vertice[1];
                if (vertice[1] > max_y || max_y.isNaN) max_y = vertice[1];
            }
        }
        super(root);
    }

    override void draw(GlobalState gs)
    {
        if (root.scrx < min_x - 30.0 ||
            root.scrx > max_x + 30.0 ||
            root.scry < min_y - 18.0 ||
            root.scry > max_y + 18.0) return;

        glPushMatrix();
        recursive_render(gs, models[model], null, null, true);
        glPopMatrix();
    }
    
    override bool tick(GlobalState gs)
    {
        if (root.scrx < min_x - 30.0 ||
            root.scrx > max_x + 30.0 ||
            root.scry < min_y - 18.0 ||
            root.scry > max_y + 18.0) return true;
        
        foreach(o, ref object; models[model].objects)
        {
            foreach(i, ref vertice; object.vertices)
            {
                if (vertice[1] > surface)
                    vertice[1] = dup_vertices[o][i][1] + 0.5f*sin(vertice[0] + root.frame/100.0)*sin(vertice[2] + root.frame/200.0);
            }
        }
        return true;
    }
}
