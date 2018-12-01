module unde.games.obj_splitter;

import unde.games.obj_loader;
import unde.games.collision_detector;
import std.algorithm;
import std.array;
import std.conv;
import std.path;
import std.stdio;
import std.math;

import std.string;

ObjFile*[SC] split_objfile(ObjFile *obj)
{
    ObjFile*[SC] objs;

    foreach (object; obj.objects)
    {
        foreach (mesh; object.meshes)
        {
            foreach (face; mesh.faces)
            {
                SC lt, rb;
                foreach (i, p; face)
                {
                    float[3] vert = object.vertices[p.vert];
                    int X = cast(int)floor((-vert[0]+15.0 - 2.0)/30.0);
                    int Y = cast(int)floor((vert[1]+8.5 - 2.0)/17.0);
                    if (i == 0)
                    {
                        lt = rb = SC(X,Y);
                    }
                    else
                    {
                        if (X < lt.x) lt.x = X;
                        if (Y < lt.y) lt.y = Y;
                        if (X > rb.x) rb.x = X;
                        if (Y > rb.y) rb.y = Y;
                    }

                    X = cast(int)floor((-vert[0]+15.0 + 2.0)/30.0);
                    Y = cast(int)floor((vert[1]+8.5 + 2.0)/17.0);
                    if (X < lt.x) lt.x = X;
                    if (Y < lt.y) lt.y = Y;
                    if (X > rb.x) rb.x = X;
                    if (Y > rb.y) rb.y = Y;
                }

                foreach (Y; lt.y..rb.y+1)
                {
                    foreach (X; lt.x..rb.x+1)
                    {
                        if (SC(X,Y) !in objs)
                        {
                            objs[SC(X,Y)] = new ObjFile;
                            objs[SC(X,Y)].filename = format("models/screen_%02d_%02d.obj", X, Y);
                            objs[SC(X,Y)].mtl = obj.mtl;
                        }
    
                        if (objs[SC(X,Y)].objects is null || 
                                objs[SC(X,Y)].objects[$-1].name != object.name)
                        {
                            objs[SC(X,Y)].objects ~= new ObjObject;
                            objs[SC(X,Y)].objects[$-1].name = object.name;
                            objs[SC(X,Y)].objects[$-1].vertices = object.vertices;
                            objs[SC(X,Y)].objects[$-1].texcoords = object.texcoords;
                            objs[SC(X,Y)].objects[$-1].normals = object.normals;
                        }
    
                        with (objs[SC(X,Y)].objects[$-1])
                        {
                            if (meshes is null ||
                                    meshes[$-1].material != mesh.material ||
                                    meshes[$-1].smooth != mesh.smooth)
                            {
                                meshes ~= new ObjMesh;
                                meshes[$-1].material = mesh.material;
                                meshes[$-1].smooth = mesh.smooth;
                            }
    
                            meshes[$-1].faces ~= face;
                        }
                    }
                }
            }
        }
    }

    return objs;
}
