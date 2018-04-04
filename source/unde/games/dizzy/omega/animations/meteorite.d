module unde.games.dizzy.omega.animations.meteorite;

import derelict.assimp3.assimp;
import derelict.opengl3.gl;
import std.format;
import std.random;
import std.stdio;
import unde.games.collision_detector;
import unde.games.dizzy.omega.dizzy;
import unde.games.dizzy.omega.main;
import unde.games.object;
import unde.games.renderer;
import unde.global_state;

class Meteorite:StaticGameObject
{
    Dizzy the_hero;
    Random rnd;

    aiVector3D start_pos, end_pos;
    int number = 1;
    float scale;
    float rotation_speed;
    aiVector3D rotation_vector;

    this(MainGameObject root, Dizzy hero, Random _rnd)
    {
        frame = -1;
        the_hero = hero;
        rnd = _rnd;

        models["meteorite-01"] = root.models["meteorite-01"];
        models["meteorite-02"] = root.models["meteorite-02"];
        models["meteorite-03"] = root.models["meteorite-03"];

        collision_objects["solid"] = root.collision_objects["solid"];
        super(root);
    }

    override void draw(GlobalState gs)
    {
        float f = 0.0;   
        if (frame >= 0)
        {
            f = root.frame - frame;
        }

        glPushMatrix();
        if (f <= 0.0) {}
        else if (f <= 300.0)
        {
            glTranslatef(x, y, z);
            glScalef(scale, scale, scale);
            glRotatef(rotation_speed*f/300.0,
                        rotation_vector.x,
                        rotation_vector.y,
                        rotation_vector.z);
            recursive_render(gs, models[format("meteorite-%02d", number)]);
        }
        else {}
        glPopMatrix();
        
    }

    override bool tick(GlobalState gs)
    {
        DizzyOmega dz = cast(DizzyOmega) root;
        if (dz.wait_meteorite == 0 &&
            root.frame < frame)
        {
            frame = root.frame - 301;
        }
        
        if (root.frame > frame + 300)
        {
            frame = root.frame + uniform(0, 1000, rnd);
            start_pos.x = the_hero.x + uniform(-10.0, 10.0, rnd);
            start_pos.y = 20.0;
            start_pos.z = the_hero.z + uniform(-1.5, 1.5, rnd);

            end_pos.x = the_hero.x + uniform(-10.0, 10.0, rnd);
            end_pos.y = -10.0;
            end_pos.z = the_hero.z + uniform(-1.5, 1.5, rnd);

            number = uniform(1, 3, rnd);
            scale = uniform(0.5, 2.0, rnd);

            rotation_speed = uniform(360.0, 3600.0, rnd);
            rotation_vector.x = uniform(-1.0, 1.0, rnd);
            rotation_vector.y = uniform(-1.0, 1.0, rnd);
            rotation_vector.z = uniform(-1.0, 1.0, rnd);
            
            if (dz.wait_meteorite == 0)
            {
                dz.wait_meteorite = 1;
                frame = root.frame;
                number = 1;
                start_pos.z = 0;
                end_pos.z = 0;
                end_pos.x = the_hero.x + uniform(5.0, 10.0, rnd);
                scale = 1.0;
            }
        }

        long mf = root.frame - frame;
        if (frame >= 0 && mf >= 0 && mf <= 300)
        {
            x = start_pos.x + (end_pos.x - start_pos.x)*mf/300.0;
            y = start_pos.y + (end_pos.y - start_pos.y)*mf/300.0;
            z = start_pos.z + (end_pos.z - start_pos.z)*mf/300.0;

            float x0 = x-0.8*scale;
            float x1 = x+0.8*scale;
            float y0 = y-0.8*scale;
            float y1 = y+0.8*scale;
            float z0 = z-0.8*scale;
            float z1 = z+0.8*scale;

            auto mb = if_intersect (collision_objects["solid"], [x0, y0, z0-4.0, x1, y1, z1+4.0]);
            if (mb > 0)
            {
                frame = root.frame - 300;
                
                if (dz.wait_meteorite == 1)
                {
                    dz.wait_meteorite = 2;
                    dz.meteorite.x = x;
                    dz.meteorite.y = y-0.8;
                    dz.meteorite.z = z;
                }
            }

            if ( (the_hero.x-1.0 < x0 && x0 < the_hero.x+1.0 || the_hero.x-1.0 < x1 && x1 < the_hero.x+1.0) &&
                 (the_hero.y < y0 && y0 < the_hero.y+2.8 || the_hero.y < y1 && y1 < the_hero.y+2.8) && 
                 (the_hero.z-1.0 < z0 && z0 < the_hero.z+1.0 || the_hero.z-1.0 < z1 && z1 < the_hero.z+1.0) )
            {
                the_hero.energy -= 0.5*scale;
                if (the_hero.energy <= 0.0)
                {
                    the_hero.die("Meteorite");
                }
            }
        }

        return true;
    }
}    

