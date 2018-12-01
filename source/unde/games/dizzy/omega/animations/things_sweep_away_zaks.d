module unde.games.dizzy.omega.animations.things_sweep_away_zaks;

import derelict.opengl3.gl;

import std.algorithm;
import std.conv;
import std.math;
import std.stdio;
import unde.games.dizzy.omega.bug;
import unde.games.dizzy.omega.grasshopper;
import unde.games.dizzy.omega.bird;
import unde.games.dizzy.omega.fish;
import unde.games.dizzy.omega.squid;
import unde.games.dizzy.omega.dizzy;
import unde.games.dizzy.omega.main;
import unde.games.object;
import unde.games.renderer;
import unde.games.collision_detector;
import unde.games.object;
import unde.global_state;

class ThingsSweepAwayZaks:StaticGameObject
{
    int frame = -1;
    bool hidden;

    StaticGameObject[] things;
    
    this(MainGameObject root)
    {
        hidden = true;
        
        x = 463.0;
        y = -158.9;
        z = 0.0;

        things = [ new Bug(root, [x, y, z], "underground-solid", true),
                   new Bug(root, [x-4.0, y, z-1.0], "underground-solid", true),
                   new Bug(root, [x-8.0, y, z+1.0], "underground-solid", true),
                   new Bug(root, [x-12.0, y, z], "underground-solid", true),
                   new Bug(root, [x-2.0, y, z-1.0], "underground-solid", true),
                   new Bug(root, [x-6.0, y, z+1.0], "underground-solid", true),
                   new Bug(root, [x-10.0, y, z], "underground-solid", true),
                   new Grasshopper(root, [x, y, z-1.0], "underground-solid", null, null),
                   new Grasshopper(root, [x-4.0, y, z+1.0], "underground-solid", null, null),
                   new Grasshopper(root, [x-8.0, y, z], "underground-solid", null, null),
                   new Grasshopper(root, [x-12.0, y, z-1.0], "underground-solid", null, null),
                   new Grasshopper(root, [x-2.0, y, z+1.0], "underground-solid", null, null),
                   new Grasshopper(root, [x-6.0, y, z], "underground-solid", null, null),
                   new Grasshopper(root, [x-10.0, y, z-1.0], "underground-solid", null, null),
                   new Bird(root, [x-5.0, y+5.0, z-5.0], x+35.0, null, 300),
                   new Bird(root, [x-10.0, y+7.0, z-5.0], x+35.0, null, 300),
                   new Bird(root, [x-15.0, y+3.0, z-5.0], x+35.0, null, 300),
                   new Fish(root, [481.1, -162.0, 0.0], 481.1, 500.0, 1.0, 0.5, -158.3, 400),
                   new Fish(root, [481.1, -164.0, 0.0], 481.1, 500.0, 0.6, 0.5, -158.3, 500),
                   new Fish(root, [481.1, -166.0, 0.0], 481.1, 500.0, 0.8, 0.5, -158.3, 600),
                   new Squid(root, [481.1, -155.72+4.0, 0.0], -158.3+4.0, -164.0, 0.03, 450),
                   new Squid(root, [481.1, -155.72+4.0, 0.0], -158.3+4.0, -164.0, 0.03, 550),
                   new Squid(root, [481.1, -155.72+4.0, 0.0], -158.3+4.0, -164.0, 0.03, 650),
                   ];
        
        super(root);
    }

    void unhide()
    {
        hidden = false;
    }

    void hide()
    {
        hidden = true;
    }

    override void draw(GlobalState gs)
    {
        if ( abs(root.scrx-x) > 32.0 &&
             abs(root.scry-y) > 18.0 )
            return;

        if (!hidden)
        {
            foreach(thing; things)
            {
                thing.draw(gs);
            }
        }
    }
    
    override bool tick(GlobalState gs)
    {
        if ( hidden || abs(root.scrx-x) > 32.0 &&
                abs(root.scry-y) > 18.0 )
            return true;

        frame++;
        foreach(thing; things)
        {
            thing.tick(gs);
        }

        return true;
    }

    override void load(string[string] s)
    {
        string p = "sweep";

        if (p in s)
            hidden = (s[p] != "not-hidden");
        else
            hidden = true;
            
        if (p~"-frame" in s)
            frame = s[p~"-frame"].to!(int);
        else
            frame = 0;

        foreach(thing; things)
        {
            thing.load(s);
        }
    }

    override void save(ref string[string] s)
    {
        string p = "sweep";
        if (!hidden)
            s[p] = "not-hidden";

        s[p~"-frame"] = frame.to!(string);
            
        foreach(thing; things)
        {
            thing.save(s);
        }
    }
}

