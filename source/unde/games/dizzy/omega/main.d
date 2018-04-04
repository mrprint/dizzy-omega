module unde.games.dizzy.omega.main;

import derelict.sdl2.mixer;
import derelict.sdl2.sdl;
import derelict.opengl3.gl3;
import derelict.assimp3.assimp;
import derelict.opengl3.gl;

import std.algorithm.comparison;
import std.algorithm.searching;
import std.conv;
import std.format;
import std.functional;
import std.random;
import std.range.primitives;
import std.stdio;
import std.math;

import std.string;
import unde.games.dizzy.omega.animations.bag_bug_anim;
import unde.games.dizzy.omega.animations.bucket;
import unde.games.dizzy.omega.animations.drop;
import unde.games.dizzy.omega.animations.fall_platform;
import unde.games.dizzy.omega.animations.ground_garden;
import unde.games.dizzy.omega.animations.light_drop;
import unde.games.dizzy.omega.animations.meteorite;
import unde.games.dizzy.omega.animations.platform1;
import unde.games.dizzy.omega.animations.explosure;
import unde.games.dizzy.omega.animations.sky_zaks;
import unde.games.dizzy.omega.animations.stalagmite;
import unde.games.dizzy.omega.animations.stone_00;
import unde.games.dizzy.omega.animations.stone_01;
import unde.games.dizzy.omega.animations.stone_02;
import unde.games.dizzy.omega.bug;
import unde.games.dizzy.omega.dialogs;
import unde.games.dizzy.omega.dizzy;
import unde.games.dizzy.omega.dog;
import unde.games.dizzy.omega.item;
import unde.games.dizzy.omega.rope;
import unde.games.dizzy.omega.rotatable;
import unde.games.dizzy.omega.save_load;
import unde.games.dizzy.omega.star;
import unde.games.dizzy.omega.tree;
import unde.games.object;
import unde.games.renderer;
import unde.games.collision_detector;
import unde.global_state;
import unde.keybar.lib;
import unde.tick;

enum STATE
{
    NO_DIALOGS = 0,
    INVENTORY = 1,
    ENERGY_STAR = 2,
    TOO_MANY_ITEMS = 3,
    PIERCED_BY_STALAGMITE = 4,
    PIERCED_BY_STALACTITE = 5,
    HIT_BY_METEORITE = 6,
    DISSOLVED_IN_ACID = 7,
    BURNED_IN_LAVA = 8,
    DAMAGED_BY_PIN = 9,
    HIT_BY_ROCK = 10,
    HELP = 99,
    MARTIAN_AGRONOMIST_HELLO  = 100,
    MARTIAN_AGRONOMIST_HELLO1 = 101,
    MARTIAN_AGRONOMIST_HELLO2 = 102,
    MARTIAN_AGRONOMIST_HELLO3 = 103,
    MARTIAN_AGRONOMIST_HELLO4 = 104,
    MARTIAN_AGRONOMIST_HELLO5 = 105,
    MARTIAN_AGRONOMIST_HELLO6 = 106,
    LOOKING_BOOTH_MESSAGE = 200,
    LOOKING_BOOTH = 201,
    DIZZY_USED_KNIFE_MESSAGE = 300,
    DIZZY_USED_KNIFE_ANIM = 301,
    DIZZY_THROW_BRANCH_MESSAGE = 400,
    DIZZY_THROW_BRANCH_ANIM = 401,
    DIZZY_CUTS_ROPE_MESSAGE = 500,
    DIZZY_CUTS_ROPE_ANIM = 501,
    MARTIAN_ENGINEER_GET_AWAY = 600,
    MARTIAN_AGRONOMIST_ROPE = 700,
    MARTIAN_ENGINEER_TAKES_PLAYER = 800,
    DIZZY_TIED_ROPE_MESSAGE = 900,
    DIZZY_UNTIED_ROPE_MESSAGE = 901,
    MARTIAN_CHEMIST_HELLO  = 1000,
    MARTIAN_CHEMIST_HELLO1 = 1001,
    MARTIAN_CHEMIST_HELLO2 = 1002,
    MARTIAN_CHEMIST_HELLO3 = 1003,
    MARTIAN_CHEMIST_HELLO4 = 1004,
    MARTIAN_CHEMIST_HELLO5 = 1005,
    DIZZY_DRINK_STUNNING_MESSAGE = 1100,
    MARTIAN_AGRONOMIST_GIVES_BUCKET  = 1200,
    MARTIAN_AGRONOMIST_GIVES_BUCKET1 = 1201,
    DIZZY_TRIES_FILL_BUCKET_MESSAGE = 1300,
    DIZZY_THROW_METEORITE_MESSAGE = 1400,
    DIZZY_FILL_BUCKET_MESSAGE = 1500,
    DIZZY_TRIES_WATER_FLOWERS_MESSAGE = 1600,
    DIZZY_COVERED_BUCKET_MESSAGE = 1700,
    DIZZY_WATER_FLOWERS_MESSAGE = 1800,
    MARTIAN_AGRONOMIST_THANKS = 1900,
    MARTIAN_ENGINEER_RETURNS_PLAYER  = 2000,
    MARTIAN_ENGINEER_RETURNS_PLAYER1 = 2001,
    MARTIAN_ENGINEER_RETURNS_PLAYER2 = 2002,
    MARTIAN_ENGINEER_TAKES_BUCKET  = 2100,
    MARTIAN_ENGINEER_TAKES_BUCKET1 = 2101,
    DIZZY_HOLD_BRANCH_UNDER_DROP = 2200,
    MARTIAN_ENGINEER_GIVES_SPADE = 2300,
    DIZZY_DIG_MESSAGE = 2400,
    DIZZY_DIG_ANIM = 2401,
    TO_BE_CONTINUED_MESSAGE = 2500,
}

enum TEMP_MESSAGES
{
    CANT_SAVE_IN_THE_MOVING,
    CANT_SAVE_DURING_THE_QUEST,
    SAVED,
    NEGATIVE_LIVES,
    PLAYS
}

class DizzyOmega:MainGameObject
{
    const (aiScene)*[10] energy_star;
    Item[] items;
    size_t[] inventory;
    GLuint[string] textures;
    Star[] stars;
    Tree[] trees;
    StaticGameObject[] animations;
    Dialogs dialogs;
    Star star0;
    Item blanket;
    Item branch;
    Item player;
    Item rope;
    Item baloon;
    Item stunning_drink;
    Item bottle;
    Item bucket;
    Item bucket_of_water;
    Item bucket_of_ice;
    Item bucket_covered;
    Item meteorite;
    Item spade;
    Item light_branch;
    Item short_rope;
    Item stone2;
    Bucket bucket_anim;
    Rope rope1;
    Rope rope2;
    GroundGarden ground_garden;
    int rope_state;
    
    Mix_Music *energy_minus;
    Mix_Music *energy_plus;
    long energy_start_tick = -1;
    bool music = true;
    Mix_Music *music1;
    float music1_len;
    long music_start_tick = -1;
    
    //float stopped_music_position;
    MUSIC_STATE music_state;

    enum MUSIC_STATE
    {
        MUSIC,
        ENERGY_PLUS,
        ENERGY_MINUS,
    }

    GLuint scene_list;

    enum LANG
    {
        EN = 0,
        RU = 1,
        MAX= 1,
    }

    LANG lang;
    
    string[string] names; 
    string[string] names_ru;

    string[TEMP_MESSAGES] temp_messages;
    string[TEMP_MESSAGES] temp_messages_ru;
    TEMP_MESSAGES temp_message;
    string temp_message_str;
    long temp_message_frame_from;
    long temp_message_frame_to;

    struct SC
    {
        int x, y;
    }

    string[SC] screen_names;
    string[SC] screen_names_ru;

    int reinit_draw;
    bool[string] done_dialogs;

    Random rnd;

    Dizzy the_hero;
    BagBugAnim bag_bug_anim;
    Dog dog;
    Rotatable martian_engineer;
    Explosure explosure;

    int dizzy_used_knife_quest_state = -1;
    int dizzy_throw_branch_quest_state = -1;
    int dizzy_cuts_rope_quest_state = -1;
    int dizzy_live_after_explosure_quest_state = -1;
    int dizzy_water_flowers_state = -1;
    int wait_meteorite = -1;

    struct BranchQuestVariables {
        int st;
        float degree;
        float x, y;
        float dx, dy;
    }
    
    BranchQuestVariables branch_quest_variables;

    this(GlobalState gs)
    {
        textures["font"] = load_texture("models/dizzy/font.png", true, 5);
        
        toGame(gs);
        loadingMessage(gs);
        
        foreach(model; ["dizzy", "dizzy-cosmonaut", "kitchen-knife", "blanket",
                        "stone", "bag", "fish-rod", "rocket", "zaks-face",
                        "light-drop", "drop", "branch", "bug",
                        "dog", "martian-engineer", "martian-chemist",
                        "player",
                        "rope", "before-explosure",
                        "after-explosure-down", "after-explosure-up",
                        "bomb", "baloon", "explosure",
                        "stunning-drink", "bottle",
                        "umbrella", "bucket", "bucket-of-water",
                        "bucket-of-ice", "bucket-covered",
                        "bucket-out-water", "bucket-water",
                        "meteorite", "spade", "light-branch",
                        "short-rope",
                        "oiler", "grenade",
                        "branch-of-tree-full", "branch-of-tree-cut",
                        "branch-on-tree",
                        "stalagmite", "fall-platform-0",
                        "platform1", "platform2",
                        "ground-garden", "ground-garden-1", "ground-garden-2",
                        "ground-garden-3",])
        {
            models[model] = aiImportFile(format("models/%s.obj", model).toStringz(), aiProcessPreset_TargetRealtime_MaxQuality);
        }

        models["stone1"] = models["stone"];
        models["stone2"] = models["stone"];
        
        models["scene"] = aiImportFile("models/scene-01.obj", aiProcessPreset_TargetRealtime_MaxQuality);
        models["solid"] = aiImportFile("models/scene-01-solid.obj", aiProcessPreset_TargetRealtime_MaxQuality);
        models["water"] = aiImportFile("models/scene-01-water.obj", aiProcessPreset_TargetRealtime_MaxQuality);
        models["clouds"] = aiImportFile("models/scene-01-clouds.obj", aiProcessPreset_TargetRealtime_MaxQuality);
        models["dangers"] = aiImportFile("models/scene-01-dangers.obj", aiProcessPreset_TargetRealtime_MaxQuality);
        models["temp-solid"] = aiImportFile("models/temp-solid.obj", aiProcessPreset_TargetRealtime_MaxQuality);

        foreach(i; 0..14)
        {
            models[format("tree-%02d", i)] = 
                aiImportFile(format("models/mars-tree-%02d.obj", i).toStringz,
                    aiProcessPreset_TargetRealtime_MaxQuality);
        }
        
        models["stone-00"] = aiImportFile("models/stone-00.obj", aiProcessPreset_TargetRealtime_MaxQuality);
        models["stone-01"] = aiImportFile("models/stone-01.obj", aiProcessPreset_TargetRealtime_MaxQuality);
        models["stone-02"] = aiImportFile("models/stone-02.obj", aiProcessPreset_TargetRealtime_MaxQuality);

        models["meteorite-01"] = aiImportFile("models/meteorite-01.obj", aiProcessPreset_TargetRealtime_MaxQuality);
        models["meteorite-02"] = aiImportFile("models/meteorite-02.obj", aiProcessPreset_TargetRealtime_MaxQuality);
        models["meteorite-03"] = aiImportFile("models/meteorite-03.obj", aiProcessPreset_TargetRealtime_MaxQuality);
        
        models["small-stone-00"] = aiImportFile("models/small-stone-00.obj", aiProcessPreset_TargetRealtime_MaxQuality);
        
        for (int i=0; i < 10; i++)
        {
            models["star-"~i.to!(string)] = aiImportFile(("models/energy-star-"~i.to!(string)~".obj").toStringz(), aiProcessPreset_TargetRealtime_MaxQuality);
        }

        collision_objects["solid"] = null;
        scene_to_collision_object (models["solid"], collision_objects["solid"]);
        collision_objects["water"] = null;
        scene_to_collision_object (models["water"], collision_objects["water"]);
        collision_objects["clouds"] = null;
        scene_to_collision_object (models["clouds"], collision_objects["clouds"]);
        collision_objects["dangers"] = null;
        scene_to_collision_object (models["dangers"], collision_objects["dangers"]);
        collision_objects["temp-solid"] = null;
        scene_to_collision_object (models["temp-solid"], collision_objects["temp-solid"]);

        models["bug-solid"] = aiImportFile("models/bug-collisions.obj", aiProcessPreset_TargetRealtime_MaxQuality);
        collision_objects["bug-solid"] = null;
        scene_to_collision_object (models["bug-solid"], collision_objects["bug-solid"]);

        collision_objects["solid"]["BranchForBreak"] = collision_objects["temp-solid"]["BranchForBreak"];
        collision_objects["solid"]["Platform1"] = collision_objects["temp-solid"]["Platform1"];
        collision_objects["solid"]["Platform2"] = collision_objects["temp-solid"]["Platform2"];
        collision_objects["solid"]["BeforeExplosure1"] = collision_objects["temp-solid"]["BeforeExplosure1"];
        collision_objects["solid"]["BeforeExplosure2"] = collision_objects["temp-solid"]["BeforeExplosure2"];
        collision_objects["solid"]["GroundGarden"] = collision_objects["temp-solid"]["GroundGarden~1"];
        collision_objects["solid"]["Stone2"] = collision_objects["temp-solid"]["Stone2"];

        items = [new Item(this, [93.7, -4.9, 0.0], "kitchen-knife"),
                 new Item(this, [223.1, 2.9, 0.0], "stone1"),
                 new Item(this, [309.0, 34.5, 3.0], "fish-rod"),
                 branch = new Item(this, [330.0, 34.0, 0.0], "branch"),
                 light_branch = new Item(this, [390.0, 34.0, 0.0], "light-branch"),
                 player = new Item(this, [120.0, 34.0, 0.0], "player"),
                 rope = new Item(this, [280.0, 34.0, 0.0], "rope"),
                 baloon = new Item(this, [433.0, -22.0, 0.0], "baloon"),
                 stunning_drink = new Item(this, [450.0, 34.0, 0.0], "stunning-drink"),
                 bottle = new Item(this, [450.0, 34.0, 0.0], "bottle"),
                 new Item(this, [511.5, -6.6, -2.6], "umbrella"),
                 stone2 = new Item(this, [334.6, 34.0, 0.0], "stone2"),
                 bucket = new Item(this, [280.0, 34.0, 0.0], "bucket"),
                 bucket_of_water = new Item(this, [280.0, 34.0, 0.0], "bucket-of-water"),
                 bucket_of_ice = new Item(this, [280.0, 34.0, 0.0], "bucket-of-ice"),
                 bucket_covered = new Item(this, [280.0, 34.0, 0.0], "bucket-covered"),
                 blanket = new Item(this, [210.7, -6.4, 0.0], "blanket"),
                 meteorite = new Item(this, [150.0, 34.0, 0.0], "meteorite"),
                 spade = new Item(this, [390.0, 34.0, 0.0], "spade"),
                 short_rope = new Item(this, [360.0, 34.0, 0.0], "short-rope"),
                 new Item(this, [-30.1, -7.3, 0.0], "oiler"),
                 new Item(this, [-40.6, -2.6, 0.0], "grenade"),];

        stars = [new Star(this, [21.6, -3.0, 0.0]),
                 new Star(this, [84.3, -3.4, 0.0]),
                 new Star(this, [189.0, 2.5, 0.0]),
                 new Star(this, [273.0, 3.0, 0.0]),
                 new Star(this, [270.0, -5.2, 0.0]),
                 new Star(this, [295.0, -1.2, 0.0]),
                 new Star(this, [293.2, 38.4, 3.0]),
                 new Star(this, [326.5, 2.24, -0.9]),
                 new Star(this, [357.8, 3.9, 0.9]),
                 new Star(this, [402.7, -2.3, 0.0]),
                 star0 = new Star(this, [418.7, 5.2, 0.0]),
                 new Star(this, [436.0, 5.0, 0.0]),
                 new Star(this, [466.4, 1.7, 0.0]),
                 new Star(this, [511.5, -6.6, 0.0]),
                 new Star(this, [572.8, 1.5, 0.0]),];

        trees = [new Tree(this, 2.7, [4.0, -7.5, 0.7], 0),
                 new Tree(this, 2.47, [97.7, -2.7, 0.7], 1),
                 new Tree(this, 4.44, [108.0, -5.5, 2.1], 2),
                 new Tree(this, 3.0, [114.0, -5.9, 0.9], 3),
                 new Tree(this, 1.9, [115.0, 0.2, 1.6], 4),
                 new Tree(this, 1.9, [116.6, 0.3, -1.6], 5),
                 new Tree(this, 2.54, [119.2, 0.2, 2.1], 6),
                 new Tree(this, 4.1, [122.0, -6.3, -2.0], 7),
                 new Tree(this, 3.5, [128.0, -3.1, 1.4], 8),
                 new Tree(this, 3.2, [137.2, -5.3, 0.7], 9),
                 new Tree(this, 3.5, [150.0, -4.9, 1.6], 10),
                 new Tree(this, 3.0, [158.3, -4.5, 1.1], 11),
                 new Tree(this, 3.3, [169.7, -6.1, 1.6], 12),
                 new Tree(this, 3.1, [180.0, -6.5, 0.7], 13),
                 ];
        
        the_hero = new Dizzy(this, [-7.0, -7.2, 0.0]);

        bag_bug_anim = new BagBugAnim(this);

        rnd = Random(28);
        
        animations = [new Stone00(this, the_hero),
                      new Stone01(this, the_hero),
                      new Stone02(this, the_hero),
                      new SkyZaks(this, the_hero),
                      new Stalagmite(this, the_hero),
                      new Meteorite(this, the_hero, rnd),
                      new LightDrop(this),
                      new Drop(this, 197.4, 2.1, 1.8, -6.2, -1.6, 0),
                      new Drop(this, 305.5, 8.4, 8.3, 5.1, 3.9, 0),
                      new Drop(this, 306.8, 8.4, 8.3, 5.6, 3.9, 100),
                      new Drop(this, 308.2, 8.4, 8.3, 5.6, 3.9, 150),
                      new Drop(this, 311.3, 8.4, 8.3, 5.6, 3.9, 225),
                      new Drop(this, 454.8, 0.8, 0.6, -6.3, 1.9, 0),
                      new Drop(this, 458.9, 0.8, 0.6, -2.0, 1.9, 50),
                      new Drop(this, 461.9, 0.8, 0.6, -2.0, 1.9, 250),
                      new Drop(this, 457.3, -2.8, -3.0, -6.3, 1.9, 280),
                      new Drop(this, 458.9, -2.8, -3.0, -6.3, 1.9, 220),
                      new Drop(this, 460.6, -2.8, -3.0, -6.3, 1.9, 120),
                      new Drop(this, 461.6, -2.8, -3.0, -6.3, 1.9, 180),
                      new FallPlatform(this, the_hero, [247.3, 2.1, 0.0], 0),
                      new Bug(this, [252.0, -5.6, 0.0], "bug-solid"),
                      dog = new Dog(this, [362.0, -3.5, 0.0], [359.5, -2.4, 3.0], -5.1, 20, 0.5, the_hero),
                      martian_engineer = new Rotatable(this, [401.8, 2.7, 0.0], 90.0, "martian-engineer"),
                      new Rotatable(this, [463.2, 1.7, 2.1], 0.0, "martian-chemist"),
                      new Platform1(this, [418.5, 4.6, 0.0]),
                      explosure = new Explosure(this, [416.4, -20.7, 0.0], [425.4, -16.7, 0.0], [412.4, -20.5, 0.0], the_hero),
                      bucket_anim = new Bucket(this),
                      ground_garden = new GroundGarden(this),];

        rope1 = new Rope(root, [418.1, 1.3, 0.7], [416.9, 1.3, 0.0], -13.0, 30, 0.5, 3);
        rope2 = new Rope(root, [245.0, 2.2, 0.7], [246.2, 2.2, 0.0], -5.0, 7, 0.5, 3);
        
        textures["live"] = load_texture("models/dizzy/dizzy-live.png");
        textures["energy"] = load_texture("models/dizzy/energy.png");

        names =
        [
            "kitchen-knife": "Kitchen Knife",
            "blanket": "Quilted Blanket",
            "stone1": "Stone",
            "stone2": "Stone",
            "fish-rod": "Fish Rod",
            "branch": "Branch",
            "light-branch": "Light Branch",
            "player": "Player",
            "rope": "Rope",
            "baloon": "Baloon",
            "stunning-drink": "Stunning drink",
            "bottle": "Bottle",
            "umbrella": "Umbrella",
            "bucket": "Bucket",
            "bucket-of-water": "Bucket Of Water",
            "bucket-of-ice": "Bucket Of Ice",
            "bucket-covered": "Covered Bucket of Water",
            "meteorite": "Meteorite",
            "spade": "Spade",
            "short-rope": "Short Rope",
            "oiler": "Oiler",
            "grenade": "Hand Grenade",
        ];

        names_ru =
        [
            "kitchen-knife": "Кухонный нож",
            "blanket": "Ватное Одеяло",
            "stone1": "Камень",
            "stone2": "Камень",
            "fish-rod": "Удочка",
            "branch": "Ветка",
            "light-branch": "Сияющая ветка",
            "player": "Плеер",
            "rope": "Верёвка",
            "baloon": "Воздушный шар",
            "stunning-drink": "Напиток \"Сногсшибающий\"",
            "bottle": "Бутылка",
            "umbrella": "Зонт",
            "bucket": "Ведро",
            "bucket-of-water": "Ведро воды",
            "bucket-of-ice": "Ведро льда",
            "bucket-covered": "Накрытое Ведро с Водой",
            "meteorite": "Метеорит",
            "spade": "Лопата",
            "short-rope": "Короткая Верёвка",
            "oiler": "Маслёнка",
            "grenade": "Ручная Граната",
        ];

        screen_names =
        [
            SC(-1,0): "Entrance to cave",
            SC(0, 0): "The landing place",
            SC(1, 0): "The cave of light tree",
            SC(2, 0): "The valley of death",
            SC(3, 0): "The valley of death",
            SC(4, 0): "The martian well",
            SC(5, 0): "Under the open sky of Mars",
            SC(6, 0): "Entrance to the cave of an extinct volcano",
            SC(7, 0): "In the cave",
            SC(8, 0): "In the cave",
            SC(9, 0): "The first Martian",
            SC(10,0): "Farmstead of the agronomist",
            SC(10,2): "Barn of the agronomist",
            SC(11,0): "Garden",
            SC(12,0): "Entrance to the secret laboratory",
            SC(13,0): "The engineer",
            SC(14,0): "Muzzle of the volcano",
            SC(14,-1): "Muzzle of the volcano",
            SC(15,0): "Chemical laboratory",
            SC(16,0): "Cave corridor",
            SC(17,0): "Corridor in the cave",
            SC(18,0): "Exit from the cave of volcano",
            SC(19,0): "Walls of the castle",
            SC(19,1): "Walls of the castle",
        ];

        screen_names_ru =
        [
            SC(-1,0): "Вход в пещеру",
            SC(0, 0): "Место посадки",
            SC(1, 0): "Пещера сияющего дерева",
            SC(2, 0): "Долина смерти",
            SC(3, 0): "Долина смерти",
            SC(4, 0): "Марсианский колодец",
            SC(5, 0): "Под открытым небом Марса",
            SC(6, 0): "Вход в пещеру потухшего вулкана",
            SC(7, 0): "В пещере",
            SC(8, 0): "В пещере",
            SC(9, 0): "Первый марсианин",
            SC(10,0): "Усадьба агронома",
            SC(10,2): "Сарай агронома",
            SC(11,0): "Сад",
            SC(12,0): "Вход в секретную лабораторию",
            SC(13,0): "Инженер",
            SC(14,0): "Жерло вулкана",
            SC(14,-1): "Жерло вулкана",
            SC(15,0): "Химическая лаборатория",
            SC(16,0): "Пещерный коридор",
            SC(17,0): "Коридор пещерный",
            SC(18,0): "Выход из пещеры вулкана",
            SC(19,0): "Стены замка",
            SC(19,1): "Стены замка",
        ];

        temp_messages =
        [
            TEMP_MESSAGES.CANT_SAVE_IN_THE_MOVING: "Can't save in the moving",
            TEMP_MESSAGES.CANT_SAVE_DURING_THE_QUEST: "Can't save during the quest",
            TEMP_MESSAGES.SAVED: "Saved",
            TEMP_MESSAGES.NEGATIVE_LIVES: "Negative amount of lives",
            TEMP_MESSAGES.PLAYS: "Plays",
        ];

        temp_messages_ru =
        [
            TEMP_MESSAGES.CANT_SAVE_IN_THE_MOVING: "Не могу сохранить в движении",
            TEMP_MESSAGES.CANT_SAVE_DURING_THE_QUEST: "Не могу сохранить во время квеста",
            TEMP_MESSAGES.SAVED: "Сохранено",
            TEMP_MESSAGES.NEGATIVE_LIVES: "Отрицательное число жизней",
            TEMP_MESSAGES.PLAYS: "Звучит",
        ];

        dialogs = new Dialogs(this);

        /*if (scene) {
            get_bounding_box(scene, &scene_min, &scene_max);
            scene_center.x = (scene_min.x + scene_max.x) / 2.0f;
            scene_center.y = (scene_min.y + scene_max.y) / 2.0f;
            scene_center.z = (scene_min.z + scene_max.z) / 2.0f;
        }
        else
            throw new Exception(format("Error while aiImportFile"));*/

        scene_list = glGenLists(1);
        if (scene_list <= 0)
            throw new Exception(format("Error while glGenLists: %s", scene_list));
        glNewList(scene_list, GL_COMPILE);
        recursive_render(gs, models["scene"], null, null, true);
        glEndList();

        energy_minus = Mix_LoadMUS("sounds/energy-minus.ogg");
        if(!energy_minus) {
            writefln("Mix_LoadMUS 'sounds/energy_minus.ogg': %s", Mix_GetError().to!(string)());
        }

        energy_plus = Mix_LoadMUS("sounds/energy-plus.ogg");
        if(!energy_plus) {
            writefln("Mix_LoadMUS 'sounds/energy_plus.ogg': %s", Mix_GetError().to!(string)());
        }

        music1 = Mix_LoadMUS("music/GraveBeholders_TheSadnessOfMyWorld.ogg");
        if(!music1) {
            writefln("Mix_LoadMUS 'music/GraveBeholders_TheSadnessOfMyWorld.ogg': %s", Mix_GetError().to!(string)());
        }
        music1_len = 632.0;

        music_start_tick = cast(long)SDL_GetTicks();

        super(this);

        gs.syncTime();
    }

    ~this()
    {
        /*foreach (model; models)
        {
            aiReleaseImport(model);
        }
        aiDetachAllLogStreams();*/
    }

    void loadingMessage(GlobalState gs)
    {
        glClearColor(0.0, 0.0, 0.0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glDisable(GL_LIGHTING);
        
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
        
        float tmp = aspectRatio/15.0;
        glScalef(tmp, tmp, tmp);

        glRotatef(15.0+params[7]*10,-1,1,0);
        glRotatef(1.0443,0,0,1);
        glScalef(0.75, 0.75, 0.75);
        glTranslatef(2.2, 2.0, 0.0);

        glPushMatrix();
        glTranslatef(-5.0, 1.0, 0.0);

        glBindTexture(GL_TEXTURE_2D, textures["font"]);
        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
        glEnable(GL_COLOR_MATERIAL);
        glColor4f(1.0, 1.0, 0.0, 1.0);
        print_text("Loading...\n"~
                   "Please wait");
        glPopMatrix();
        
        glScalef(0.5, 0.5, 0.5);
        glTranslatef(-34.0, -14.0, 0.0);
        glColor4f(0.75, 0.75, 0.75, 1.0);
        print_text("   \"Dizzy\", \"The Yolkfolk\" and all related characters and titles\n"~ 
                   "are trademarks of Oliver Twins Limited and The Codemasters Software\n"~
                   "                            Company Limited.");
        glEnable(GL_LIGHTING);
        
        SDL_RenderPresent(gs.renderer);
    }

    double aspectRatio;

    void initViewPort(int w, int h)
    {
        aspectRatio = cast(double) w / h;

        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();

        GLfloat windowWidth; GLfloat windowHeight;
        if (w <= h)
        {
            windowWidth = 1;
            windowHeight = 1/aspectRatio;
            glOrtho(-windowWidth, windowWidth, -windowHeight, windowHeight, 100.0, -100.0);
        }
        else
        {
            windowWidth = 1*aspectRatio;
            windowHeight = 1;
            glOrtho(-windowWidth, windowWidth, -windowHeight, windowHeight, 100.0, -100.0);
        }

        glViewport(0, 0, w, h);

        //Initialize Modelview Matrix
        glMatrixMode( GL_MODELVIEW );
        glLoadIdentity();
    }

    void toGame(GlobalState gs)
    {
        SDL_SetRenderTarget(gs.renderer, null);
        initViewPort(gs.screen.w+32*6, gs.screen.h);
        glEnable(GL_DEPTH_TEST);
        glEnable(GL_CULL_FACE);
        glEnable(GL_TEXTURE_2D);
        glUseProgram(0);

        if (music)
        {
            if (Mix_PlayMusic(music1, -1) == -1)
            {
                writefln("Mix_PlayMusic: %s",
                    Mix_GetError().to!(string)());
            }
    
            if(Mix_SetMusicPosition((
                (SDL_GetTicks() - music_start_tick)/1000.0)%
                music1_len) == -1) {
                writefln("Mix_SetMusicPosition: %s\n",
                    Mix_GetError().to!(string)());
            }
        }

        print_message(TEMP_MESSAGES.PLAYS, " Grave Beholders: The Sadness Of My World");       
    }

    void fromGame(GlobalState gs)
    {
        glDisable(GL_DEPTH_TEST);
        glDisable(GL_CULL_FACE);
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();

        Mix_HaltMusic();
        Mix_HaltChannel(-1);
    }

    float[8] params = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
    bool p_changed;

    void parametrizer()
    {
        int i;
        if (keys & CTRL_KEY)
            i += 1;
        if (keys & SHIFT_KEY)
            i += 2;        
        
        if (keys & LEFT_KEY)
            params[i*2+0] -= 0.01;
        if (keys & RIGHT_KEY)
            params[i*2+0] += 0.01;
            
        if (keys & DOWN_KEY)
            params[i*2+1] -= 0.01;
        if (keys & UP_KEY)
            params[i*2+1] += 0.01;

        if (keys & (LEFT_KEY|RIGHT_KEY|DOWN_KEY|UP_KEY))
        {
            p_changed = true;
        }
        else
        {
            if (p_changed) writefln("params = %s", params);
            p_changed = false;
        }
    }

    int draw_tree;

    override void draw(GlobalState gs)
    {
        float tmp;

        if (reinit_draw > 0)
        {
            toGame(gs);
            reinit_draw--;
        }

        glClearColor(0.0, 0.0, 0.0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();

        glRotatef(15.0+params[7]*10,-1,1,0);
        glRotatef(1.0443,0,0,1);

        tmp = aspectRatio/15.0;
        glScalef(tmp, tmp, tmp);

        bool star_found;
        foreach(star; stars)
        {
            star_found = star.set_light(gs);
            if (star_found) break;
        }
        
        if (!star_found)
            glDisable(GL_LIGHT1);

        // Light Tree
        if (scrx == 0.0 && scry == 0.0)
        {
            glEnable(GL_LIGHT2);
            glLightfv(GL_LIGHT2, GL_POSITION, [11.8f, -5.8f, 1.0f, 1.0f].ptr);
            glLightfv(GL_LIGHT2, GL_DIFFUSE,
                [0.0f,
                 cast(float)(0.065f + 0.03*sin(cast(float)frame/50)),
                 cast(float)(0.065f + 0.03*cos(cast(float)frame/50)),
                 1.0f].ptr);
        }
        else
        {
            glDisable(GL_LIGHT2);
        }            

        //Sky
        glEnable(GL_COLOR_MATERIAL);
        glDisable(GL_LIGHTING);
        glBindTexture(GL_TEXTURE_2D, 0);
        glPushMatrix();
        glTranslatef(-2.0, -2.0, 0.0);
        glBegin(GL_POLYGON);
        glColor4f(0.965, 0.665, 0.644, 1.0);
        glVertex3f(16.0, 16.0/aspectRatio, 10.0);
        glVertex3f(-16.0, 16.0/aspectRatio, 10.0);
        glColor4f(1.000, 0.807, 0.617, 1.0);
        glVertex3f(-16.0, -16.0/aspectRatio, 10.0);
        glVertex3f(16.0, -16.0/aspectRatio, 10.0);
        glEnd();
        glPopMatrix();
        glColor4f(1.0, 1.0, 1.0, 1.0);
        glDisable(GL_COLOR_MATERIAL);

        glPushMatrix();
        glTranslatef(-scrx, -scry, 0.0);

        the_hero.draw(gs);

        foreach(star; stars)
        {
            star.draw(gs);
        }

        stars[0].force_draw(gs);

        if (the_hero.show_sensors)
            recursive_render(gs, models["solid"]);
        else
        {
            //recursive_render(gs, models["scene"], null, null, [scrx-16, scry-10, -10, scrx+16, scry+10, 10]);
            glCallList(scene_list);
        }

        foreach(tree; trees)
        {
            tree.draw(gs);
        }

        foreach(anim; animations)
        {
            anim.draw(gs);
        }
        
        bag_bug_anim.draw(gs);

        if (dizzy_used_knife_quest_state <= 0)
        {
            glPushMatrix();
            glTranslatef(331.78, -3.85, 4.0);
            recursive_render(gs, models["branch-of-tree-full"]);
            glPopMatrix();
        }
        else
        {
            glPushMatrix();
            glTranslatef(331.78, -3.85, 4.0);
            recursive_render(gs, models["branch-of-tree-cut"]);
            glPopMatrix();

            float f = the_hero.frame;

            if (dizzy_used_knife_quest_state == 1 && f < 100.0)
            {
                glPushMatrix();
                glTranslatef(326.40, 2.01 - 8.0*f/100.0, -0.50);
                glRotatef(f*8.0, 0.0, 0.0, 1.0);
                recursive_render(gs, models["branch-on-tree"]);
                glPopMatrix();
            }
            else if (dizzy_used_knife_quest_state <= 2)
            {
                glPushMatrix();
                glTranslatef(326.40, -6.0, -0.50);
                glRotatef(800.0, 0.0, 0.0, 1.0);
                recursive_render(gs, models["branch-on-tree"]);
                glPopMatrix();
            }
        }

        if (dizzy_throw_branch_quest_state == 1 || dizzy_throw_branch_quest_state == 2)
        {
            glPushMatrix();

            auto b = &branch_quest_variables;

            glTranslatef(b.x, b.y, 0.0);
    
            glTranslatef(1.5, 2.5, 0.0);
            glRotatef(b.degree,0,0,1);
            glTranslatef(-1.5, -2.5, 0.0);
    
            glRotatef(-90,0,1,0);
    
            glTranslatef(0.0, 1.9, 0.0);
            glRotatef(90.0, 1.0, 0.0, 0.0);
            glTranslatef(0.0, -1.9, 0.0);
            glTranslatef(-0.9, 0.5, -0.1);
    
            glRotatef(55.0, 0.0, 1.0, 0.0);
            glRotatef(-60.0, 0.0, 0.0, 1.0);
            glScalef(0.5, 0.5, 0.5);

            recursive_render(gs, models["branch"]);
            
            glPopMatrix();
        }
        else if (dizzy_throw_branch_quest_state == 3 || dizzy_throw_branch_quest_state == 4)
        {
            glPushMatrix();
            
            auto b = &branch_quest_variables;

            float f = (dog.frame*4)%240;
            float translate = 0.0;
            
            if (f < 120.0)
                translate = 0.2 - 0.4*f/120.0;
            else if (f < 240.0)
                translate = -0.2 + 0.4*(f - 120.0)/120.0;

            glTranslatef(dog.x, dog.y + b.y + translate, dog.z);

            glTranslatef(-3.0, -0.2, 0.3);
            glRotatef(-61.5, 0.430, -0.875, 0.224);
            glScalef(0.5, 0.5, 0.5);

            recursive_render(gs, models["branch"]);

            glPopMatrix();
        }

        foreach (ref item; items)
        {
            item.draw(gs);
        }

        if (scrx == 0.0 && scry == 0.0)
        {
            glPushMatrix();
            glTranslatef(-11.8, -6.4, 3.2);
            recursive_render(gs, models["rocket"]);
            glPopMatrix();
        }

        switch(rope_state)
        {
            case 0:
                break;
            case 1:
                rope1.draw(gs);
                break;
            case 2:
                rope2.draw(gs);
                break;
            default:
                assert(0);
        }
        
        glPopMatrix();

        //Indicators
        glDisable(GL_LIGHTING);

        glScalef(0.75, 0.75, 0.75);

        glPushMatrix();
        glTranslatef(2.2, 2.0, 0.0);

        if ((the_hero.y - scry) > 4.0)
            indicators_down = true;

        if ((the_hero.y - scry) < -4.0)
            indicators_down = false;

        float iy = 21.0/aspectRatio-2.0;
        if (indicators_down)
            iy = -21.0/aspectRatio+1.0;
        
        glBindTexture(GL_TEXTURE_2D, textures["live"]);

        glBegin(GL_POLYGON);
        glTexCoord2f(0.0, 0.0);
        glVertex3f(-20.0, iy+1.0, -10.0);
        glTexCoord2f(0.0, 1.0);
        glVertex3f(-20.0, iy, -10.0);
        glTexCoord2f(the_hero.lives >=0 ? the_hero.lives : 1, 1.0);
        glVertex3f(-20.0 + (the_hero.lives >=0 ? the_hero.lives : 1), iy, -10.0);
        glTexCoord2f(the_hero.lives >=0 ? the_hero.lives : 1, 0.0);
        glVertex3f(-20.0 + (the_hero.lives >=0 ? the_hero.lives : 1), iy+1.0, -10.0);
        glEnd();

        glBindTexture(GL_TEXTURE_2D, textures["energy"]);
        glBegin(GL_POLYGON);
        glTexCoord2f(0.0, 0.0);
        glVertex3f(-16.0, iy+1.0, -10.0);
        glTexCoord2f(0.0, 1.0);
        glVertex3f(-16.0, iy, -10.0);
        glTexCoord2f(energy/100.0, 1.0);
        glVertex3f(-16.0 + 8.0*energy/100.0, iy, -10.0);
        glTexCoord2f(energy/100.0, 0.0);
        glVertex3f(-16.0 + 8.0*energy/100.0, iy+1.0, -10.0);
        glEnd();

        int scrX = cast(int) round(scrx/30);
        int scrY = cast(int) round(scry/17);

        glPushMatrix();
        glBindTexture(GL_TEXTURE_2D, textures["font"]);
        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
        glEnable(GL_COLOR_MATERIAL);
        if (the_hero.lives < 0)
        {
            glPushMatrix();
            glTranslatef(-19.0, iy+1.0, 0.0);
            glColor4f(1.0, 1.0, 0.0, 1.0);
            print_text(format("%2d", the_hero.lives));
            glPopMatrix();
        }
        glTranslatef(-7.0, iy+1.0, 0.0);
        glColor4f(1.0, 1.0, 0.0, 1.0);
        print_text(format("%02d", num_stars));
        glTranslatef(3.0, 0.0, 0.0);
        glColor4f(1.0, 1.0, 1.0, 1.0);
        string screen_name;
        if ((SC(scrX, scrY) in screen_names))
        {
            final switch(lang)
            {
                case LANG.EN:
                    screen_name = screen_names[SC(scrX, scrY)];
                    break;
                    
                case LANG.RU:
                    screen_name = screen_names_ru[SC(scrX, scrY)];
                    break;
            }
        }
        print_text(screen_name);

        /*glTranslatef(-8.0, -2.0, 0.0);
        print_text(format("FPS %.02f",
            gs.fps_frames*1000.0/gs.fps_time));*/
        
        glPopMatrix();

        draw_temp_message();

        glDisable(GL_COLOR_MATERIAL);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        
        dialogs.draw(gs);
        glPopMatrix();
    }

    void draw_temp_message()
    {
        if (frame < temp_message_frame_from ||
            frame > temp_message_frame_to) return;
            
        float f = frame - temp_message_frame_from;
        glPushMatrix();
        
        string msg;
        final switch (lang)
        {
            case LANG.EN:
                msg = temp_messages[temp_message] ~ temp_message_str;
                break;
            case LANG.RU:
                msg = temp_messages_ru[temp_message] ~ temp_message_str;
                break;
        }

        if (temp_message == TEMP_MESSAGES.PLAYS)
        {
            glScalef(0.5, 0.5, 0.5);
            glTranslatef(0.0, -10.0, 0.0);
        }

        float alpha = 1.0;
        if (f < 50) alpha = f/50.0;
        if (temp_message_frame_to - 50 > frame)
            alpha = (temp_message_frame_to-frame)/50.0;

        glColor4f(1.0, 1.0, 0.0, alpha);

        immutable (char)* second_line = msg.find("\n").ptr;
        if (second_line == null) second_line = msg.ptr + msg.length;

        glTranslatef(-0.5*msg[0..second_line - msg.ptr].walkLength(), -6.0, 0.0);

        print_text(msg);
        
        glPopMatrix();
    }

    bool paused;
    int slow = -1;
    int num_stars = 0;
    float energy = 100.0;
    bool indicators_down;
    int inv_num = -1;
    STATE state = STATE.NO_DIALOGS;    
    
    override bool tick(GlobalState gs)    
    {
        if (slow >= 0)
        {
            slow++;
            if (slow >= 10) slow = 0;
            else return true;
        }
        
        dialogs.tick(gs);

        if (the_hero.energy-0.5 > energy)
        {
            if (music_state != MUSIC_STATE.ENERGY_PLUS)
            {
                music_state = MUSIC_STATE.ENERGY_PLUS;

                if (the_hero.sounds && energy_plus)
                {   
                    if (Mix_PlayMusic(energy_plus, 1) == -1)
                    {
                        writefln("Mix_PlayMusic: %s",
                            Mix_GetError().to!(string)());
                    }

                    energy_start_tick = SDL_GetTicks() - cast(long)(1000*energy/100.0);
    
                    if(Mix_SetMusicPosition(energy/100.0) == -1) {
                        writefln("Mix_SetMusicPosition: %s\n",
                            Mix_GetError().to!(string)());
                    }
                }
            }
            
            energy += 1.0;
        }
        else if (the_hero.energy+0.5 < energy)
        {
            if (music_state != MUSIC_STATE.ENERGY_MINUS)
            {
                music_state = MUSIC_STATE.ENERGY_MINUS;

                if (the_hero.sounds && energy_minus)
                {
                    if (Mix_PlayMusic(energy_minus, 1) == -1)
                    {
                        writefln("Mix_PlayMusic: %s",
                            Mix_GetError().to!(string)());
                    }

                    energy_start_tick = SDL_GetTicks() - cast(long)(1000*(100.0-energy)/100.0);

                    if(Mix_SetMusicPosition((100.0-energy)/100.0) == -1) {
                        writefln("Mix_SetMusicPosition: %s\n",
                            Mix_GetError().to!(string)());
                    }
                }
            }
            
            energy -= 1.0;
        }
        else
        {
            if (music_state != MUSIC_STATE.MUSIC &&
                (energy != 100.0 && energy != 0.0 ||
                    (SDL_GetTicks() - energy_start_tick) > 2000))
            {
                music_state = MUSIC_STATE.MUSIC;

                if (the_hero.sounds)
                {
                    if (music)
                    {
                        if (Mix_PlayMusic(music1, -1) == -1)
                        {
                            writefln("Mix_PlayMusic: %s",
                                Mix_GetError().to!(string)());
                        }
                
                        if(Mix_SetMusicPosition((
                            (SDL_GetTicks() - music_start_tick)/1000.0)%
                            music1_len) == -1) {
                            writefln("Mix_SetMusicPosition: %s\n",
                                Mix_GetError().to!(string)());
                        }
                    }
                    else
                    {
                        Mix_HaltMusic();
                    }
                }
            }
        }

        auto b = &branch_quest_variables;

        if (dizzy_throw_branch_quest_state == 1)
        {
            if (!b.st)
            {
                b.st = 1;
                b.x = the_hero.x;
                b.y = the_hero.y;
                b.dx = (366.7 - b.x)/136;
                b.dy = 0.23;
                b.degree = 0.0;
            }

            if (b.y < -1.5 && b.dy < 0.0)
            {
                dizzy_throw_branch_quest_state++;
            }

            b.x += b.dx;
            b.y += b.dy;
            b.degree += 2.0;

            if (b.dy > -0.1)
                b.dy -= the_hero.MARS_G;
        }
        else if (dizzy_throw_branch_quest_state == 2)
        {
            if (dog.state == dog.STATE.GO_LEFT)
            {
                dizzy_throw_branch_quest_state++;
                b.st = 0;
                b.x = 0.0;
                b.y = 0.0;
                b.dy = 0.0;
            }
            
            if (b.dy > -0.1)
                b.dy -= the_hero.MARS_G;
        }
        else if (dizzy_throw_branch_quest_state == 3 &&
            (dog.state == dog.STATE.WATCH || dog.state == dog.STATE.FLY_AWAY))
        {
            dizzy_throw_branch_quest_state++;
        }
        else if (dizzy_throw_branch_quest_state == 4)
        {
            b.y += b.dy;
            if (b.dy > -0.1)
                b.dy -= the_hero.MARS_G;

            if (b.y < -2.0)
            {
                if (dizzy_cuts_rope_quest_state < 0)
                    dizzy_throw_branch_quest_state = -1;
                else
                    dizzy_throw_branch_quest_state++;

                branch.x = 358.8;
                branch.y = -5.0;
                branch.used = false;
            }
        }

        if (state == STATE.DIZZY_USED_KNIFE_ANIM)
        {
            if (dizzy_used_knife_quest_state == 0 && !the_hero.tick(gs))
            {
                dizzy_used_knife_quest_state++;
                collision_objects["solid"].remove("BranchForBreak");
                reset_collision_cache();
                the_hero.reset_anim();
                the_hero.start_fall();
            }
            else if (dizzy_used_knife_quest_state == 1)
            {
                the_hero.tick(gs);
                if (the_hero.frame >= 400)
                {
                    dizzy_used_knife_quest_state++;
                    state = STATE.NO_DIALOGS;
                    the_hero.reset_anim();
                }
            }
        }
        else if (state == STATE.DIZZY_THROW_BRANCH_ANIM)
        {
            dog.tick(gs);
            if (dizzy_throw_branch_quest_state <= 1 && !the_hero.tick(gs))
            {
                the_hero.reset_anim();
                state = STATE.NO_DIALOGS;
            }
            if (the_hero.frame == 45)
                    dizzy_throw_branch_quest_state = 1;
        }
        if (state == STATE.DIZZY_CUTS_ROPE_ANIM)
        {
            dog.tick(gs);
            if (!the_hero.tick(gs))
            {
                dog.cut_rope();
                the_hero.reset_anim();
                state = STATE.NO_DIALOGS;
            }
        }
        if (state == STATE.DIZZY_DIG_ANIM)
        {
            frame++;
            ground_garden.tick(gs);
            
            if (frame - ground_garden.frame == 100)
            {
                stone2.x = the_hero.x - 1.0;
                stone2.y = the_hero.y;
            }
            
            if (!the_hero.tick(gs))
            {
                the_hero.x = 326.5;
                the_hero.reset_anim();
                state = STATE.NO_DIALOGS;
            }
        }
        else if (state != STATE.NO_DIALOGS)
        {
            if (the_hero.energy <= 0.0)
                the_hero.tick(gs);
        }
        else if (!paused)
        {
            //degrees += 1.0;
            frame++;

            the_hero.tick(gs);

            if (the_hero.energy <= 0.0)
            {
                if (the_hero.killed_by.startsWith("Stalactite."))
                {
                    state = STATE.PIERCED_BY_STALACTITE;
                }
                else if (the_hero.killed_by.startsWith("Stalagmite."))
                {
                    state = STATE.PIERCED_BY_STALAGMITE;
                }
                else if (the_hero.killed_by == "Meteorite")
                {
                    state = STATE.HIT_BY_METEORITE;
                }
                else if (the_hero.killed_by.startsWith("Acid"))
                {
                    state = STATE.DISSOLVED_IN_ACID;
                }
                else if (the_hero.killed_by.startsWith("Lava"))
                {
                    state = STATE.BURNED_IN_LAVA;
                }
                else if (the_hero.killed_by.startsWith("Pin"))
                {
                    state = STATE.DAMAGED_BY_PIN;
                }
                else if (the_hero.killed_by.startsWith("Rock"))
                {
                    state = STATE.HIT_BY_ROCK;
                }
                else
                {
                    assert(0, format("Unknown danger object: %s", the_hero.killed_by));
                }
            }

            if (the_hero.x > martian_engineer.x - 1.5 &&
                the_hero.y > martian_engineer.y - 0.5 &&
                martian_engineer.z == 0.0)
            {
                state = STATE.MARTIAN_ENGINEER_GET_AWAY;
            }

            // Location: In the bam
            if ( 293.7 < the_hero.x && the_hero.x < 304.1 &&
                 26.3 < the_hero.y && the_hero.y < 29.2 )
            {
                the_hero.z = (the_hero.y-26.3);
            }
            else if ( the_hero.x >= 280.0 && the_hero.x < 320.0 && 26.2 < the_hero.y && the_hero.y < 29.2 )
            {
                the_hero.z = 0.0;
            }

            // Location: Two passes and umbrella
            if ( the_hero.z < 0.0 && abs(the_hero.x - 511.5) < 4.0  &&
                    abs(the_hero.y+4.6) < 2.2 )
            {
                the_hero.z = -2.6;
            }
            else if (the_hero.z < 0.0 && abs(the_hero.x - 511.5) >= 4.0 &&
                abs(the_hero.x-511.5) < 7.0 &&
                abs(the_hero.y+4.6) < 2.2)
            {
                the_hero.z = -2.6 + 2.6*(abs(the_hero.x-511.5)-4.0)/3.0;
            }
            else if (the_hero.z < 0.0 && abs(the_hero.x - 511.5) >= 7.0 &&
                abs(the_hero.x-511.5) < 8.0 &&
                abs(the_hero.y+4.6) < 2.2)
            {
                the_hero.z = 0.0;
            }

            if (abs(the_hero.x-511.5) < 2.6 &&
                -0.6 < the_hero.y && the_hero.y < 4.3)
            {
                the_hero.z = -2.6*(4.3 - the_hero.y)/4.9;
            }
            else if (abs(the_hero.x-511.5) < 3.6 &&
                -0.6 < the_hero.y && the_hero.y < 5.3)
            {
                the_hero.z = 0.0;
            }

            foreach (animation; animations)
            {
                animation.tick(gs);
            }

            bag_bug_anim.tick(gs);

            switch(rope_state)
            {
                case 0:
                    the_hero.rope = null;
                    break;
                case 1:
                    the_hero.rope = rope1;
                    rope1.tick(gs);
                    break;
                case 2:
                    the_hero.rope = rope2;
                    rope2.tick(gs);
                    break;
                default:
                    assert(0);
            }

            if ((bucket_of_water.inventory ||
                 bucket_covered.inventory) &&
                 the_hero.fall && bucket_anim.frame < 0)
            {
                foreach(i, ref item_num; inventory)
                {
                    if (items[item_num] == bucket_of_water)
                    {
                        bucket_of_water.inventory = false;
                        bucket_of_water.used = true;
                        inventory = inventory[0..i]~inventory[i+1..$];
                        break;
                    }
                }
                foreach(i, ref item_num; inventory)
                {
                    if (items[item_num] == bucket_covered)
                    {
                        bucket_covered.inventory = false;
                        bucket_covered.used = true;
                        item_num++;
                        break;
                    }
                }
                bucket_anim.start_anim([the_hero.x, the_hero.y, the_hero.z]);
            }

            if (bucket_anim.frame >= 0 &&
                frame - bucket_anim.frame >= 200)
            {
                bucket_anim.frame = -1;
                bucket.used = false;
                bucket.inventory = false;
                bucket.x = the_hero.x - 2.0;
                bucket.y = the_hero.y;
                bucket.z = the_hero.z;
            }

            float oldscrx = scrx;

            while (the_hero.x-scrx > 15.0)
            {
                scrx += 30.0;
            }
            
            while (the_hero.x-scrx < -15.0)
            {
                scrx -= 30.0;
            }

            while (the_hero.y-scry > 8.5)
            {
                scry += 17.0;
            }

            while (the_hero.y-scry < -8.5)
            {
                scry -= 17.0;
            }

            if (abs(scrx - 360.0) < 1.0 && abs(scry + 17.0) < 1.0 ||
                scrx > 389.0 && scrx < 451.0 && abs(scry + 34.0) < 1.0 ||
                abs(scrx - 480.0) < 1.0 && abs(scry + 17.0) < 1.0)
            {
                scry += 17.0;
            }

            if ( abs(scrx - 330.0) < 1.0 && abs(scry + 17.0) < 1.0 )
            {
                the_hero.force_dx = -0.15;
                the_hero.dy = the_hero.JUMP_V;
                state = state.TO_BE_CONTINUED_MESSAGE;
                scry += 17.0;
            }

            if (explosure.frame >= 0 && abs(scrx - 420.0) < 1.0 &&
                abs(scry - 0.0) < 1.0)
            {
                dizzy_live_after_explosure_quest_state = 1;
            }

            if (wait_meteorite < 0 && "Martian_Agronomist_Gives_Bucket" in done_dialogs &&
                oldscrx < 149 && scrx > 149)
            {
                wait_meteorite = 0;
            }

            if (bucket_of_water.inventory && abs(scrx - 360.0) < 1.0 &&
                abs(scry - 0.0) < 1.0)
            {
                foreach(i, ref item_num; inventory)
                {
                    if (items[item_num] == bucket_of_water)
                    {
                        bucket_of_water.inventory = false;
                        bucket_of_water.used = true;
                        bucket_of_ice.inventory = true;
                        bucket_of_ice.used = false;
                        item_num++;
                        break;
                    }
                }
            }
        }
        
        return true;
    }

    void print_message(TEMP_MESSAGES msg, string str = null)
    {
        temp_message = msg;
        temp_message_str = str;
        temp_message_frame_from = frame;
        temp_message_frame_to = frame+200;
    }

    void pause(GlobalState gs)
    {
        paused = !paused;
    }

    void
    process_event(GlobalState gs, SDL_Event event)
    {
        
    }

    void
    quit(GlobalState gs)
    {
        gs.stopGame();
    }

    void
    start_left(GlobalState gs)
    {
        if (!(keys & LEFT_KEY))
        {
            keys |= LEFT_KEY;
            the_hero.start_left(gs);
        }
    }

    void stop_left(GlobalState gs)
    {
        if (keys & LEFT_KEY)
        {
            keys &= ~LEFT_KEY;
            the_hero.stop_left(gs);
        }
    }

    void
    start_right(GlobalState gs)
    {
        if (!(keys & RIGHT_KEY))
        {
            keys |= RIGHT_KEY;
            the_hero.start_right(gs);
        }
    }

    void stop_right(GlobalState gs)
    {
        if (keys & RIGHT_KEY)
        {
            keys &= ~RIGHT_KEY;
            the_hero.stop_right(gs);
        }
    }

    void start_jump(GlobalState gs)
    {
        if (state == STATE.INVENTORY)
        {
            inv_num--;
            if (inv_num < -1) inv_num = cast(int)(inventory.length-1);
        }
        
        keys |= UP_KEY;
    }

    void stop_jump(GlobalState gs)
    {
        keys &= ~UP_KEY;
    }

    void down(GlobalState gs)
    {
        if (state == STATE.INVENTORY)
        {
            inv_num++;
            if (inv_num >= inventory.length) inv_num = -1;
        }
        keys |= DOWN_KEY;
    }

    void stop_down(GlobalState gs)
    {
        keys &= ~DOWN_KEY;
    }

    void change_language(GlobalState gs)
    {
        lang++;
        if (lang > LANG.MAX) lang = LANG.EN;
    }

    void print_coords(GlobalState gs)
    {
        writefln("x=%s, y=%s, z=%s", the_hero.x, the_hero.y, the_hero.z);
    }

    void switch_slow(GlobalState gs)
    {
        if (keys & CTRL_KEY) return save(gs);
        /*if (slow >= 0) slow = -1;
        else slow = 0;*/
    }

    void switch_sensors(GlobalState gs)
    {
        the_hero.show_sensors = !the_hero.show_sensors;
    }

    void ctrl_down(GlobalState gs)
    {
        keys |= CTRL_KEY;
    }

    void ctrl_up(GlobalState gs)
    {
        keys &= ~CTRL_KEY;
    }

    void shift_down(GlobalState gs)
    {
        keys |= SHIFT_KEY;
    }

    void shift_up(GlobalState gs)
    {
        keys &= ~SHIFT_KEY;
    }

    void action(GlobalState gs)
    {
        switch_label:
        final switch(state)
        {
            case STATE.NO_DIALOGS:

                foreach(i, star; stars)
                {
                    if (star.maybe_taken(gs, the_hero))
                    {
                        state = STATE.ENERGY_STAR;
                        num_stars++;
                        the_hero.energy += 25.0;
                        if (the_hero.energy > 100.0)
                        {
                            the_hero.energy = 100.0;
                            if (energy == 100.0) energy = 99.0;
                        }
                        star.take();
                        break switch_label;
                    }
                }

                foreach(i, ref item; items)
                {
                    if (item.maybe_taken(gs, the_hero))
                    {
                        if (inventory.length >= 3)
                        {
                            state = STATE.TOO_MANY_ITEMS;
                            break switch_label;
                        }
                        
                        inventory ~= i;
                        item.inventory = true;

                        state = STATE.INVENTORY;
                        inv_num = -1;
                        break switch_label;
                    }
                }

                // Location: Martian-Agronomist
                if (abs(the_hero.x-282.25) < 2.6 && abs(the_hero.y-0.95) < 0.5 && !the_hero.jump)
                {
                    if ("Martian_Agronomist_Hello" !in done_dialogs)
                    {
                        done_dialogs["Martian_Agronomist_Hello"] = true;
                        state = STATE.MARTIAN_AGRONOMIST_HELLO;
                        break switch_label;
                    }

                    if (dizzy_throw_branch_quest_state >= 5 &&
                        "Martian_Agronomist_Rope" !in done_dialogs)
                    {
                        done_dialogs["Martian_Agronomist_Rope"] = true;
                        state = STATE.MARTIAN_AGRONOMIST_ROPE;
                        break switch_label;
                    }

                    if ("Martian_Chemist_Hello" in done_dialogs &&
                        "Martian_Agronomist_Gives_Bucket" !in done_dialogs)
                    {
                        done_dialogs["Martian_Agronomist_Gives_Bucket"] = true;
                        state = STATE.MARTIAN_AGRONOMIST_GIVES_BUCKET;
                        break switch_label;
                    }

                    if (dizzy_water_flowers_state == 1 &&
                        "Martian_Agronomist_Thanks" !in done_dialogs)
                    {
                        done_dialogs["Martian_Agronomist_Thanks"] = true;
                        state = STATE.MARTIAN_AGRONOMIST_THANKS;
                        break switch_label;
                    }
                }

                // Location: Martian-Engineer
                if (abs(the_hero.x-402.0) < 2.6 && abs(the_hero.y-2.7) < 0.5 && !the_hero.jump)
                {
                    if ("Martian_Agronomist_Thanks" in done_dialogs &&
                        "Martian_Engineer_Returns_Player" !in done_dialogs)
                    {
                        done_dialogs["Martian_Engineer_Returns_Player"] = true;
                        state = STATE.MARTIAN_ENGINEER_RETURNS_PLAYER;
                        break switch_label;
                    }

                    if ((light_branch.inventory ||
                        light_branch.def_x != light_branch.x &&
                        light_branch.def_y != light_branch.y) &&
                        "Martian_Engineer_Gives_Spade" !in done_dialogs)
                    {
                        done_dialogs["Martian_Engineer_Gives_Spade"] = true;
                        state = STATE.MARTIAN_ENGINEER_GIVES_SPADE;
                        break switch_label;
                    }
                }

                // Location: Door of bam (Outdoor)
                if (abs(the_hero.x-311.5) < 1.5 && abs(the_hero.y+0.1) < 0.5 && !the_hero.jump)
                {
                    the_hero.x = 304.7;
                    the_hero.y = 26.2;
                    bag_bug_anim.start();
                    break switch_label;
                }

                // Location: Door of bam (Indoor)
                if (abs(the_hero.x-304.7) < 1.5 && abs(the_hero.y-26.2) < 0.5 && !the_hero.jump)
                {
                    the_hero.x = 311.5;
                    the_hero.y = -0.1;
                    break switch_label;
                }

                // Location: Booth (Outdoor)
                if (abs(the_hero.x-308.7) < 1.5 && abs(the_hero.y+6.2) < 0.5 && !the_hero.jump)
                {
                    state = STATE.LOOKING_BOOTH_MESSAGE;
                    break switch_label;
                }

                // Location : near branch under tree
                if (dizzy_used_knife_quest_state == 2 && 
                    abs(the_hero.x-327.0) < 1.5 && abs(the_hero.y+6.0) < 0.5 && !the_hero.jump)
                {                                                        
                    if (inventory.length >= 3)
                    {
                        state = STATE.TOO_MANY_ITEMS;
                        break switch_label;
                    }
                    
                    foreach(i, ref item; items)
                    {
                        if (item.model == "branch")
                        {
                            dizzy_used_knife_quest_state++;
                            
                            inventory ~= i;
                            item.inventory = true;
                            break;
                        }
                    }
                }

                // Location : Danger sign in the muzzle of volcano
                if (rope_state == 1 &&
                    abs(the_hero.x-418.1) < 1.5 &&
                    abs(the_hero.y-1.0) < 0.5 && !the_hero.jump)
                {
                    foreach(i, ref item; items)
                    {
                        if (item.model == "rope")
                        {
                            if (inventory.length >= 3)
                            {
                                state = STATE.TOO_MANY_ITEMS;
                                break switch_label;
                            }
                            
                            state = STATE.DIZZY_UNTIED_ROPE_MESSAGE;
                            inventory ~= i;
                            item.inventory = true;
                            item.used = false;
                    
                            break switch_label;
                        }
                    }
                }

                // Location : Danger sign before Martian-Agronomist
                if (rope_state == 2 &&
                    abs(the_hero.x-245.0) < 1.5 &&
                    abs(the_hero.y-2.0) < 0.5 && !the_hero.jump)
                {
                    foreach(i, ref item; items)
                    {
                        if (item.model == "rope")
                        {
                            if (inventory.length >= 3)
                            {
                                state = STATE.TOO_MANY_ITEMS;
                                break switch_label;
                            }
                            
                            state = STATE.DIZZY_UNTIED_ROPE_MESSAGE;
                            inventory ~= i;
                            item.inventory = true;
                            item.used = false;
                    
                            break switch_label;
                        }
                    }
                }

                // Location : Near tree with the dog, rope
                if (dizzy_cuts_rope_quest_state >= 0 &&
                    dizzy_throw_branch_quest_state >= 5 &&
                    dog.hidden == 1 &&
                    short_rope.x == short_rope.def_x &&
                    short_rope.y == short_rope.def_y &&
                    abs(the_hero.x-359.2) < 1.5 && abs(the_hero.y+5.0) < 0.5 && !the_hero.jump)
                {
                    foreach(i, ref item; items)
                    {
                        if (item.model == "short-rope")
                        {
                            if (inventory.length >= 3)
                            {
                                state = STATE.TOO_MANY_ITEMS;
                                break switch_label;
                            }
                            
                            state = STATE.DIZZY_UNTIED_ROPE_MESSAGE;
                            inventory ~= i;
                            item.inventory = true;
                            item.used = false;
                            dog.hide();
                    
                            break switch_label;
                        }
                    }
                }


                // Location: Martian-Chemist
                if (abs(the_hero.x-463.2) < 2.6 && abs(the_hero.y-1.7) < 0.5 && !the_hero.jump)
                {
                    if ("Martian_Chemist_Hello" !in done_dialogs)
                    {
                        done_dialogs["Martian_Chemist_Hello"] = true;
                        state = STATE.MARTIAN_CHEMIST_HELLO;
                        break switch_label;
                    }
                }

                state = STATE.INVENTORY;
                inv_num = -1;
                break;
            case STATE.INVENTORY:
                if (inv_num >= 0)
                {
                    // Location : On Tree
                    if (items[inventory[inv_num]].model == "kitchen-knife" && 
                        abs(the_hero.x-327.0) < 1.5 && abs(the_hero.y-2.3) < 0.5 && !the_hero.jump)
                    {
                        state = STATE.DIZZY_USED_KNIFE_MESSAGE;
                        dizzy_used_knife_quest_state = 0;
                        the_hero.use_knife();
                        break switch_label;
                    }

                    // Location : Near tree with the dog
                    if (items[inventory[inv_num]].model == "branch" && 
                        dizzy_throw_branch_quest_state == -1 &&
                        abs(the_hero.x-354.1) < 3 && abs(the_hero.y+5.0) < 0.5 && !the_hero.jump)
                    {
                        state = STATE.DIZZY_THROW_BRANCH_MESSAGE;
                        dizzy_throw_branch_quest_state = 0;
                        the_hero.throw_branch();
                        
                        inventory = inventory[0..inv_num] ~ inventory[inv_num+1..$];
                        branch.inventory = false;
                        branch.used = true;
                        
                        break switch_label;
                    }

                    // Location : Near tree with the dog, rope
                    if (items[inventory[inv_num]].model == "kitchen-knife" &&
                        dizzy_cuts_rope_quest_state == -1 &&
                        abs(the_hero.x-359.2) < 1.5 && abs(the_hero.y+5.0) < 0.5 && !the_hero.jump)
                    {
                        state = STATE.DIZZY_CUTS_ROPE_MESSAGE;
                        dizzy_cuts_rope_quest_state = 0;
                        the_hero.cut_rope();               
                        break switch_label;
                    }

                    // Location : Martian-Engineer
                    if (items[inventory[inv_num]].model == "player" &&
                        "Martian_Engineer_Takes_Player" !in done_dialogs &&
                        abs(the_hero.x-martian_engineer.x) < 4.0 &&
                        abs(the_hero.y-martian_engineer.y) < 0.5 && !the_hero.jump)
                    {
                        done_dialogs["Martian_Engineer_Takes_Player"] = true;
                        state = STATE.MARTIAN_ENGINEER_TAKES_PLAYER;
                        inventory = inventory[0..inv_num] ~ inventory[inv_num+1..$];
                        player.inventory = false;
                        player.used = true;
                        
                        break switch_label;
                    }
                    if (items[inventory[inv_num]].model == "bucket-of-ice" &&
                        "Martian_Engineer_Returns_Player" in done_dialogs &&
                        abs(the_hero.x-402.0) < 2.6 && abs(the_hero.y-2.7) < 0.5 && !the_hero.jump)
                    {
                        done_dialogs["Martian_Engineer_Takes_Bucket"] = true;
                        state = STATE.MARTIAN_ENGINEER_TAKES_BUCKET;
                        inventory[inv_num] -= 2;
                        bucket_of_ice.inventory = false;
                        bucket_of_ice.used = true;
                        bucket.inventory = true;
                        bucket.used = false;
                        
                        break switch_label;
                    }

                    // Location : Danger sign in the muzzle of volcano
                    if (items[inventory[inv_num]].model == "rope" &&
                        abs(the_hero.x-418.1) < 1.5 &&
                        abs(the_hero.y-1.0) < 0.5 && !the_hero.jump)
                    {
                        state = STATE.DIZZY_TIED_ROPE_MESSAGE;
                        inventory = inventory[0..inv_num] ~ inventory[inv_num+1..$];
                        rope.inventory = false;
                        rope.used = true;
                        
                        break switch_label;
                    }

                    // Location : Danger sign before Martian-Agronomist
                    if (items[inventory[inv_num]].model == "rope" &&
                        abs(the_hero.x-245.0) < 1.5 &&
                        abs(the_hero.y-2.0) < 0.5 && !the_hero.jump)
                    {
                        state = STATE.DIZZY_TIED_ROPE_MESSAGE;
                        inventory = inventory[0..inv_num] ~ inventory[inv_num+1..$];
                        rope.inventory = false;
                        rope.used = true;
                        
                        break switch_label;
                    }

                    if (items[inventory[inv_num]].model == "stunning-drink")
                    {
                        state = STATE.DIZZY_DRINK_STUNNING_MESSAGE;
                        break switch_label;
                    }

                    // Location : Well
                    if ((items[inventory[inv_num]].model == "bucket" ||
                         items[inventory[inv_num]].model == "bucket-of-ice") &&
                        rope.inventory &&
                        abs(the_hero.x-118.8) < 1.5 &&
                        abs(the_hero.y+4.1) < 0.5 && !the_hero.jump)
                    {
                        if (dizzy_water_flowers_state < 0)
                        {
                            state = STATE.DIZZY_TRIES_FILL_BUCKET_MESSAGE;
                        }
                        else
                        {
                            state = STATE.DIZZY_FILL_BUCKET_MESSAGE;
                        }
                        break switch_label;
                    }
                    if (items[inventory[inv_num]].model == "meteorite" &&
                        abs(the_hero.x-118.8) < 1.5 &&
                        abs(the_hero.y+4.1) < 0.5 && !the_hero.jump)
                    {
                        state = STATE.DIZZY_THROW_METEORITE_MESSAGE;
                        inventory = inventory[0..inv_num] ~ inventory[inv_num+1..$];
                        meteorite.inventory = false;
                        meteorite.used = true;
                        dizzy_water_flowers_state = 0;
                        break switch_label;
                    }

                    // Location : Garden of agronomist
                    if (dizzy_water_flowers_state < 1 &&
                        items[inventory[inv_num]].model == "bucket-of-water" &&
                        abs(the_hero.x-276.0) < 3.0 &&
                        abs(the_hero.y+8.1) < 0.5 && !the_hero.jump)
                    {
                        state = STATE.DIZZY_TRIES_WATER_FLOWERS_MESSAGE;
                        break switch_label;
                    }
                    if (dizzy_water_flowers_state < 1 &&
                        items[inventory[inv_num]].model == "bucket-covered" &&
                        abs(the_hero.x-276.0) < 3.0 &&
                        abs(the_hero.y+8.1) < 0.5 && !the_hero.jump)
                    {
                        state = STATE.DIZZY_WATER_FLOWERS_MESSAGE;
                        bucket_covered.inventory = false;
                        bucket_covered.used = true;
                        blanket.inventory = true;
                        blanket.used = false;
                        inventory[inv_num]++;
                        dizzy_water_flowers_state = 1;
                        the_hero.water_with_bucket_of_water();
                        break switch_label;
                    }

                    // Location : Garden under tree
                    if (ground_garden.frame < 0 &&
                        items[inventory[inv_num]].model == "spade" &&
                        abs(the_hero.x-326.1) < 3.0 &&
                        abs(the_hero.y+6.0) < 0.5 && !the_hero.jump)
                    {
                        ground_garden.frame = root.frame;
                        state = STATE.DIZZY_DIG_MESSAGE;
                        the_hero.dig();
                        break switch_label;
                    }

                    if (dizzy_water_flowers_state < 1 &&
                        items[inventory[inv_num]].model == "blanket" &&
                        bucket_of_water.inventory)
                    {
                        state = STATE.DIZZY_COVERED_BUCKET_MESSAGE;
                        break switch_label;
                    }

                    if (items[inventory[inv_num]].model == "branch" &&
                        "Martian_Engineer_Takes_Bucket" in done_dialogs &&
                        abs(the_hero.x-12.3) < 1.5 &&
                        abs(the_hero.y+7.3) < 0.5 && !the_hero.jump)
                    {
                        state = STATE.DIZZY_HOLD_BRANCH_UNDER_DROP;
                        branch.inventory = false;
                        branch.used = true;
                        light_branch.inventory = true;
                        light_branch.used = false;
                        inventory[inv_num]++;
                        break switch_label;
                    }
                    
                    items[inventory[inv_num]].inventory = false;
                    items[inventory[inv_num]].x = the_hero.x;
                    items[inventory[inv_num]].y = the_hero.y;
                    items[inventory[inv_num]].z = the_hero.z;
                    inventory = inventory[0..inv_num]~ inventory[inv_num+1..$];
                }
                state = STATE.NO_DIALOGS;
                break;
            case STATE.ENERGY_STAR:
            case STATE.TOO_MANY_ITEMS:
            case STATE.MARTIAN_AGRONOMIST_HELLO6:
            case STATE.DIZZY_TRIES_FILL_BUCKET_MESSAGE:
            case STATE.DIZZY_THROW_METEORITE_MESSAGE:
            case STATE.MARTIAN_AGRONOMIST_THANKS:
            case STATE.MARTIAN_ENGINEER_TAKES_BUCKET1:
            case STATE.DIZZY_HOLD_BRANCH_UNDER_DROP:
            case STATE.TO_BE_CONTINUED_MESSAGE:
                state = STATE.NO_DIALOGS;
                break;
            case STATE.PIERCED_BY_STALAGMITE:
            case STATE.PIERCED_BY_STALACTITE:
            case STATE.HIT_BY_METEORITE:
            case STATE.DISSOLVED_IN_ACID:
            case STATE.BURNED_IN_LAVA:
            case STATE.DAMAGED_BY_PIN:
            case STATE.HIT_BY_ROCK:
                if ( abs(scrx-420.0) < 1.0 &&
                     (abs(scry+17.0) < 1.0 || abs(scry-0.0) < 1.0) )
                {
                    if (dizzy_live_after_explosure_quest_state < 0)
                    {
                        if (baloon.inventory)
                        {
                            foreach(i, item_num; inventory)
                            {
                                if (items[item_num] == baloon)
                                {
                                    inventory = inventory[0..i] ~ inventory[i+1..$];
                                    break;
                                }
                            }
                        }
                        
                        baloon.load(null);
                        explosure.load(null);
                    }
                    the_hero.last_safe = [418.1, 1.0, 0.0];
                }
                the_hero.rise();
                state = STATE.NO_DIALOGS;
                break;
            case STATE.MARTIAN_AGRONOMIST_HELLO:
            case STATE.MARTIAN_AGRONOMIST_HELLO1:
            case STATE.MARTIAN_AGRONOMIST_HELLO2:
            case STATE.MARTIAN_AGRONOMIST_HELLO3:
            case STATE.MARTIAN_AGRONOMIST_HELLO4:
            case STATE.MARTIAN_AGRONOMIST_HELLO5:
            case STATE.MARTIAN_CHEMIST_HELLO:
            case STATE.MARTIAN_CHEMIST_HELLO1:
            case STATE.MARTIAN_CHEMIST_HELLO2:
            case STATE.MARTIAN_CHEMIST_HELLO3:
            case STATE.MARTIAN_CHEMIST_HELLO4:
            case STATE.DIZZY_USED_KNIFE_MESSAGE:
            case STATE.DIZZY_THROW_BRANCH_MESSAGE:
            case STATE.DIZZY_CUTS_ROPE_MESSAGE:
            case STATE.MARTIAN_AGRONOMIST_GIVES_BUCKET:
            case STATE.MARTIAN_ENGINEER_RETURNS_PLAYER:
            case STATE.MARTIAN_ENGINEER_RETURNS_PLAYER1:
            case STATE.MARTIAN_ENGINEER_TAKES_BUCKET:
            case STATE.DIZZY_DIG_MESSAGE:
                state++;
                break;
            case STATE.LOOKING_BOOTH_MESSAGE:
                state = STATE.LOOKING_BOOTH;
                scry += 68.0;
                break;
            case STATE.LOOKING_BOOTH:
                scry -= 68.0;
                state = STATE.NO_DIALOGS;
                break;
            case STATE.DIZZY_USED_KNIFE_ANIM:
                dizzy_used_knife_quest_state = 2;
                the_hero.y = -6.0;
                the_hero.reset_anim();
                collision_objects["solid"].remove("BranchForBreak");
                state = STATE.NO_DIALOGS;
                break;
            case STATE.DIZZY_THROW_BRANCH_ANIM:
            case STATE.DIZZY_CUTS_ROPE_ANIM:
            case STATE.DIZZY_DIG_ANIM:
            case STATE.HELP:
                break;
            case STATE.MARTIAN_ENGINEER_GET_AWAY:
                if (player.x == player.def_x &&
                    player.y == player.def_y)
                {
                    player.x = 118.0;
                    player.y = 0.4;
                }
                the_hero.force_dx = -0.15;
                the_hero.dy = the_hero.JUMP_V;
                state = STATE.NO_DIALOGS;
                break;
            case STATE.MARTIAN_AGRONOMIST_ROPE:
                rope.x = 280.9;
                rope.y = 0.8;
                state = STATE.NO_DIALOGS;
                break;
            case STATE.MARTIAN_AGRONOMIST_GIVES_BUCKET1:
                bucket.x = 280.9;
                bucket.y = 0.8;
                state = STATE.NO_DIALOGS;
                break;
            case STATE.MARTIAN_ENGINEER_TAKES_PLAYER:
                martian_engineer.degrees = 0;
                martian_engineer.z = 2.0;
                state = STATE.NO_DIALOGS;
                break;
            case STATE.DIZZY_TIED_ROPE_MESSAGE:
                if (abs(scrx - 420.0) < 1.0 &&
                    abs(scry - 0.0) < 1.0)
                {
                    rope_state = 1;
                    rope1.reinit();
                }

                if (abs(scrx - 240.0) < 1.0 &&
                    abs(scry - 0.0) < 1.0)
                {
                    rope_state = 2;
                    rope2.reinit();
                }
                state = STATE.NO_DIALOGS;
                break;

            case STATE.DIZZY_UNTIED_ROPE_MESSAGE:
                rope_state = 0;
                state = STATE.NO_DIALOGS;
                break;

            case STATE.MARTIAN_CHEMIST_HELLO5:
                stunning_drink.x = 462.0;
                stunning_drink.y = 1.7;
                stunning_drink.z = 0.0;
                state = STATE.NO_DIALOGS;
                break;

            case STATE.DIZZY_DRINK_STUNNING_MESSAGE:
                foreach(i, ref item_num; inventory)
                {
                    if (items[item_num] == stunning_drink)
                    {
                        stunning_drink.used = true;
                        bottle.inventory = true;
                        item_num++;
                        break;
                    }
                }
                the_hero.stunning = 10*6000;
                state = STATE.NO_DIALOGS;
                break;

            case STATE.DIZZY_FILL_BUCKET_MESSAGE:
                foreach(i, ref item_num; inventory)
                {
                    if (items[item_num] == bucket)
                    {
                        bucket.inventory = false;
                        bucket.used = true;
                        bucket_of_water.used = false;
                        bucket_of_water.inventory = true;
                        item_num++;
                        break;
                    }
                    if (items[item_num] == bucket_of_ice)
                    {
                        bucket_of_ice.inventory = false;
                        bucket_of_ice.used = true;
                        bucket_of_water.used = false;
                        bucket_of_water.inventory = true;
                        item_num--;
                        break;
                    }
                }
                state = STATE.NO_DIALOGS;
                break;

            case STATE.DIZZY_TRIES_WATER_FLOWERS_MESSAGE:
                foreach(i, ref item_num; inventory)
                {
                    if (items[item_num] == bucket_of_water)
                    {
                        bucket_of_water.inventory = false;
                        bucket_of_water.used = true;
                        bucket_of_ice.inventory = true;
                        bucket_of_ice.used = false;
                        item_num++;
                        break;
                    }
                }
                state = STATE.NO_DIALOGS;
                break;

            case STATE.DIZZY_COVERED_BUCKET_MESSAGE:
                foreach(i, ref item_num; inventory)
                {
                    if (items[item_num] == bucket_of_water)
                    {
                        bucket_of_water.inventory = false;
                        bucket_of_water.used = true;
                        bucket_covered.inventory = true;
                        bucket_covered.used = false;
                        item_num += 2;
                        break;
                    }
                }
                
                foreach(i, ref item_num; inventory)
                {   
                    if (items[item_num] == blanket)
                    {
                        blanket.inventory = false;
                        blanket.used = true;
                        inventory = inventory[0..i] ~ inventory[i+1..$];
                        break;
                    }
                }
                
                state = STATE.NO_DIALOGS;
                break;

            case STATE.DIZZY_WATER_FLOWERS_MESSAGE:
                bucket.used = false;
                bucket.x = the_hero.x;
                bucket.y = the_hero.y;
                bucket.z = the_hero.z;

                the_hero.reset_anim();
                state = STATE.NO_DIALOGS;
                break;

            case STATE.MARTIAN_ENGINEER_RETURNS_PLAYER2:
                player.used = false;
                player.x = the_hero.x - 2.0;
                player.y = the_hero.y;
                player.z = the_hero.z;
                
                state = STATE.NO_DIALOGS;
                break;

            case STATE.MARTIAN_ENGINEER_GIVES_SPADE:
                spade.used = false;
                spade.x = the_hero.x - 2.0;
                spade.y = the_hero.y;
                spade.z = the_hero.z;
                
                state = STATE.NO_DIALOGS;
                break;
        }
    }

    void load(string[string] s)
    {
        if ("frame" in s)
            frame = s["frame"].to!(long);
        else
            frame = 0;

        temp_message_frame_from = 0;
        temp_message_frame_to = 0;

        if ("lang" in s)
            lang = s["lang"].to!(LANG);
        else
            lang = LANG.EN;
        
        num_stars = 0;
        foreach(star; stars)
        {
            star.load(s);
            if (star.taken)
                num_stars++;
        }

        inventory = [];
        foreach(i, item; items)
        {
            item.load(s);
            if (item.inventory)
                inventory ~= i;
        }

        foreach(animation; animations)
            animation.load(s);

        the_hero.load(s);
        bag_bug_anim.load(s);
        
        done_dialogs = null;
        foreach(d; ["Martian_Agronomist_Hello",
                    "Martian_Agronomist_Rope",
                    "Martian_Engineer_Takes_Player",
                    "Martian_Chemist_Hello",
                    "Martian_Agronomist_Gives_Bucket",
                    "Martian_Agronomist_Thanks",
                    "Martian_Engineer_Returns_Player",
                    "Martian_Engineer_Takes_Bucket",
                    "Martian_Engineer_Gives_Spade"])
        {
            if ("dialog"~d in s)
            {
                done_dialogs[d] = true;
            }
        }

        if ("dizzy_used_knife" in s)
        {
            dizzy_used_knife_quest_state = s["dizzy_used_knife"].to!(int);
            collision_objects["solid"]["BranchForBreak"] = null;
            collision_objects["solid"].remove("BranchForBreak");
            reset_collision_cache();
        }
        else
        {
            dizzy_used_knife_quest_state = -1;
            collision_objects["solid"]["BranchForBreak"] = collision_objects["temp-solid"]["BranchForBreak"];
            reset_collision_cache();
        }

        if ("dizzy_cuts_rope" in s)
        {
            dizzy_cuts_rope_quest_state = 0;
            dizzy_throw_branch_quest_state = 5;
        }
        else
        {
            dizzy_cuts_rope_quest_state = -1;
            dizzy_throw_branch_quest_state = -1;
        }

        if ("dizzy_live_after_explosure" in s)
        {
            dizzy_live_after_explosure_quest_state = 0;
        }
        else
            dizzy_live_after_explosure_quest_state = -1;

        if ("rope_state" in s)
            rope_state = s["rope_state"].to!(int);
        else rope_state = 0;

        if ("dizzy_fields_garden" in s)
            dizzy_water_flowers_state = s["dizzy_fields_garden"].to!(int);
        else if ("dizzy_water_flowers" in s)
            dizzy_water_flowers_state = s["dizzy_water_flowers"].to!(int);
        else dizzy_water_flowers_state = -1;

        if (meteorite.x != meteorite.def_x ||
            meteorite.y != meteorite.def_y)
            wait_meteorite = 2;
        else
            wait_meteorite = -1;
    }

    void save(ref string[string] s)
    {
        foreach(star; stars)
            star.save(s);

        foreach(item; items)
            item.save(s);

        foreach(animation; animations)
            animation.save(s);

        the_hero.save(s);
        bag_bug_anim.save(s);
        
        foreach(d; ["Martian_Agronomist_Hello",
                    "Martian_Agronomist_Rope",
                    "Martian_Engineer_Takes_Player",
                    "Martian_Chemist_Hello",
                    "Martian_Agronomist_Gives_Bucket",
                    "Martian_Agronomist_Thanks",
                    "Martian_Engineer_Returns_Player",
                    "Martian_Engineer_Takes_Bucket",
                    "Martian_Engineer_Gives_Spade"])
        {
            if (d in done_dialogs)
            {
                s["dialog"~d] = "done";
            }
        }

        if (dizzy_used_knife_quest_state >= 2)
            s["dizzy_used_knife"] = dizzy_used_knife_quest_state.to!(string);

        if (dizzy_cuts_rope_quest_state >= 0 &&
            dizzy_throw_branch_quest_state >= 5)
            s["dizzy_cuts_rope"] = "Done";

        if (dizzy_live_after_explosure_quest_state >= 0)
            s["dizzy_live_after_explosure"] = "Done";

        if (rope_state != 0)
            s["rope_state"] = rope_state.to!(string);

        if (dizzy_water_flowers_state >= 0)
            s["dizzy_water_flowers"] = dizzy_water_flowers_state.to!(string);

        s["frame"] = frame.to!(string);
        s["lang"] = lang.to!(string);
    }

    void restart(GlobalState gs)
    {   
        if (!(keys & CTRL_KEY)) return;

        load(cast(string[string]) null);
    }

    void load(GlobalState gs)
    {
        if (!(keys & CTRL_KEY)) return;
        if (state != STATE.NO_DIALOGS) return;
        
        auto s = .load();
        load(s);
    }

    void save(GlobalState gs)
    {        
        if (keys & (LEFT_KEY | RIGHT_KEY))
        {
            print_message(TEMP_MESSAGES.CANT_SAVE_IN_THE_MOVING);
            return;
        }
        
        if (dizzy_throw_branch_quest_state >= 0 && dizzy_cuts_rope_quest_state < 0 ||
            dizzy_throw_branch_quest_state < 5 && dizzy_cuts_rope_quest_state >= 0)
        {
            print_message(TEMP_MESSAGES.CANT_SAVE_DURING_THE_QUEST);
            return;
        }

        if (the_hero.lives < 0)
        {
            print_message(TEMP_MESSAGES.NEGATIVE_LIVES);
            return;
        }

        if (state != STATE.NO_DIALOGS) return;
        
        string[string] s;
        save(s);
        .save(s);

        print_message(TEMP_MESSAGES.SAVED);
    }

    void help(GlobalState gs)
    {
        if (state == STATE.HELP) state = STATE.NO_DIALOGS;
        else if (state == STATE.NO_DIALOGS) state = STATE.HELP;
    }

    void turn_music(GlobalState gs)
    {
        music = !music;
        if (music)
        {
            if (Mix_PlayMusic(music1, -1) == -1)
            {
                writefln("Mix_PlayMusic: %s",
                    Mix_GetError().to!(string)());
            }
    
            if(Mix_SetMusicPosition((
                (SDL_GetTicks() - music_start_tick)/1000.0)%
                music1_len) == -1) {
                writefln("Mix_SetMusicPosition: %s\n",
                    Mix_GetError().to!(string)());
            }
        }
        else
        {
            Mix_HaltMusic();
        }
    }

    void turn_sounds(GlobalState gs)
    {
        the_hero.sounds = !the_hero.sounds;

        if (!the_hero.sounds)
        {
            Mix_HaltChannel(-1);
        }
    }

    void
    setup_keybar(GlobalState gs)
    {
        gs.keybar.handlers.clear();
        gs.keybar.handlers_down.clear();
        gs.keybar.handlers_double.clear();
        
        gs.keybar.handlers_down[SDL_SCANCODE_Q] = KeyHandler(&quit, ("Quit"), "exit.png");
        gs.keybar.handlers_down[SDL_SCANCODE_PRINTSCREEN] = KeyHandler(toDelegate(&make_screenshot), ("Make screenshot"), "Prt Sc");
        gs.keybar.handlers_down[SDL_SCANCODE_P] = KeyHandler(toDelegate(&pause), ("Pause"), "Pause");

        gs.keybar.handlers_down[SDL_SCANCODE_LEFT] = KeyHandler(&start_left, ("Left"), "Left");
        gs.keybar.handlers[SDL_SCANCODE_LEFT] = KeyHandler(&stop_left, ("Left"), "Left");
        gs.keybar.handlers_down[SDL_SCANCODE_RIGHT] = KeyHandler(&start_right, ("Right"), "Right");
        gs.keybar.handlers[SDL_SCANCODE_RIGHT] = KeyHandler(&stop_right, ("Right"), "Right");
        gs.keybar.handlers_down[SDL_SCANCODE_UP] = KeyHandler(&start_jump, ("Jump"), "Jump");
        gs.keybar.handlers[SDL_SCANCODE_UP] = KeyHandler(&stop_jump, ("Jump"), "Jump");
        gs.keybar.handlers_down[SDL_SCANCODE_DOWN] = KeyHandler(&down, ("Down"), "Down");
        gs.keybar.handlers[SDL_SCANCODE_DOWN] = KeyHandler(&stop_down, ("Down"), "Down");
        gs.keybar.handlers_down[SDL_SCANCODE_RETURN] = KeyHandler(&action, ("Action"), "Action");

        gs.keybar.handlers_down[SDL_SCANCODE_Z] = KeyHandler(&start_left, ("Left"), "Left");
        gs.keybar.handlers[SDL_SCANCODE_Z] = KeyHandler(&stop_left, ("Left"), "Left");
        gs.keybar.handlers_down[SDL_SCANCODE_X] = KeyHandler(&start_right, ("Right"), "Right");
        gs.keybar.handlers[SDL_SCANCODE_X] = KeyHandler(&stop_right, ("Right"), "Right");
        gs.keybar.handlers_down[SDL_SCANCODE_K] = KeyHandler(&start_jump, ("Jump"), "Jump");
        gs.keybar.handlers[SDL_SCANCODE_K] = KeyHandler(&stop_jump, ("Jump"), "Jump");
        gs.keybar.handlers_down[SDL_SCANCODE_M] = KeyHandler(&down, ("Down"), "Down");
        gs.keybar.handlers[SDL_SCANCODE_M] = KeyHandler(&stop_down, ("Down"), "Down");

        gs.keybar.handlers_down[SDL_SCANCODE_SPACE] = KeyHandler(&start_jump, ("Jump"), "Jump");
        gs.keybar.handlers[SDL_SCANCODE_SPACE] = KeyHandler(&stop_jump, ("Jump"), "Jump");

        gs.keybar.handlers_down[SDL_SCANCODE_LCTRL] = KeyHandler(&ctrl_down, ("Ctrl"), "Ctrl");
        gs.keybar.handlers[SDL_SCANCODE_LCTRL] = KeyHandler(&ctrl_up, ("Ctrl"), "Ctrl");
        gs.keybar.handlers_down[SDL_SCANCODE_LSHIFT] = KeyHandler(&shift_down, ("Shift"), "Shift");
        gs.keybar.handlers[SDL_SCANCODE_LSHIFT] = KeyHandler(&shift_up, ("Shift"), "Shift");
        
        gs.keybar.handlers_down[SDL_SCANCODE_C] = KeyHandler(&print_coords, ("Print Coords"), "Coords");
        gs.keybar.handlers_down[SDL_SCANCODE_S] = KeyHandler(&switch_slow, ("Switch Slow"), "Slow");
        //gs.keybar.handlers_down[SDL_SCANCODE_E] = KeyHandler(&switch_sensors, ("Show Sensors"), "Sensors");
        gs.keybar.handlers_down[SDL_SCANCODE_U] = KeyHandler(&turn_music, ("On/Off Music"), "Music");
        gs.keybar.handlers_down[SDL_SCANCODE_O] = KeyHandler(&turn_sounds, ("On/Off Sounds"), "Sounds");

        gs.keybar.handlers_down[SDL_SCANCODE_ESCAPE] = KeyHandler(&help, ("Help"), "Help");

        gs.keybar.handlers_down[SDL_SCANCODE_1] = KeyHandler(&the_hero.change_costume, ("Change Costume"), "Cost");
        gs.keybar.handlers_down[SDL_SCANCODE_2] = KeyHandler(&change_language, ("Change Language"), "Lang");

        gs.keybar.handlers_down[SDL_SCANCODE_R] = KeyHandler(&restart, ("Restart"), "Restart");
        gs.keybar.handlers_down[SDL_SCANCODE_L] = KeyHandler(&load, ("Load"), "Load");
    }
}

