module unde.games.dizzy.omega.item;

import derelict.opengl3.gl;
import std.conv;
import std.math;
import unde.games.object;
import unde.games.renderer;
import unde.global_state;

class Item:StaticGameObject
{
    bool inventory;
    bool used;
    string model;

    float def_x, def_y, def_z;

    this(MainGameObject root, float[3] coords, string model)
    {
        def_x = x = coords[0];
        def_y = y = coords[1];
        def_z = z = coords[2];
        
        models[model] = root.models[model];
        this.model = model;

        super(root);
    }

    bool maybe_taken(GlobalState gs, StaticGameObject the_hero)
    {
        float width = 2.5;
        if (model == "stone-1" || model == "stone-2") width = 2.0;
        return !inventory && !used &&
                the_hero.x-width <= x && x <= the_hero.x+width &&
                the_hero.y <= y+1.0 && y+1.0 <= the_hero.y+2.5 &&
                the_hero.z-1.0 <= z && z <= the_hero.z+1.0;
    }

    override void draw(GlobalState gs)
    {
        if (!inventory && !used &&
            abs(root.scrx-x) < 16.0 &&
            abs(root.scry-y) < 9.0)
        {
            glPushMatrix();
            glTranslatef(x, y, z);
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
        if ("item-"~model~"-x" in s)
            x = s["item-"~model~"-x"].to!(float);
        else
            x = def_x;
            
        if ("item-"~model~"-y" in s)
            y = s["item-"~model~"-y"].to!(float);
        else
            y = def_y;
            
        if ("item-"~model~"-z" in s)
            z = s["item-"~model~"-z"].to!(float);
        else
            z = def_z;

        if ("item-"~model in s)
        {
            used = (s["item-"~model] == "used");
            inventory = (s["item-"~model] == "taken");
        }
        else
        {
            used = false;
            inventory = false;
        }
    }

    override void save(ref string[string] s)
    {
        if (used)
            s["item-"~model] = "used";
        else if (inventory)
            s["item-"~model] = "taken";
        else
        {
            if (x != def_x) s["item-"~model~"-x"] = x.to!(string);
            if (y != def_y) s["item-"~model~"-y"] = y.to!(string);
            if (z != def_z) s["item-"~model~"-z"] = z.to!(string);
        }
    }    
}
