module unde.games.dizzy.omega.scene_loader;

import core.memory;
import std.concurrency;
import std.datetime;
import std.stdio;
import std.string;
import unde.games.collision_detector;
import unde.games.obj_loader;

private bool scene_load(ref shared ObjFile*[SC] screens,
    ref immutable string[SC] screen_names,
    int X, int Y)
{
    if (SC(X,Y) in screen_names && SC(X,Y) !in screens)
    {
        screens[SC(X,Y)] =
            cast (shared) load_objfile(format("models/screen_%02d_%02d.obj", X, Y));
    }
    
    return (SC(X,Y) in screen_names) !is null;
}


private void scene_loader_iteration(ref shared ObjFile*[SC] screens, 
    ref immutable string[SC] screen_names,
    int X, int Y, int L)
{
    scene_load(screens, screen_names, X, Y);
    scene_load(screens, screen_names, X-1, Y);
    if ( !scene_load(screens, screen_names, X, Y-1) )
        scene_load(screens, screen_names, X, Y-2);
    scene_load(screens, screen_names, X+1, Y);
    if ( !scene_load(screens, screen_names, X, Y+1) )
        scene_load(screens, screen_names, X, Y+2);

    bool collect;
    while (screens.length > L)
    {
        foreach(sc; screens.keys())
        {
            if (sc != SC(X, Y) &&
                sc != SC(X-1, Y) &&
                sc != SC(X, Y-1) &&
                sc != SC(X+1, Y) &&
                sc != SC(X, Y+1) &&
                sc != SC(X, Y-2) &&
                sc != SC(X, Y+2))
            {
                screens.remove(sc);
                collect = true;
                break;
            }
        }
    }
    
    if (collect) GC.collect();
}

void
scene_loader(shared ObjFile*[SC] *screens,
    immutable string[SC] *screen_names,
    int X, int Y, int L, Tid tid)
{
    try {
        bool finish;
        do
        {
            scene_loader_iteration(*screens, 
                *screen_names, X, Y, L);
            receiveTimeout( 100.msecs,
                    (int x, int y)
                    {
                        X = x;
                        Y = y;
                    },
                    (bool a) {
                        finish = a;
                    },
                    (OwnerTerminated ot) {
                        writefln("Abort scene_loader due stopping parent");
                        finish = true;
                    } );
        }
        while (!finish);
    } catch (shared(Throwable) exc) {
        send(tid, exc);
    }

    writefln("Finish scene loader");
    //send(tid, thisTid);
}
