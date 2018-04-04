module unde.tick;

import unde.global_state;
import unde.lib;

import unde.keybar.lib;

import derelict.sdl2.sdl;

import std.stdio;
import std.datetime;

enum EventHandlerResult
{
    Pass,
    Block
}

enum unDE_MouseButtons {
    Left = 0x01,
    Middle = 0x02,
    Right = 0x04,
}

void make_tick(GlobalState gs)
{
    gs.games.dizzy_omega.tick(gs);
}

void
process_event(GlobalState gs, SDL_Event event)
{
    if (event.type == SDL_WINDOWEVENT)
    {
        switch (event.window.event) {
            case SDL_WINDOWEVENT_SHOWN:
            case SDL_WINDOWEVENT_EXPOSED:
            case SDL_WINDOWEVENT_RESTORED:
                gs.window_shown = true;
                gs.games.dizzy_omega.reinit_draw = 2;
                break;
            case SDL_WINDOWEVENT_HIDDEN:
            case SDL_WINDOWEVENT_MINIMIZED:
            case SDL_WINDOWEVENT_FOCUS_LOST:
                gs.window_shown = false;
                break;
            default:
                break;
        }
        return;
    }

    gs.games.dizzy_omega.process_event(gs, event);
}

void process_events(GlobalState gs)
{
    /* Our SDL event placeholder. */
    SDL_Event event;
    SDL_Event prev_event;

    /* Grab all the events off the queue. */
    while( SDL_PollEvent( &event ) )
    {
        KeyHandler *keyhandler;
        if (event.type == SDL_KEYDOWN)
        {
            keyhandler = event.key.keysym.scancode in gs.keybar.handlers_down;
            if (keyhandler)
            {
                keyhandler.handle(gs);
            }
        }
        else if (event.type == SDL_KEYUP)
        {
            keyhandler = event.key.keysym.scancode in gs.keybar.handlers;
            if (keyhandler)
                keyhandler.handle(gs);
        }

        if (keyhandler is null)
        {
            process_event(gs, event);
        }

        prev_event = event;
    }
}

void
make_screenshot(GlobalState gs) { 
    SDL_Surface *screenshot; 
    screenshot = SDL_CreateRGBSurface(SDL_SWSURFACE,
            gs.screen.w+32*6, 
            gs.screen.h, 
            32, 0x00FF0000, 0X0000FF00, 0X000000FF, 0XFF000000); 
    SDL_RenderReadPixels(gs.renderer, null, SDL_PIXELFORMAT_ARGB8888, 
            screenshot.pixels, screenshot.pitch);
    SDL_SaveBMP(screenshot, "screenshot.bmp"); 
    SDL_FreeSurface(screenshot); 
}

