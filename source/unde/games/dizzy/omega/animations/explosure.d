module unde.games.dizzy.omega.animations.explosure;

import derelict.opengl3.gl;
import std.conv;
import std.format;
import std.math;
import unde.games.collision_detector;
import unde.games.dizzy.omega.dizzy;
import unde.games.dizzy.omega.main;
import unde.games.object;
import unde.games.renderer;
import unde.global_state;

class Explosure:StaticGameObject
{
    float x1, y1, z1;
    float x2, y2, z2;

    LiveGameObject the_hero;
    immutable float timer = 400.0;
    
    this(MainGameObject root, float[3] coords, float[3] coords1, float[3] coords2, LiveGameObject hero)
    {
        frame = -1;
        x = coords[0];
        y = coords[1];
        z = coords[2];
        
        x1 = coords1[0];
        y1 = coords1[1];
        z1 = coords1[2];

        x2 = coords2[0];
        y2 = coords2[1];
        z2 = coords2[2];        
        
        models["platform2"] = root.models["platform2"];
        models["before-explosure"] = root.models["before-explosure"];
        models["after-explosure-up"] = root.models["after-explosure-up"];
        models["after-explosure-down"] = root.models["after-explosure-down"];
        models["bomb"] = root.models["bomb"];
        models["explosure"] = root.models["explosure"];

        the_hero = hero;
        super(root);
    }

    override void draw(GlobalState gs)
    {
        DizzyOmega dz = cast(DizzyOmega) root;

        glPushMatrix();
        if (frame < 0)
        {
            glTranslatef(x1, y1, z1);
            recursive_render(gs, models["platform2"]);
            
            glPopMatrix();
            glPushMatrix();

            glTranslatef(x, y, z);
            recursive_render(gs, models["before-explosure"]);
            
            glPopMatrix();
            glPushMatrix();

            glTranslatef(x2, y2, z2);
            recursive_render(gs, models["bomb"]);
        }
        else
        {
            float f = frame;
            if (f < timer)
            {
                glTranslatef(x1, y1, z1);
                recursive_render(gs, models["platform2"]);
                
                glPopMatrix();
                glPushMatrix();
    
                glTranslatef(x, y, z);
                recursive_render(gs, models["before-explosure"]);
                
                glPopMatrix();
                glPushMatrix();

                glTranslatef(x2, y2, z2);
                recursive_render(gs, models["bomb"]);

                glDisable(GL_LIGHTING);
                glTranslatef(-0.2, 0.0, 0.0);
                float f2 = f % 100.0;
                int num = cast(int)((timer - f)/100.0) + 1;

                glScalef(f2/100.0, f2/100.0, f2/100.0);
                glTranslatef(2.2, 2.0, 0.0);
        
                glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                glEnable(GL_COLOR_MATERIAL);
                glColor4f(1.0, 1.0, 1.0, 1.0);
                print_text(format("%d", num));

                glEnable(GL_LIGHTING);
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            }
            else if (f < timer+100.0)
            {
                glTranslatef(x1, y1, z1);
                recursive_render(gs, models["platform2"]);
                
                glPopMatrix();
                glPushMatrix();
                
                glTranslatef(x, y, z);
                recursive_render(gs, models["before-explosure"]);    
                
                glPopMatrix();
                glPushMatrix();

                glTranslatef(x2, y2, z2);
                recursive_render(gs, models["bomb"]);
                glTranslatef(0.0, 0.0, -0.6);
                glScalef((f-timer)*2.0/100.0, (f-timer)*2.0/100.0, (f-timer)*2.0/100.0);
                recursive_render(gs, models["explosure"]);
            }
            else if (f < timer+200.0)
            {
                glTranslatef(x1, y1, z1);
                recursive_render(gs, models["platform2"]);
                
                glPopMatrix();
                glPushMatrix();
    
                glTranslatef(x, y, z);
                glRotatef((f-timer-100.0)*70.0/100.0, 0.0, 0.0, -1.0);
                recursive_render(gs, models["after-explosure-up"]);

                glPopMatrix();
                glPushMatrix();
    
                glTranslatef(x, y, z);
                recursive_render(gs, models["after-explosure-down"]);
            }
            else
            {
                glTranslatef(x1, y1, z1);
                recursive_render(gs, models["platform2"]);
                
                glPopMatrix();
                glPushMatrix();
    
                glTranslatef(x, y, z);
                glRotatef(70.0, 0.0, 0.0, -1.0);
                recursive_render(gs, models["after-explosure-up"]);

                glPopMatrix();
                glPushMatrix();
    
                glTranslatef(x, y, z);
                recursive_render(gs, models["after-explosure-down"]);
            }
        }
        glPopMatrix();
    }
    
    override bool tick(GlobalState gs)
    {        
        DizzyOmega dz = cast(DizzyOmega) root;

        long old_frame = frame;
        if (frame >= 0)
        {
            int speedfactor = 1;

            if (frame < timer + 100)
            {
                if (the_hero.y < -20.7 ||
                    the_hero.y < -16.7 &&
                     timer + 100 - frame < 200)
                {
                    speedfactor = 1;
                }
                else if (the_hero.y < -16.7)
                {
                    speedfactor = 2;
                }
                else
                {
                    speedfactor = 4;
                }
            }
            
            frame += speedfactor;
        }
        
        if (frame < 0 && dz.baloon.inventory)
        {
            frame = 0;
        }

        if (frame >= 0 &&
            old_frame < cast(long) timer + 150 &&
            frame >= cast(long) timer + 150)
        {
            dz.collision_objects["solid"]["BeforeExplosure1"] = null;
            dz.collision_objects["solid"].remove("BeforeExplosure1");
            dz.collision_objects["solid"]["BeforeExplosure2"] = null;
            dz.collision_objects["solid"].remove("BeforeExplosure2");
            
            dz.collision_objects["solid"]["AfterExplosure1"] = 
                dz.collision_objects["temp-solid"]["AfterExplosure1"];
            dz.collision_objects["solid"]["AfterExplosure2"] = 
                dz.collision_objects["temp-solid"]["AfterExplosure2"];

            reset_collision_cache();

            if (abs(dz.the_hero.x - 422.2) < 2.0 &&
                abs(dz.the_hero.y + 18.3) < 2.0 ||
                abs(dz.the_hero.x - 421.5) < 2.0 &&
                abs(dz.the_hero.y + 15.4) < 1.5)
            {
                dz.the_hero.die("Rock");
            }
        }

        return true;
    }

    override void load(string[string] s)
    {
        string p = "platform2";
        if (p in s)
            frame = s[p].to!(long);
        else
            frame = -1;

        DizzyOmega dz = cast(DizzyOmega) root;
        if (frame < 0 || root.frame - frame < cast(long) timer + 150)
        {
            dz.collision_objects["solid"]["AfterExplosure1"] = null;
            dz.collision_objects["solid"].remove("AfterExplosure1");
            dz.collision_objects["solid"]["AfterExplosure2"] = null;
            dz.collision_objects["solid"].remove("AfterExplosure2");

            dz.collision_objects["solid"]["BeforeExplosure1"] =
                dz.collision_objects["temp-solid"]["BeforeExplosure1"];
            dz.collision_objects["solid"]["BeforeExplosure2"] =
                dz.collision_objects["temp-solid"]["BeforeExplosure2"];

            reset_collision_cache();
        }
        else
        {
            dz.collision_objects["solid"]["BeforeExplosure1"] = null;
            dz.collision_objects["solid"].remove("BeforeExplosure1");
            dz.collision_objects["solid"]["BeforeExplosure2"] = null;
            dz.collision_objects["solid"].remove("BeforeExplosure2");
            
            dz.collision_objects["solid"]["AfterExplosure1"] = 
                dz.collision_objects["temp-solid"]["AfterExplosure1"];
            dz.collision_objects["solid"]["AfterExplosure2"] = 
                dz.collision_objects["temp-solid"]["AfterExplosure2"];

            reset_collision_cache();
        }
    }

    override void save(ref string[string] s)
    {
        if (frame >= 0)
        {
            string p = "platform2";
            s[p] = frame.to!(string);
        }
    }    
}
