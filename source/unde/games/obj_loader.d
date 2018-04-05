module unde.games.obj_loader;

import std.algorithm;
import std.array;
import std.conv;
import std.path;
import std.stdio;

import std.string;
struct MtlMaterial
{
    string name;
    string map_diffuse;
    string map_bump;
    float[3] ambient;
    float[3] diffuse;
    float[3] specular;
    float[3] emissive;
    float specular_koef;
    float optical_density;
    float transparency;
    int illum_model;
}

struct MtlFile
{
    string filename;
    MtlMaterial*[string] materials;
}

struct ObjIndex
{
    int vert = -1;
    int tex = -1;
    int normal = -1;
}

struct ObjMesh
{
    string material;
    bool smooth;
    ObjIndex*[][] faces;
}

struct ObjObject
{
    string name;
    float[3][] vertices;
    float[2][] texcoords;
    float[3][] normals;

    ObjMesh*[] meshes;
}

struct ObjFile
{
    string filename;
    MtlFile *mtl;
    ObjObject*[] objects;
}

private MtlFile*[string] mtl_files;

private float[3] get_3f(char[] str)
{
    return str.splitter(" ").map!(a => a.to!(float)())().array[0..3];
}

private float[2] get_2f(char[] str)
{
    return str.splitter(" ").map!(a => a.to!(float)())().array[0..2];
}

private int get_index(char[] str)
{
    if (str == "") return -1;
    else return str.to!(int);
}

private ObjIndex* get_indices(char[] str, int[3] offsets)
{
    int[] numbers = str.split("/").map!(a => a.get_index())().array;
    if (numbers.length < 1) numbers ~= -1;
    if (numbers.length < 2) numbers ~= -1;
    if (numbers.length < 3) numbers ~= -1;
    numbers[] -= offsets[];
    return new ObjIndex(numbers[0]-1, numbers[1]-1, numbers[2]-1);
}

private ObjIndex*[] get_face(char[] str, int[3] offsets)
{
    return str.split(" ").map!(a => a.get_indices(offsets))().array[0..$];
}

MtlFile *load_mtlfile(string filename)
{
    MtlFile *mtl = new MtlFile;
    mtl.filename = filename;

    string mat;
    
    auto file = File(filename);
    foreach (line; file.byLine())
    {
        if (line == "" || line[0] == '#')
            continue;
        else if (line[0..3] == "Ns ")
        {
            mtl.materials[mat].specular_koef = line[3..$].to!(float);
        }
        else if (line[0..3] == "Ka ")
        {
            mtl.materials[mat].ambient = get_3f(line[3..$]);
        }
        else if (line[0..3] == "Kd ")
        {
            mtl.materials[mat].diffuse = get_3f(line[3..$]);
        }
        else if (line[0..3] == "Ks ")
        {
            mtl.materials[mat].specular = get_3f(line[3..$]);
        }
        else if (line[0..3] == "Ke ")
        {
            mtl.materials[mat].emissive = get_3f(line[3..$]);
        }
        else if (line[0..3] == "Ni ")
        {
            mtl.materials[mat].optical_density = line[3..$].to!(float);
        }
        else if (line[0..2] == "d ")
        {
            mtl.materials[mat].transparency = line[2..$].to!(float);
        }
        else if (line[0..7] == "map_Kd ")
        {
            mtl.materials[mat].map_diffuse = line[7..$].idup();
        }
        else if (line[0..6] == "map_d ")
        {
            // Just ignore
        }
        else if (line[0..6] == "illum ")
        {
            mtl.materials[mat].illum_model = line[6..$].to!(int);
        }
        else if (line[0..7] == "newmtl ")
        {
            mat = line[7..$].idup();
            mtl.materials[mat] = new MtlMaterial;
        }
        else if (line[0..9] == "map_Bump ")
        {
            mtl.materials[mat].map_diffuse = line[9..$].idup();
        }
        else
        {
            throw new Exception("Cannot parse mtl line: "~line.idup());
        }
    }

    return mtl;
}

ObjFile *load_objfile(string filename)
{
    ObjFile *obj = new ObjFile;
    obj.filename = filename;

    int[3] offsets;
    
    auto file = File(filename);
    foreach (line; file.byLine())
    {
        if (line == "" || line[0] == '#')
            continue;
        else if (line[0..2] == "o ")
        {
            if (obj.objects.length > 0)
            {
                offsets[0] += obj.objects[$-1].vertices.length;
                offsets[1] += obj.objects[$-1].texcoords.length;
                offsets[2] += obj.objects[$-1].normals.length;
            }
            
            obj.objects ~= new ObjObject;
            obj.objects[$-1].name = line[2..$].idup();
        }
        else if (line[0..2] == "v ")
        {
            obj.objects[$-1].vertices ~= get_3f(line[2..$]);
        }
        else if (line[0..3] == "vt ")
        {
            obj.objects[$-1].texcoords ~= get_2f(line[3..$]);
        }
        else if (line[0..3] == "vn ")
        {
            obj.objects[$-1].normals ~= get_3f(line[3..$]);
        }
        else if (line[0..2] == "s ")
        {
            string material;
            bool n = true;
            if (obj.objects[$-1].meshes.length > 0)
            {
                material = obj.objects[$-1].meshes[$-1].material;
                n = obj.objects[$-1].meshes[$-1].faces.length > 0;
            }
            
            if (n)
            {
                obj.objects[$-1].meshes ~= new ObjMesh;
                obj.objects[$-1].meshes[$-1].material = material;
            }
            
            obj.objects[$-1].meshes[$-1].smooth = (line[2..$] == "1");
        }
        else if (line[0..2] == "p " || line[0..2] == "l " || line[0..2] == "f ")
        {
            obj.objects[$-1].meshes[$-1].faces ~= get_face(line[2..$], offsets);
        }
        else if (line[0..7] == "usemtl ")
        {
            obj.objects[$-1].meshes ~= new ObjMesh;
            obj.objects[$-1].meshes[$-1].material = line[7..$].idup();
        }
        else if (line[0..7] == "mtllib ")
        {
            string mtlfile = line[7..$].idup();
            
            if (!isAbsolute(mtlfile))
            {
                mtlfile = chainPath(dirName(filename), mtlfile).array;
            }
            
            if (mtlfile !in mtl_files)
            {
                    mtl_files[mtlfile] = load_mtlfile(mtlfile);
            }
            
            obj.mtl = mtl_files[mtlfile];
        }
        else
        {
            throw new Exception("Cannot parse obj line: "~line.idup());
        }
    }

    return obj;    
}
