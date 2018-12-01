module unde.games.obj_joiner;

import unde.games.obj_loader;
import unde.games.collision_detector;
import std.algorithm;
import std.array;
import std.conv;
import std.path;
import std.stdio;
import std.math;

import std.string;

void join_objfiles(ObjFile *obj, ObjFile *obj2)
{
    bool[string] o;
    foreach (ref object; obj.objects)
    {
        o[object.name] = true;
    }

    foreach (ref object; obj2.objects)
    {
        if (object.name !in o)
        {
            obj.objects ~= object;
        }
    }

    foreach (name, ref material; obj2.mtl.materials)
    {
        if (name !in obj.mtl.materials)
        {
            obj.mtl.materials[name] = material;
        }
    }
}
