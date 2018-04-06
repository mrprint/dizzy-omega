module unde.games.collision_detector;

import std.algorithm.sorting;
import std.math;
import std.conv;
import std.string;
import std.stdio;
import std.algorithm.comparison;

import unde.games.obj_loader;
enum Intersect
{
    No = 0,
    Almost = 1,
    Yes = 2,
    In = 3
}

struct Vector
{
    float x,y,z;
}

void scene_to_collision_object (const (ObjFile) *sc, ref Vector[][string] output)
{
    foreach (object; sc.objects)
    {
        uint i;
        uint n = 0, t;
        
        string name = object.name;
        Intersect intersect = Intersect.No;
        
        Vector[] vertices;
        typeof(vertices) new_vertices;
    
        foreach (ref v; object.vertices)
        {
            vertices ~= Vector(-v[0], v[1], v[2]);
        }
    
        //vertices.sort!("a.x < b.x || a.x==b.x && (a.y < b.y || a.y==b.y && a.z < b.z)");
        vertices.sort!("a.x > b.x + 0.001 || abs(a.x-b.x) < 0.001 && (a.y > b.y + 0.001 || abs(a.y-b.y) < 0.001 && a.z > b.z + 0.001)");
    
        for (t = 1; t < vertices.length; t++)
        {
            if (!(abs(vertices[t-1].x-vertices[t].x) < 0.001 && abs(vertices[t-1].y-vertices[t].y) < 0.001 &&
                  abs(vertices[t-1].z-vertices[t].z) < 0.001))
            {
                new_vertices ~= Vector(
                        vertices[t-1].x,
                        vertices[t-1].y,
                        vertices[t-1].z);
            }
        }
    
        new_vertices ~= Vector(
                        vertices[$-1].x,
                        vertices[$-1].y,
                        vertices[$-1].z);
        vertices = new_vertices;
    
        bool _join;
        do
        {
            new_vertices = null;
            _join = false;
            if (name.startsWith("GroundGarden")) writefln("vertices.length = %s", vertices.length);
            for (t = 1; t < vertices.length; t++)
            {
                if (abs(vertices[t-1].x-vertices[t].x) < 0.001 && abs(vertices[t-1].y-vertices[t].y) < 0.001)
                {
                    if (name.startsWith("GroundGarden")) writefln("x:%s,%s, y=%s,%s z:(%s+%s)/2=%s",
                        vertices[t-1].x, vertices[t].x,
                        vertices[t-1].y, vertices[t].y,
                        vertices[t-1].z, vertices[t].z, (vertices[t-1].z+vertices[t].z)/2);
                    new_vertices ~= Vector(
                        (vertices[t-1].x+vertices[t].x)/2,
                        (vertices[t-1].y+vertices[t].y)/2,
                        (vertices[t-1].z+vertices[t].z)/2);
                    _join = true;
                    t++;
                }
                else new_vertices ~= vertices[t-1];
                
                if ( t+1 == vertices.length )
                    new_vertices ~= vertices[t];
            }
            vertices = new_vertices;
        } while (_join);
    
        for (t = 1; t < new_vertices.length; t++)
        {
            if (abs(new_vertices[t-1].y - new_vertices[t].y) < 0.001)
            {
                float y = (new_vertices[t-1].y + new_vertices[t].y)/2;
                new_vertices[t-1].y = y;
                new_vertices[t].y = y;
                t++;
            }
        }
    
        for (t = 1; t < new_vertices.length; t++)
        {
            if (abs(new_vertices[t-1].x - new_vertices[t].x) < 0.001)
            {
                float x = (new_vertices[t-1].x + new_vertices[t].x)/2;
                new_vertices[t-1].x = x;
                new_vertices[t].x = x;
                t++;
            }
        }
    
        output[name] = new_vertices;
    }
}

float vecLen(float[2] v)
{
    return sqrt(v[0]^^2 + v[1]^^2);
}

Intersect if_intersect (float[2] p1, float[2] p2, float[2] cp, float[2] p, bool _debug=false)
{
    float[2] P2 = p2[] - p1[];
    float[2] CP = cp[] - p[];

    float x, y;

    if (abs(P2[0]) < 0.001)
    {
        if (_debug) writefln("P2=%s, CP=%s", P2, CP);
        x = p1[0];
        if (CP[1] == 0.0)
        {
            y = cp[1];
        }
        else
        {
            y = (x - p[0])*CP[1]/CP[0] + p[1];
        }
    }
    else if (abs(CP[1]) < 0.001)
    {
        if (_debug) writefln("P2=%s, CP=%s", P2, CP);
        y = p[1];
        x = (y - p1[1])*P2[0]/P2[1] + p1[0];
    }
    else
    {
        x = (p[0]/CP[0] - p1[0]*P2[1]/P2[0]/CP[1] + (p1[1] - p[1])/CP[1]) / (1/CP[0] - P2[1]/P2[0]/CP[1]);
        y = (x - p1[0])*P2[1]/P2[0] + p1[1];
    }

    float[2] cross = [x, y];
    float[2] cr = p[] - cross[];
    float[2] cd = cp[] - cross[];

    float lambda = vecLen(cr)/vecLen(cd);

    foreach (ref pp; cr)
    {
        if (abs(pp) < 0.01) pp = 0.0;
    }

    for (int i; i < 2; i++)
    {
        if (cr[i] == 0.0 && abs(cd[i]) < 0.1) cd[i] = 0.0;
    }

    if ( !(sgn(cr[0]) != sgn(cd[0]) &&
        sgn(cr[1]) != sgn(cd[1])) &&
        (sgn(cr[0]) != sgn(cd[0]) ||
        sgn(cr[1]) != sgn(cd[1])) &&
        cr[0] != 0.0 && cr[1] != 0.0 &&
        cd[0] != 0.0 && cd[1] != 0.0)
    {
        if(_debug)
        { 
            writefln("%s!=%s, %s!=%s",
                sgn(cr[0]), sgn(cd[0]),
                sgn(cr[1]), sgn(cd[1]));
            writefln("cr=%s, cd=%s", cr, cd);
        }
        if (_debug) writefln("OH %s, %s, %s, %s: cross=%s, lambda = %s", p1, p2, cp, p, cross, lambda);
        return Intersect.Yes;
    }

    if (sgn(cr[0]) != sgn(cd[0]) && cr[0] != 0.0 && cd[0] != 0.0 ||
        sgn(cr[1]) != sgn(cd[1]) && cr[1] != 0.0 && cd[1] != 0.0) lambda = -lambda;

    if (_debug) writefln("%s, %s, %s, %s: cross=%s, lambda = %s (cr=%s, cd=%s)", p1, p2, cp, p, cross, lambda, cr, cd);
    
    if (lambda > 0.0) return Intersect.In;
    else if (lambda == 0.0) return Intersect.Yes;
    else return Intersect.No;
}

long if_intersect (float[2] p1, float[2] p2, float[2] cp, float[4] box, bool _debug=false)
{
    assert(p1 != p2);
    assert(p1 != cp);
    assert(p2 != cp);
    
    float[2][] points;
    points ~= [ box[0], box[1] ];
    points ~= [ box[0], box[3] ];
    points ~= [ box[2], box[1] ];
    points ~= [ box[2], box[3] ];

    Intersect max_i = Intersect.No;
    Intersect min_i = Intersect.In;

    long inners;

    foreach(j, p; points)
    {
        auto i = if_intersect (p1, p2, cp, p, _debug);
        if (i == Intersect.In)
            inners |= 2^^j;
        max_i = max(max_i, i);
        min_i = min(min_i, i);
    }

    if (_debug) writefln("Отрезок, точка и бокс. (%s, %s) %s, %s, %s, %s",
        min_i, max_i, p1, p2, cp, box);

    if (max_i == min_i) return min_i;

    float[2] P2 = p2[] - p1[];
    float x, y;
    x = box[0];
    if (p1[0] < x && x < p2[0] ||
        p2[0] < x && x < p1[0])
    {
        y = (x - p1[0])*P2[1]/P2[0] + p1[1];
        if (_debug) writefln("1. (%s, %s)", x, y);
        if (box[1] < y && y < box[3])
            return Intersect.Yes;
    }

    x = box[2];
    if (p1[0] < x && x < p2[0] ||
        p2[0] < x && x < p1[0])
    {
        y = (x - p1[0])*P2[1]/P2[0] + p1[1];
        if (_debug) writefln("2. (%s, %s)", x, y);
        if (box[1] < y && y < box[3])
            return Intersect.Yes;    
    }

    y = box[1];
    if (p1[1] < y && y < p2[1] ||
        p2[1] < y && y < p1[1])
    {
        x = (y - p1[1])*P2[0]/P2[1] + p1[0];
        if (_debug) writefln("3. (%s, %s)", x, y);
        if (box[0] < x && x < box[2])
            return Intersect.Yes;
    }

    y = box[3];
    if (p1[1] < y && y < p2[1] ||
        p2[1] < y && y < p1[1])
    {
        x = (y - p1[1])*P2[0]/P2[1] + p1[0];
        if (_debug) writefln("4. (%s, %s)", x, y);
        if (box[0] < x && x < box[2])
            return Intersect.Yes;
    }

    if (box[0] < p1[0] && p1[0] < box[2] &&
        box[1] < p1[1] && p1[1] < box[3] ||
        box[0] < p2[0] && p2[0] < box[2] &&
        box[1] < p2[1] && p2[1] < box[3])
        return Intersect.Yes;

    if (_debug) writefln("no");
    return -inners;
}

string last_intersect;

struct CollisionCacheEntry
{
    string name;
    size_t from;
    size_t to;
}

struct SC
{
    int x, y;
}

private CollisionCacheEntry[][SC][void *] collision_cache;

void reset_collision_cache()
{
    collision_cache = null;
}

Intersect if_intersect (Vector[][string] co, float[6] box, bool _debug = false)
in
{
    assert(box[0] < box[3], format("Box x0=%s must be less x1=%s", box[0], box[3]));
    assert(box[1] < box[4]);
    assert(box[2] < box[5]);
}
body
{
    size_t j;

    Intersect intersect = Intersect.No;

    Intersect check_object(string name, Vector[] object, size_t from, size_t to,
        void *co, SC *sc)
    {
        Intersect intersect = Intersect.No;

        size_t cfrom = object.length, cto = min(2, object.length);

        if (object.length < 3) return intersect;

        /*if (abs(object[0].y - box[1]) > 3.0 &&
            abs(object[$-1].y - box[1]) > 3.0 &&
            abs(object[$-1].y - object[0].y) < 3.0)
            return intersect;*/
        
        for (j = from; j < to; j++)
        {
            auto v1 = object[j-2];
            auto v2 = object[j-1];
            auto v3 = object[j];
            typeof(v3) v4;
            if (j+1 < object.length) v4 = object[j+1];
            
            bool __debug = _debug;

            if (co)
            {
                auto vl = j+1 < object.length?v4:v3;
                if (v1.x < (sc.x*30 - 20) || vl.x > (sc.x*30 + 20) ||
                    v1.y < (sc.y*17 - 10) && vl.y < (sc.y*17 - 10) || 
                    v1.y > (sc.y*17 + 10) && vl.y > (sc.y*17 + 10))
                {
                    continue;
                }
            
                if (j < cfrom) cfrom = j;
                if (j+1 > cto) cto = j+1;
            }
            
            if (_debug && abs(v1.x - box[0]) > 3.0 && abs(v3.x - box[0]) > 3.0) __debug = false;
            if (abs(v1.x - box[0]) > 3.0 && abs(v3.x - box[0]) > 3.0 &&
                abs(v3.x - v1.x) < 3.0) continue;

            if (v1.x == v2.x && v3.x == v4.x)
            {
                float z = (v1.z + v2.z + v3.z + v4.z)/4;
                if (box[2] <= z && z <= box[5])
                {
                    Intersect max_i = Intersect.No;
                    Intersect min_i = Intersect.In;
                    long inners = 2^^4-1;
                    
                    auto i = if_intersect ([v1.x, v1.y], [v2.x, v2.y], [v3.x, v3.y],
                        [box[0], box[1], box[3], box[4]], __debug);
                    Intersect inter;
                    inter = Intersect.No;
                    if (i > 0) inter = cast(Intersect) i;
                    if (i <= 0) inners &= -i;
                    max_i = max(max_i, inter);
                    min_i = min(min_i, inter);
    
                    i = if_intersect ([v1.x, v1.y], [v3.x, v3.y], [v4.x, v4.y],
                        [box[0], box[1], box[3], box[4]], __debug);
                    inter = Intersect.No;
                    if (i > 0) inter = cast(Intersect) i;
                    if (i <= 0) inners &= -i;
                    max_i = max(max_i, inter);
                    min_i = min(min_i, inter);
    
                    i = if_intersect ([v2.x, v2.y], [v4.x, v4.y], [v1.x, v1.y],
                        [box[0], box[1], box[3], box[4]], __debug);
                    inter = Intersect.No;
                    if (i > 0) inter = cast(Intersect) i;
                    if (i <= 0) inners &= -i;
                    max_i = max(max_i, inter);
                    min_i = min(min_i, inter);
    
                    i = if_intersect ([v3.x, v3.y], [v4.x, v4.y], [v1.x, v1.y],
                        [box[0], box[1], box[3], box[4]], __debug);
                    inter = Intersect.No;
                    if (i > 0) inter = cast(Intersect) i;
                    if (i <= 0) inners &= -i;
                    max_i = max(max_i, inter);
                    min_i = min(min_i, inter);

                    if (__debug) writefln("%s. (%s, %s, %s) points: %s, %s, %s, %s, box: %s", name, 
                        min_i, max_i, inners, v1, v2, v3, v4, box);
    
                    if (min_i > Intersect.No || inners > 0)
                    {
                        last_intersect = name;
                        
                        if (_debug) writefln("%s. %s", min_i, name);
                        if (!co) return max(min_i, Intersect.Yes);
                        else intersect = max(min_i, Intersect.Yes, intersect);
                    }
                }
                    
                j++;
            }
            else
            {
                float z = (v1.z + v2.z + v3.z)/4;
                if (box[2] <= z && z <= box[5])
                {
                    Intersect max_i = Intersect.No;
                    Intersect min_i = Intersect.In;
                    long inners = 2^^4-1;
                    
                    auto i = if_intersect ([v1.x, v1.y], [v2.x, v2.y], [v3.x, v3.y],
                        [box[0], box[1], box[3], box[4]], __debug);
                        
                    Intersect inter;
                    inter = Intersect.No;
                    if (i > 0) inter = cast(Intersect) i;
                    if (i <= 0) inners &= -i;
                    max_i = max(max_i, inter);
                    min_i = min(min_i, inter);
    
                    i = if_intersect ([v2.x, v2.y], [v3.x, v3.y], [v1.x, v1.y],
                        [box[0], box[1], box[3], box[4]], __debug);
                    inter = Intersect.No;
                    if (i > 0) inter = cast(Intersect) i;
                    if (i <= 0) inners &= -i;
                    max_i = max(max_i, inter);
                    min_i = min(min_i, inter);
    
                    i = if_intersect ([v3.x, v3.y], [v1.x, v1.y], [v2.x, v2.y],
                        [box[0], box[1], box[3], box[4]], __debug);
                    inter = Intersect.No;
                    if (i > 0) inter = cast(Intersect) i;
                    if (i <= 0) inners &= -i;
                    max_i = max(max_i, inter);
                    min_i = min(min_i, inter);

                    if (__debug) writefln("%s. (%s, %s, %s) points: %s, %s, %s, box: %s", name, 
                        min_i, max_i, inners, v1, v2, v3, box);
    
                    if (min_i > Intersect.No || inners > 0)
                    {
                        last_intersect = name;
                        if (_debug) writefln("%s. %s", min_i, name);
                        if (!co) return max(min_i, Intersect.Yes);
                        else intersect = max(min_i, Intersect.Yes, intersect);
                    }
                }
            }
        }

        if (co && cto > cfrom)
        {
            collision_cache[co][*sc] ~= CollisionCacheEntry(name, cfrom, cto);
        }
        
        return intersect;
    }

    float cx = (box[0] + box[3])/2;
    float cy = (box[1] + box[4])/2;

    SC sc = SC(cast(int)round(cx/30), cast(int)round(cy/17));

    if (cast(void*) co !in collision_cache ||
        sc !in collision_cache[cast(void*) co])
    {
        if (cast(void*)co !in collision_cache)
            collision_cache[cast(void*)co] = null;
            
        if (sc !in collision_cache[cast(void*)co])
            collision_cache[cast(void*)co][sc] = [];

        foreach (name, object; co)
        {
            //writefln("%s from %s to %s", name, 2, object.length);
            intersect = max(intersect, check_object(name, object, 2, object.length, cast(void*) co, &sc));
        }
    }
    else
    {
        //writefln("%s objects instead of %s", collision_cache[cast(void*) co][sc].length, co.length);
        foreach (cache_entry; collision_cache[cast(void*) co][sc])
        {
            //writefln("*%s from %s to %s", cache_entry.name, cache_entry.from, cache_entry.to);
            intersect = check_object(cache_entry.name, co[cache_entry.name],
                cache_entry.from, cache_entry.to, null, &sc);
            if (intersect > Intersect.No) return intersect;
        }
    }
            
    return intersect;    
}

