module unde.draw;

import unde.global_state;

import derelict.sdl2.sdl;

void draw_screen(GlobalState gs)
{
    gs.games.dizzy_omega.draw(gs);
    SDL_RenderPresent(gs.renderer);
}
