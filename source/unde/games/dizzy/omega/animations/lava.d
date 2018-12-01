module unde.games.dizzy.omega.animations.lava;

import derelict.opengl3.gl;
import std.math;
import std.random;
import std.stdio;
import unde.games.object;
import unde.games.renderer;
import unde.global_state;

class Lava:StaticGameObject
{
    float x1, y1, z1;
    float x2, y2, z2;

    enum G = 0.005;
    enum SPEED = 0.05;

    float[3][3] bubbles;
    float[3][3][3] subbubbles;
    
    float[3] sizes;
    float[3][3] subsizes;

    float[3][3] speed;
    float[3][3][3] subspeed;

    Random rnd;
    
    this(MainGameObject root, float[3] c1, float[3] c2, Random _rnd)
    {
        x1 = c1[0];
        y1 = c1[1];
        z1 = c1[2];
        
        x2 = c2[0];
        y2 = c2[1];
        z2 = c2[2];

        rnd = _rnd;
        
        models["lava-bubble"] = root.models["lava-bubble"];
        super(root);
    }

    override void draw(GlobalState gs)
    {
        if (root.scrx < x1 - 30.0 ||
            root.scrx > x2 + 30.0 ||
            root.scry < y1 - 18.0 ||
            root.scry > y2 + 18.0) return;
            
        foreach (i, ref bubble; bubbles)
        {
            if (!isNaN(bubble[0]))
            {
                glPushMatrix();
                glTranslatef(bubble[0], bubble[1], bubble[2]);
                glScalef(sizes[i], sizes[i], sizes[i]);
                recursive_render(gs, models["lava-bubble"]);
                glPopMatrix();
            }
        }

        foreach (i, ref subbubblez; subbubbles)
        {
            foreach (j, ref subbubble; subbubblez)
            {
                if (!isNaN(subbubble[0]))
                {
                    glPushMatrix();
                    glTranslatef(subbubble[0], subbubble[1], subbubble[2]);
                    glScalef(subsizes[i][j], subsizes[i][j], subsizes[i][j]);
                    recursive_render(gs, models["lava-bubble"]);
                    glPopMatrix();
                }
            }
        }
    }
    
    override bool tick(GlobalState gs)
    {
        if (root.scrx < x1 - 30.0 ||
            root.scrx > x2 + 30.0 ||
            root.scry < y1 - 18.0 ||
            root.scry > y2 + 18.0) return true;
            
        foreach (i, ref bubble; bubbles)
        {
            if (!isNaN(bubble[0]))
            {
                if (bubble[1] > y2)
                {
                    foreach (j, ref subbubble; subbubbles[i])
                    {
                        subbubble[0..3] = bubble[0..3];
                        subsizes[i][j] = uniform(sizes[i]*0.1, sizes[i]*0.5, rnd);
                        subspeed[i][j][0] = uniform(-SPEED, SPEED, rnd);
                        subspeed[i][j][1] = speed[i][1];
                        subspeed[i][j][2] = uniform(-SPEED, SPEED, rnd);
                    }
                    bubble[0] = float.nan;
                }
                else
                {
                    //writefln("%s: %s - %s", i, bubble, speed[i]);
                    bubble[0..3] += speed[i][0..3];
                }
            }
        }

        foreach (i, ref subbubblez; subbubbles)
        {
            int isnans;
            foreach (j, ref subbubble; subbubblez)
            {
                if (!isNaN(subbubble[0]))
                {
                    subbubble[0..3] += subspeed[i][j][0..3];
                    subspeed[i][j][1] -= G;
                    if (subspeed[i][j][1] < -SPEED) subspeed[i][j][1] = -SPEED;

                    if (subbubble[1] < y2 ||
                        subbubble[0] < x1 || subbubble[0] > x2 ||
                        subbubble[2] < z1 || subbubble[2] > z2)
                    {
                        subbubble[0] = float.nan;
                    }
                }

                if (isNaN(subbubble[0]) && isNaN(bubbles[i][0]))
                {
                    isnans++;
                }
            }
        
            if (isnans == subbubblez.length)
            {
                bubbles[i][0] = uniform(x1, x2, rnd);
                bubbles[i][1] = y1;
                bubbles[i][2] = uniform(z1, z2, rnd);

                sizes[i] = uniform(0.5, 1.0, rnd);

                speed[i][0] = 0.0;
                speed[i][1] = uniform(0.5*SPEED, 1.5*SPEED, rnd);
                speed[i][2] = 0.0;
            }
        }
        
        return true;
    }
}
