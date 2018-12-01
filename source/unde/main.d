module unde.main;

import unde.draw;
import unde.global_state;
import unde.tick;
import unde.slash;
import unde.games.dizzy.omega.main;
import unde.games.obj_splitter;
import unde.games.obj_joiner;
import unde.games.obj_loader;
import unde.games.obj_writer;

import derelict.sdl2.sdl;

import std.stdio;
import std.file;
import std.conv;
import core.stdc.stdlib;

import core.sys.posix.signal;

void split_scene()
{
    writefln("Load scene");
    auto scene1 = load_objfile("models/scene-01.obj");
    writefln("Split");
    auto scenes1 = split_objfile(scene1);
    writefln("Write scenes");
    foreach(sc, scene; scenes1)
    {
        if (sc in screen_names)
            save_objfile(scene);
    }

    writefln("Load scene");
    auto scene2 = load_objfile("models/scene-02.obj");
    writefln("Split");
    auto scenes2 = split_objfile(scene2);
    writefln("Write scenes");
    foreach(sc, scene; scenes2)
    {
        if (sc in screen_names && (sc !in scenes1 ||
            scene.objects.length > scenes1[sc].objects.length))
            save_objfile(scene);
    }

    writefln("Load solid scenes");
    auto scene1solid = load_objfile("models/scene-01-solid.obj");
    auto scene2solid = load_objfile("models/scene-02-solid.obj");
    writefln("Join");
    scene1solid.join_objfiles(scene2solid);
    scene1solid.filename = "models/scene-solid.obj";
    scene1solid.mtl.filename = "models/scene-solid.mtl";
    writefln("Write solid scene");
    save_objfile(scene1solid);

    writefln("Load dangers scenes");
    auto scene1dangers = load_objfile("models/scene-01-dangers.obj");
    auto scene2dangers = load_objfile("models/scene-02-dangers.obj");
    writefln("Join");
    scene1dangers.join_objfiles(scene2dangers);
    scene1dangers.filename = "models/scene-dangers.obj";
    scene1dangers.mtl.filename = "models/scene-dangers.mtl";
    writefln("Write dangers scene");
    save_objfile(scene1dangers);

}

extern(C) void mybye(int value){
    exit(1);
}

int main(string[] args)
{
    bool scene_splitter;
    size_t display;

    for (int i=1; i < args.length; i++)
    {
        if (args[i] == "--scene-splitter")
        {
            scene_splitter = true;
        }
        else if (args[i] == "--display")
            display = args[++i].to!size_t;
    }

    if (scene_splitter)
    {
        split_scene();
        return 0;
    }

    GlobalState gs = new GlobalState(false, display);
    version(Posix)
    {
        sigset(SIGINT, &mybye);
        
        sigset_t set;
        sigaddset(&set, SIGPIPE);
        int retcode = sigprocmask(SIG_BLOCK, &set, null);
        if (retcode == -1) throw new Exception("sigprocmask error");
    }

    /* How many frames was skipped */
    uint skipframe;
    /* How long rendering was last frame */
    uint last_draw_time;
    uint[] times;
    uint prev_time;

    /* Sum of time which was taken by rendering */
    uint drawtime;
    /* Minumum time between 2 frames */
    uint min_frame_time = 2;
    /* Maximum skip frames running */
    uint max_skip_frames = 10;

    /* Start time used in below scope(exit) to calculate avarage
       rendering time*/
    uint starttime=SDL_GetTicks();
    scope(exit)
    {
        uint endtime = SDL_GetTicks();
        writefln("FPS= %f, average draw time: %f ms",
            (cast(float)gs.frame)*1000/(endtime-starttime), 
            (cast(float)drawtime)/gs.frame);
        /* EN: Necessary because otherwise it will destroy 
           gs.dbenv, gs.db_map before and it lead to Seg.Fault
           RU: Необходим, т.к. иначе до gs будут уничтожены
           gs.dbenv, gs.db_map, что ведёт к ошибке сегментирования */
        destroy(gs);
    }

    /* The main Idea of rendering process:
       Splitting the actions which must be done on frame on 2:
       1. Process events and make tick
       2. Draw Frame
       "Draw frame" maybe skipped to catch up real time,
       But "Make tick" can't be skipped
     */
    while(!gs.finish)
    {
        uint time_before_frame=SDL_GetTicks();

        /* Process incoming events. */

        process_events(gs);

        make_tick(gs);
        stdout.flush();

        uint now=SDL_GetTicks();
        /* Draw the screen. */
        /* Don't skip frame when:
            1. Too much frame skipped
            2. The virtual time (gs.time) too big (more than real time)
            3. Estimation time of the next frame less than minimum frame time  */
        if ( skipframe>=max_skip_frames || (gs.time+250.0)>now ||
                (now+last_draw_time)<(time_before_frame+min_frame_time) )
        {
            uint time_before_draw=SDL_GetTicks();

            if (gs.window_shown)
                draw_screen(gs);

            last_draw_time=SDL_GetTicks()-time_before_draw;
            drawtime+=last_draw_time;

            //gs.txn.commit();

            gs.frame++;
            skipframe=0;
        }
        else skipframe++;

        now=SDL_GetTicks();

        /* Calculate FPS */
        gs.fps_frames++;
        gs.fps_time += now - prev_time;
        times ~= now - prev_time;
        if (gs.fps_frames > 100)
        {
            gs.fps_time -= times[0];
            gs.fps_frames--;
            times = times[1..$];
        }
        prev_time = now;
        
        /* Virtual time more real time? */
        if (gs.time>now)
            SDL_Delay(gs.time-now);
        else /* If time of frame too small */
            if ( (now - time_before_frame)<min_frame_time )
                SDL_Delay( min_frame_time - (now - time_before_frame) );
        
        /* Add 10 ms to time, because we want render with speed 100 FPS
           1 frame / 100 FPS = 1/100s = 10ms */
        gs.time += 10;

    }
    return 0;
}
