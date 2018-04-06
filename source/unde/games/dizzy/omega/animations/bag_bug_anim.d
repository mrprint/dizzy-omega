module unde.games.dizzy.omega.animations.bag_bug_anim;

import derelict.opengl3.gl;

import std.conv;
import unde.games.dizzy.omega.bug;
import unde.games.object;
import unde.games.renderer;
import unde.global_state;

class BagBugAnim:GameObject
{
    enum SPEED = 0.05;
    enum G = 0.015;
    enum MAX_V = 0.05;
    enum JUMP_V = 0.1;
    
    long frame = -1;
    int stage;

    Bug bug;
    float dz = 0.0;

    this(MainGameObject root)
    {
        bug = new Bug(root, [302.6, 34.4, 3.0], "solid");
        bug.dx = -SPEED;
        models["bag"] = root.models["bag"];
        super(root);
    }

    void start()
    {
        if (frame < 0) frame = 0;
    }

    override void draw(GlobalState gs)
    {
        if (frame >= 0 && bug.x > 284.0)
        {
            bug.draw(gs);
            
            glPushMatrix();
            glTranslatef(bug.x, bug.y+0.5, bug.z);
            recursive_render(gs, models["bag"]);
            glPopMatrix();
        }
    }

    override bool tick(GlobalState gs)
    {
        if (frame >= 0 && bug.x > 284.0)
        {
            frame++;
            bug.x += bug.dx;
            bug.y += bug.dy;
            bug.z += dz;

            switch(stage)
            {
                case 0:
                    if (bug.x <= 299.2)
                    {
                        bug.dy = JUMP_V;
                        stage++;
                    }
                    break;
                case 1:
                    bug.dy -= G;
                    if (bug.y <= 29.4)
                    {
                        bug.dy = 0;
                        dz = -SPEED;
                        stage++;
                    }
                    break;
                case 2:
                    if (bug.z <= 1.5)
                    {
                        bug.dy = JUMP_V;
                        stage++;
                    }
                    break;
                case 3:
                    bug.dy -= G;
                    if (bug.y <= 26.4)
                    {
                        bug.dy = 0.0;
                        bug.dx = -SPEED;
                        stage++;
                    }
                    break;
                case 4:
                    if (bug.z <= -3.0)
                    {
                        dz = 0;
                        stage++;
                    }
                    break;
                default:
                    break;
            }
        }

        return true;
    }

    void load(string[string] s)
    {
        bug.load(s);

        if ("bag-bug-dz" in s)
            dz = s["bag-bug-dz"].to!(float);
        else
        {
            dz = 0.0;
            bug.dx = -SPEED;
        }

        if ("bag-bug-frame" in s)
            frame = s["bag-bug-frame"].to!(long);
        else
            frame = -1;

        if ("stage" in s)
            stage = s["bag-bug-stage"].to!(int);
        else
            stage = 0;
    }

    void save(ref string[string] s)
    {
        if (frame >= 0)
        {
            bug.save(s);
            s["bag-bug-dz"] = dz.to!(string);
            s["bag-bug-frame"] = frame.to!(string);
            s["bag-bug-stage"] = stage.to!(string);
        }
    }
}
