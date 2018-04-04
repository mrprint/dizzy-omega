module unde.games.dizzy.omega.star;

import derelict.opengl3.gl;
import std.conv;
import std.format;
import unde.games.object;
import unde.games.renderer;
import unde.global_state;

class Star:StaticGameObject
{
    static int num;
    int number;
    bool taken;
    
    this(MainGameObject root, float[3] coords)
    {
        x = coords[0];
        y = coords[1];
        z = coords[2];

        number = num++;
        
        super(root);
    }

    bool maybe_taken(GlobalState gs, StaticGameObject the_hero)
    {
        return !taken && the_hero.x-1.5 <= x && x <= the_hero.x+1.5 &&
               the_hero.y <= y+1.0 && y+1.0 <= the_hero.y+2.5 &&
               the_hero.z-1.0 <= z && z <= the_hero.z+1.0;
    }

    bool set_light(GlobalState gs)
    {
        if (!taken && x-root.scrx >= -15 && x-root.scrx < 15 &&
            y-root.scry >= -8.5 && y-root.scry < 8.5)
        {
            glEnable(GL_LIGHT1);
            glLightfv(GL_LIGHT1, GL_POSITION, [x-root.scrx, y-root.scry+0.35f, z, 1.0f].ptr);
            return true;
        }
        
        return false;
    }

    void take()
    {
        taken = true;
    }

    void force_draw(GlobalState gs)
    {
        glPushMatrix();
        glTranslatef(0, 10.0, 0.0);
        glScalef(0.35, 0.35, 0.35);
        recursive_render(gs, root.models["star-"~(cast(uint)(root.frame/7.5)%10).to!(string)]);
        glPopMatrix();
    }

    override void draw(GlobalState gs)
    {
        if (!taken && x-root.scrx >= -15 && x-root.scrx < 15 &&
            y-root.scry >= -8.5 && y-root.scry < 8.5)
        {
            glPushMatrix();
            glTranslatef(x, y, z);
            glScalef(0.35, 0.35, 0.35);
            recursive_render(gs, root.models["star-"~(cast(uint)(root.frame/7.5)%10).to!(string)]);
            glPopMatrix();
        } 
    }    

    override bool tick(GlobalState gs)
    {
        return true;
    }

    override void load(string[string] s)
    {
        string key = format("star-%03d", number);
        taken = (key in s) !is null;
    }

    override void save(ref string[string] s)
    {
        if (taken)
        {
            string key = format("star-%03d", number);
            s[key] = "taken";
        }
    }    
}
