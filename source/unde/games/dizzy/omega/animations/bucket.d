module unde.games.dizzy.omega.animations.bucket;

import derelict.opengl3.gl;
import unde.games.object;
import unde.games.renderer;
import unde.global_state;

class Bucket:StaticGameObject
{    
    this(MainGameObject root)
    {
        frame = -1;
        models["bucket-of-water"] = root.models["bucket-of-water"];
        models["bucket-out-water"] = root.models["bucket-out-water"];
        models["bucket"] = root.models["bucket"];
        super(root);
    }

    void start_anim(float[3] coords)
    {
        x = coords[0];
        y = coords[1];
        z = coords[2];
        frame = root.frame;
    }

    override void draw(GlobalState gs)
    {
        float f = 0.0;
        if (frame >= 0) f = root.frame - frame;

        glPushMatrix();
        if (f <= 0.0) {}
        else if (f <= 50.0)
        {
            glTranslatef(x-2.0*f/50.0, y-0.5*f/50.0, z-2.0*f/50.0);

            glTranslatef(0.0, 1.0, 0.0);
            glRotatef(90.0*f/50.0, -1.0, 0.0, 0.0);
            glTranslatef(0.0, -1.0, 0.0);
            
            recursive_render(gs, models["bucket-of-water"]);
        }
        else if (f <= 100.0)
        {
            glTranslatef(x-2.0, y-0.5, z-2.0);

            glTranslatef(0.0, 1.0, 0.0);
            glRotatef(90.0, -1.0, 0.0, 0.0);
            glTranslatef(0.0, -1.0, 0.0);
            
            recursive_render(gs, models["bucket-out-water"]);
        }
        else if (f <= 200.0)
        {
            glTranslatef(x-2.0, y-0.5, z-2.0);

            glTranslatef(0.0, 1.0, 0.0);
            glRotatef(90.0, -1.0, 0.0, 0.0);
            glTranslatef(0.0, -1.0, 0.0);
            
            recursive_render(gs, models["bucket"]);
        }

        else {}
        glPopMatrix();
    }
    
    override bool tick(GlobalState gs)
    {
        return true;
    }
}

