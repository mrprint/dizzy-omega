module unde.games.object;

import derelict.assimp3.assimp;
import unde.global_state;

class GameObject
{
    enum{
        LEFT_KEY = 0x01,
        RIGHT_KEY = 0x02,
        UP_KEY = 0x04,
        DOWN_KEY = 0x08,
        CTRL_KEY = 0x10,
        SHIFT_KEY = 0x20,
    }
    
    protected MainGameObject root;
    long frame;
    ulong state;
    const (aiScene)*[string] models;
    aiVector3D[][string][string] collision_objects;

    this(MainGameObject root_object)
    {
        root = root_object;
    }
    
    void draw(GlobalState gs)
    {
    }

    bool tick(GlobalState gs)
    {
        frame++;
        return true;
    }

    void reset_frame()
    {
        frame = 0;
    }

    protected @property ulong gframe()
    {
        return root.frame;
    }
}

class MainGameObject:GameObject
{
    float scrx = 0.0, scry = 0.0;
    ulong keys;

    this(MainGameObject root)
    {
        super(root);
    }
}

class StaticGameObject:GameObject
{
    float x, y, z;

    this(MainGameObject root)
    {
        super(root);
    }

    void load(string[string] s)
    {
    }

    void save(ref string[string] s)
    {
    }
}

class LiveGameObject:StaticGameObject
{    
    float energy;
    int lives;
    string killed_by;
    bool show_sensors;

    this(MainGameObject root)
    {
        super(root);
    }
}
