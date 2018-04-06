module unde.global_state;

import unde.games.dizzy.omega.main;
import unde.file_manager.events;
import unde.keybar.lib;

import std.format;
import std.conv;
import std.stdio;

import std.datetime;

import std.string;

import derelict.sdl2.sdl;
import derelict.sdl2.image;

import derelict.opengl3.gl3;
import derelict.opengl3.gl;
import derelict.sdl2.mixer;

public import core.sys.posix.sys.types;

import std.file;

struct Games
{
    DizzyOmega dizzy_omega;
}

class GlobalState
{
    Games games;
    SDL_Window* window;
    SDL_Renderer* renderer;
    bool finish = false;
    uint frame; //Frame which renders
    uint time; //Time from start of program in ms
    uint fps_frames;
    uint fps_time;

    bool window_shown;

    KeyBar_Buttons keybar;
    SDL_Rect screen;

    void createWindow(size_t display = 0)
    {
        int displays = SDL_GetNumVideoDisplays();

        int x = SDL_WINDOWPOS_UNDEFINED;
        int y = SDL_WINDOWPOS_UNDEFINED;

        if (display > 0 && display < displays)
        {
            SDL_Rect displayBounds;
            auto r = SDL_GetDisplayBounds(cast(int) display, &displayBounds);
            if (r != 0)
            {
                writefln("Error SDL_GetDisplayBounds display %d: %s", display, SDL_GetError().fromStringz());
            }
            else
            {
                x = displayBounds.x;
                y = displayBounds.y;
            }
        }

        SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES, 4);
        //The window we'll be rendering to
        window = SDL_CreateWindow(
            "Dizzy Omega",                            // window title
            x,                                 // initial x position
            y,                                 // initial y position
            0,                                 // width, in pixels
            0,                                 // height, in pixels
            SDL_WINDOW_FULLSCREEN_DESKTOP | 
            SDL_WINDOW_RESIZABLE |
            SDL_WINDOW_OPENGL                  // flags
        );
        if( window == null )
        {
            throw new Exception(format("Error while create window: %s",
                    SDL_GetError().to!string()));
        }
    }

    void createRenderer()
    {
        /* To render we need only renderer (which connected to window) and
           surfaces to draw it */
        SDL_SetHint(SDL_HINT_RENDER_DRIVER, "opengl");
        renderer = SDL_CreateRenderer(
                window, 
                -1, 
                SDL_RENDERER_ACCELERATED | SDL_RENDERER_TARGETTEXTURE
        );
        if (!renderer)
        {
            writefln("Error while create accelerated renderer: %s",
                    SDL_GetError().to!string());
            renderer = SDL_CreateRenderer(
                    window, 
                    -1, 
                    SDL_RENDERER_TARGETTEXTURE
            );
        }
        if (!renderer)
        {
            throw new Exception(format("Error while create renderer: %s",
                    SDL_GetError().to!string()));
        }

        SDL_RenderClear(renderer);

        SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);

        int r = SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
        if (r < 0)
        {
            throw new Exception(
                    format("Error while set render draw blend mode: %s",
                    SDL_GetError().to!string()));
        }

        SDL_bool res = SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "1");
        if (!res)
        {
            throw new Exception(
                    format("Can't set filter mode"));
        }
    }

    void initGL()
    {
        DerelictGL.load();
        DerelictGL3.load();
        DerelictGL3.reload();

        glEnable(GL_BLEND);
        glEnable(GL_TEXTURE_2D);
        glEnable(GL_LIGHTING);
        glEnable(GL_LIGHT0);
        glLightfv(GL_LIGHT0, GL_POSITION, [-5f, -5f, 10.0f, 1.0f].ptr);
        glLightfv(GL_LIGHT0, GL_SPOT_DIRECTION, [0.5f, 0.5f, -1.0f].ptr);
        glLighti(GL_LIGHT0, GL_SPOT_EXPONENT, 64);
        glLighti(GL_LIGHT0, GL_SPOT_CUTOFF, 90);

        glEnable(GL_LIGHT1);
        glLightfv(GL_LIGHT1, GL_DIFFUSE, [0.0f, 0.08f, 0.10f, 1.0f].ptr);
        glLightfv(GL_LIGHT1, GL_SPECULAR, [0.0f, 0.0f, 0.0f, 1.0f].ptr);
        glLightfv(GL_LIGHT1, GL_POSITION, [0.0f, 0.0f, 0.0f, 1.0f].ptr);
        //glLightfv(GL_LIGHT1, GL_SPOT_DIRECTION, [0.5f, 0.5f, -1.0f].ptr);
        glLighti(GL_LIGHT1, GL_SPOT_EXPONENT, 90);
        glLighti(GL_LIGHT1, GL_SPOT_CUTOFF, 180);
        glLighti(GL_LIGHT1, GL_CONSTANT_ATTENUATION, 0);
        glLighti(GL_LIGHT1, GL_QUADRATIC_ATTENUATION, 3);

        glEnable(GL_LIGHT2);
        glLightfv(GL_LIGHT2, GL_DIFFUSE, [0.0f, 0.08f, 0.10f, 1.0f].ptr);
        glLightfv(GL_LIGHT2, GL_SPECULAR, [0.0f, 0.0f, 0.0f, 1.0f].ptr);
        glLightfv(GL_LIGHT2, GL_POSITION, [0.0f, 0.0f, 0.0f, 1.0f].ptr);
        //glLightfv(GL_LIGHT1, GL_SPOT_DIRECTION, [0.5f, 0.5f, -1.0f].ptr);
        glLighti(GL_LIGHT2, GL_SPOT_EXPONENT, 90);
        glLighti(GL_LIGHT2, GL_SPOT_CUTOFF, 180);
        glLighti(GL_LIGHT2, GL_CONSTANT_ATTENUATION, 0);
        glLighti(GL_LIGHT2, GL_QUADRATIC_ATTENUATION, 1);

        glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, GL_TRUE);
        glEnable(GL_NORMALIZE);

        glColorMaterial(GL_FRONT_AND_BACK, GL_DIFFUSE);
    }

    void syncTime()
    {
        time = SDL_GetTicks();
    }

    void startGame()
    {
        if (games.dizzy_omega is null)
        {
            games.dizzy_omega = new DizzyOmega(this);
        }
        games.dizzy_omega.toGame(this);
        setup_keybar(this);
    }

    void stopGame()
    {
        games.dizzy_omega.fromGame(this);
        finish = true;
    }

    void initSDL(size_t display = 0)
    {
        DerelictSDL2.load();
        
        if( SDL_Init( SDL_INIT_VIDEO | SDL_INIT_TIMER ) < 0 )
        {
            throw new Exception(format("Error while SDL initializing: %s",
                    SDL_GetError().to!string() ));
        }

        createWindow(display);

        createRenderer();

        SDL_GetWindowSize(window, &screen.w, &screen.h);

        initGL();

        screen.w -= 32*6;
    }

    void deInitSDL()
    {
        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
        SDL_Quit();
    }

    void initSDLImage()
    {
        DerelictSDL2Image.load();

        auto flags = IMG_INIT_PNG;
        int initted = IMG_Init(flags);
        if((initted&flags) != flags) {
            if (!(IMG_INIT_PNG & initted))
                writefln("IMG_Init: Failed to init required png support!");
            throw new Exception(format("IMG_Init: %s\n",
                        IMG_GetError().to!string()));
        }
    }

    void initSDLMixer()
    {    
        DerelictSDL2Mixer.load();
 	
        // load support for the OGG sample/music formats
        int flags=MIX_INIT_OGG;
        int initted=Mix_Init(flags);
        if((initted&flags) != flags) {
            if (!(MIX_INIT_OGG & initted))
                writefln("Mix_Init: Failed to init required ogg support!");
            throw new Exception(format("IMG_Init: %s\n",
                        Mix_GetError().to!string()));
        }

        if(Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 2, 1024)==-1) {
            throw new Exception(format("Mix_OpenAudio: %s\n",
                        Mix_GetError().to!string()));
        }
    }

    void initAllSDLLibs(size_t display = 0)
    {
        initSDLImage();
        initSDLMixer();
        initSDL(display);
    }

    void deInitAllSDLLibs()
    {
        Mix_CloseAudio();
        Mix_Quit();
        IMG_Quit();
        deInitSDL();
    }

    this(bool force_recover = false, size_t display = 0)
    {
        initAllSDLLibs(display);
        keybar = new KeyBar_Buttons(this, renderer, null);
        startGame();
    }

    ~this()
    {
        stopGame();
        deInitAllSDLLibs();
    }
}

