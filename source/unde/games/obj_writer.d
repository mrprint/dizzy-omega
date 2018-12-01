module unde.games.obj_writer;

import unde.games.obj_loader;
import std.algorithm;
import std.array;
import std.conv;
import std.path;
import std.stdio;

import std.string;

void save_objfile(ObjFile *obj)
{
    auto file = File(obj.filename, "w");

    int[3] num;

    file.writefln("# Dizzy Omega scene splitter");
    file.writefln("");
    file.writefln("mtllib %s", obj.mtl.filename.absolutePath().asRelativePath(absolutePath(dirName(obj.filename))));
    file.writefln("");
    foreach (object; obj.objects)
    {
        file.writefln("o %s", object.name);

        foreach (vertice; object.vertices)
            file.writefln("v %.6f %.6f %.6f", vertice[0], vertice[1], vertice[2]);

        foreach (texcoord; object.texcoords)
            file.writefln("vt %.6f %.6f", texcoord[0], texcoord[1]);

        foreach (normal; object.normals)
            file.writefln("vn %.6f %.6f %.6f", normal[0], normal[1], normal[2]);
        
        foreach (mesh; object.meshes)
        {
            if (mesh.material !is null)
                file.writefln("usemtl %s", mesh.material);

            file.writefln("s %s", mesh.smooth?"1":"off");

            foreach (face; mesh.faces)
            {
                if (face[0].normal >= 0)
                {
                    file.writef("f");
                    foreach (p; face)
                    {
                        if (p.tex >= 0)
                            file.writef(" %s/%s/%s", p.vert+num[0]+1, p.tex+num[1]+1, p.normal+num[2]+1);
                        else
                            file.writef(" %s//%s", p.vert+num[0]+1, p.normal+num[2]+1);
                    }
                }
                else if (face[0].tex >= 0)
                {
                    file.writef("l");
                    foreach (p; face)
                    {
                        file.writef(" %s/%s", p.vert+num[0]+1, p.tex+num[1]+1);
                    }
                }
                else
                {
                    file.writef("p");
                    foreach (p; face)
                    {
                        file.writef(" %s", p.vert+num[0]+1);
                    }
                }
                file.writefln("");
            }
        }

        num[0] += object.vertices.length;
        num[1] += object.texcoords.length;
        num[2] += object.normals.length;
    }
}
