module unde.file_manager.events;

import unde.global_state;
import unde.lib;
import unde.keybar.lib;
import unde.tick;
import unde.slash;

import derelict.sdl2.sdl;

import std.utf;
import std.stdio;
import std.string;
import std.conv;
import std.format;
import std.datetime;
import std.functional;

import std.file;

void setup_keybar(GlobalState gs)
{
    gs.games.dizzy_omega.setup_keybar(gs);
}

