module unde.keybar.lib;

import derelict.sdl2.sdl;
import derelict.sdl2.ttf;
import derelict.sdl2.image;

import unde.global_state;
import unde.slash;

import std.stdio;
import std.string;
import std.math;
import std.range.primitives;
import std.file;
import std.algorithm.sorting;
import std.process;
import core.stdc.locale;
import core.sys.windows.windows;

struct KeyHandler
{
    void delegate (GlobalState gs) handler;
    string description;
    string icon;

    void handle(GlobalState gs)
    {
        handler(gs);
    }
}

struct ButtonParms
{
    SDL_Rect rect;
    SDL_Color color;
}

struct ButtonPos
{
    ushort i;
    ushort pos;
}

class KeyBar_Buttons
{
    private
    SDL_Renderer *renderer;

    bool input_mode;
    byte rec_input_mode = -1;

    string[] layout_names;

    KeyHandler[int] handlers;
    KeyHandler[int] handlers_down;
    KeyHandler[int] handlers_double;

    void delegate (GlobalState gs)[string] macros_handlers;
    string[void delegate (GlobalState gs)] handlers_macros;

    SDL_Scancode[][3] *scans_cur;
    SDL_Scancode[][3] scans;
    SDL_Scancode[][3] scans_altgr;
    ButtonPos[SDL_Scancode] buttonpos_by_scan;
    ButtonPos[SDL_Scancode] buttonpos_by_scan_altgr;

    this(GlobalState gs, SDL_Renderer *renderer, string start_cwd)
    {
        this.renderer = renderer;
        SDL_StopTextInput();
    }
}

