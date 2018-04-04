module unde.games.dizzy.omega.rotatable;

import derelict.opengl3.gl;
import std.conv;
import std.math;
import std.stdio;
import unde.games.object;
import unde.games.renderer;
import unde.global_state;

class Rotatable:StaticGameObject
{
    bool hidden;
    string model;

    float def_x, def_y, def_z;
    float def_degrees;
    float degrees;

    this(MainGameObject root, float[3] coords, float degrees, string model)
    {
        def_x = x = coords[0];
        def_y = y = coords[1];
        def_z = z = coords[2];
        
        models[model] = root.models[model];
        this.model = model;
        def_degrees = this.degrees = degrees;

        super(root);
    }

    override void draw(GlobalState gs)
    {
        if (!hidden &&
            abs(root.scrx-x) < 16.0 &&
            abs(root.scry-y) < 9.0)
        {
            glPushMatrix();
            glTranslatef(x, y, z);
            glRotatef(degrees, 0.0, 1.0, 0.0);
            recursive_render(gs, models[model]);
            glPopMatrix();
        }   
    }    

    override bool tick(GlobalState gs)
    {
        return true;
    }

    override void load(string[string] s)
    {
        if ("rot-"~model~"-x" in s)
            x = s["rot-"~model~"-x"].to!(float);
        else
            x = def_x;
            
        if ("rot-"~model~"-y" in s)
            y = s["rot-"~model~"-y"].to!(float);
        else
            y = def_y;
            
        if ("rot-"~model~"-z" in s)
            z = s["rot-"~model~"-z"].to!(float);
        else
            z = def_z;

        if ("rot-"~model~"-degrees" in s)
            degrees = s["rot-"~model~"-degrees"].to!(float);
        else
            degrees = def_degrees;

        if ("rot-"~model in s)
        {
            hidden = (s["rot-"~model] == "hidden");
        }
        else hidden = false;
    }

    override void save(ref string[string] s)
    {
        if (hidden)
            s["rot-"~model] = "hidden";
        else
        {
            if (x != def_x) s["rot-"~model~"-x"] = x.to!(string);
            if (y != def_y) s["rot-"~model~"-y"] = y.to!(string);
            if (z != def_z) s["rot-"~model~"-z"] = z.to!(string);
            if (degrees != def_degrees) s["rot-"~model~"-degrees"] = degrees.to!(string);
        }
    }    
}
