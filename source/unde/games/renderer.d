module unde.games.renderer;

import std.format;
import std.conv;
import std.math;
import std.string;
import std.stdio;

import derelict.sdl2.image;
import derelict.sdl2.sdl;
import derelict.opengl3.gl3;
import derelict.opengl3.gl;
import std.algorithm.comparison;

import std.utf;
import unde.global_state;
import unde.games.obj_loader;

private GLuint[string] textures;

/* ---------------------------------------------------------------------------- */
bool apply_material(GlobalState gs, const (MtlMaterial) *mtl, 
    string delegate(GlobalState gs, string name) tex_anim = null)
{
    float[4] c;

    GLenum fill_mode;
    int ret1, ret2;
    float opacity = 1.0;

    if (mtl.transparency) opacity = mtl.transparency;

    if (mtl.diffuse[0].isNaN())
        c = [0.8f, 0.8f, 0.8f, opacity];
    else
        c = mtl.diffuse ~ opacity;
    glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, cast(const(float)*)c);

    //if (mtl.specular[0].isNaN())
        c = [0.0f, 0.0f, 0.0f, 1.0f];
    //else
    //    c = mtl.specular ~ 1.0f;
    glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, cast(const(float)*)c);

    if (mtl.ambient[0].isNaN())
	c = [0.2f, 0.2f, 0.2f, 1.0f];
    else
        c = mtl.ambient ~ 1.0f;
    glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, cast(const(float)*)c);

    if (mtl.emissive[0].isNaN())
        c = [0.0f, 0.0f, 0.0f, 1.0f];
    else
        c = mtl.emissive ~ 1.0f;
    glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, cast(const(float)*)c);

    glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, 0.0f);
    
    glPolygonMode(GL_FRONT_AND_BACK, false ? GL_LINE : GL_FILL);

    //Not Two sided
	glEnable(GL_CULL_FACE);

    bool normals = false;
    if(mtl.map_diffuse !is null)
    {
        string tex_name = mtl.map_diffuse;
        if (tex_anim) tex_name = tex_anim(gs, tex_name);
        string p = format("models/%s", tex_name);

        GLuint texture_name;
        bool link;
        if (p !in textures)
        {
            glGenTextures(1, &texture_name);// generate GL-textures ID's
            link = true;
        }
        else texture_name = textures[p];
        //writefln("texture_name=%s", texture_name);
        glBindTexture(GL_TEXTURE_2D, texture_name);// Binding of texture name

        if (link)
        {
            //
            //redefine standard texture values
            //
            // We will use linear interpolation for magnification filter
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            // tiling mode
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, true ? GL_REPEAT : GL_CLAMP);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, true ? GL_REPEAT : GL_CLAMP);
                                    
            auto image = IMG_Load(p.toStringz);
            if (!image)
            {
                throw new Exception(format("Error while loading texture: %s", p));
            }
    
            // Texture specification
            glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, image.w, image.h, 0, GL_RGBA, GL_UNSIGNED_BYTE,
                image.pixels);
            SDL_FreeSurface(image);

            textures[p] = texture_name;
        }
        return true;
    }
    else
    {
        glBindTexture(GL_TEXTURE_2D, 0);
    }

    return false;
}

GLuint[const (ObjMesh)*] gl_lists;

/* ---------------------------------------------------------------------------- */
void recursive_render (GlobalState gs, const (ObjFile) *sc,
    bool delegate(GlobalState gs, string name) anim = null,
    string delegate(GlobalState gs, string name) tex_anim = null,
    bool dontcache = false, bool reverse = false)
{
    foreach(i; 0..sc.objects.length)
    {
        const(ObjObject) *object;
        if (!reverse) object = sc.objects[i];
        else object = sc.objects[sc.objects.length-1-i];

        GLuint prev_tex_id_idx = 0;
        
        glPushMatrix();
    
        bool draw = true;
        string name = object.name;
        if (anim) draw = anim(gs, name);
    
        if (draw)
        {
            /* draw all meshes assigned to this node */
            foreach (mesh; object.meshes) {
                //writefln("mesh %d. material %d", n, mesh.mMaterialIndex);
                bool is_texture = apply_material(gs, sc.mtl.materials[mesh.material], tex_anim);
        
                if(object.normals is null) {
                    glDisable(GL_LIGHTING);
                } else {
                    glEnable(GL_LIGHTING);
                }
                
                glDisable(GL_COLOR_MATERIAL);
    
                bool full_draw;
                if (!tex_anim && !dontcache)
                {
                    if (mesh in gl_lists)
                    {
                        glCallList(gl_lists[mesh]);
                    }
                    else
                    {
                        gl_lists[mesh] = glGenLists(1);
                        if (gl_lists[mesh] <= 0)
                            throw new Exception(format("Error while glGenLists: %s", gl_lists[mesh]));
                        glNewList(gl_lists[mesh], GL_COMPILE_AND_EXECUTE);
                        full_draw = true;
                    }
                }
                else full_draw = true;
        
                if (full_draw)
                {
                    foreach (face; mesh.faces) {
                        GLenum face_mode;
            
                        switch(face.length) {
                            case 1: face_mode = GL_POINTS; break;
                            case 2: face_mode = GL_LINES; break;
                            case 3: face_mode = GL_TRIANGLES; break;
                            default: face_mode = GL_POLYGON; break;
                        }
            
                        glBegin(face_mode);
            
                        foreach(index; face) {
                            //glColor4fv(0.0f,0.0f,0.0f,1.0f);
            
                            if (is_texture && index.tex >= 0)
                                glTexCoord2f(object.texcoords[index.tex][0], 1.0-object.texcoords[index.tex][1]);
            
                            if(index.normal >= 0)
                            {
                                float[3] normal = [ object.normals[index.normal][0], 
                                                   -object.normals[index.normal][1],
                                                   -object.normals[index.normal][2]];
                                glNormal3fv(normal.ptr);
                            }

                            if (index.vert >= 0)
                            {
                                float[3] coords = [-object.vertices[index.vert][0],
                                                    object.vertices[index.vert][1],
                                                    object.vertices[index.vert][2]];
                                glVertex3fv(coords.ptr);
                            }
                        }
            
                        glEnd();
                     }
                }
        
                if (!tex_anim && !dontcache && full_draw)
                {
                    glEndList();
                }
            }
        }
        
        glPopMatrix();
    }
}

void render_box (float[6] box)
{
    glBegin(GL_POLYGON);
    glVertex3f(box[0], box[1], box[2]);
    glVertex3f(box[0], box[4], box[2]);
    glVertex3f(box[3], box[4], box[2]);
    glVertex3f(box[3], box[1], box[2]);
    glEnd();

    glBegin(GL_POLYGON);
    glVertex3f(box[0], box[1], box[5]);
    glVertex3f(box[0], box[4], box[5]);
    glVertex3f(box[3], box[4], box[5]);
    glVertex3f(box[3], box[1], box[5]);
    glEnd();

    glBegin(GL_POLYGON);
    glVertex3f(box[0], box[1], box[2]);
    glVertex3f(box[0], box[4], box[2]);
    glVertex3f(box[0], box[4], box[5]);
    glVertex3f(box[0], box[1], box[5]);
    glEnd();

    glBegin(GL_POLYGON);
    glVertex3f(box[3], box[1], box[2]);
    glVertex3f(box[3], box[4], box[2]);
    glVertex3f(box[3], box[4], box[5]);
    glVertex3f(box[3], box[1], box[5]);
    glEnd();

    glBegin(GL_POLYGON);
    glVertex3f(box[0], box[1], box[2]);
    glVertex3f(box[3], box[1], box[2]);
    glVertex3f(box[3], box[1], box[5]);
    glVertex3f(box[0], box[1], box[5]);
    glEnd();

    glBegin(GL_POLYGON);
    glVertex3f(box[0], box[4], box[2]);
    glVertex3f(box[3], box[4], box[2]);
    glVertex3f(box[3], box[4], box[5]);
    glVertex3f(box[0], box[4], box[5]);
    glEnd();
}

GLuint load_texture(string path, bool grayscale = false, int skiplines=0)
{
    GLuint texture_name;
    glGenTextures(1, &texture_name);// generate GL-textures ID's
    glBindTexture(GL_TEXTURE_2D, texture_name);// Binding of texture name

    //
    //redefine standard texture values
    //
    // We will use linear interpolation for magnification filter
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    // tiling mode
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, true ? GL_REPEAT : GL_CLAMP);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, true ? GL_REPEAT : GL_CLAMP);
                            
    auto image = IMG_Load(path.toStringz());
    if (!image)
    {
        throw new Exception(format("Error while loading texture: %s", path));
    }

    // Texture specification
    glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, 
        image.w, image.h-skiplines, 0, grayscale?GL_LUMINANCE:GL_RGBA, GL_UNSIGNED_BYTE,
        image.pixels + skiplines*image.w);

    return texture_name;
}

void print_text(string text)
{
    string[] encoding = ["@"," ","!",`"`,"#","$","%","&","'","(",")","*","+",",","-",".",
                         "/","0","1","2","3","4","5","6","7","8","9",":",";","<","=",">",
                         "?","@","A","B","C","D","E","F","G","H","I","J","K","L","M","N",
                         "O","P","Q","R","S","T","U","V","W","X","Y","Z","[",`\`,"]","^",
                         "_","`","a","b","c","d","e","f","g","h","i","j","k","l","m","n",
                         "o","p","q","r","s","t","u","v","w","x","y","z","{","|","}","~",
                         " "," "," ","Ё"," "," "," "," "," "," "," "," "," "," "," "," ",
                         " "," "," ","ё"," "," "," "," "," "," "," "," "," "," "," "," ",
                         "ю","а","б","ц","д","е","ф","г","х","и","й","к","л","м","н","о",
                         "п","я","р","с","т","у","ж","в","ь","ы","з","ш","э","щ","ч","ъ",
                         "Ю","А","Б","Ц","Д","Е","Ф","Г","Х","И","Й","К","Л","М","Н","О",
                         "П","Я","Р","С","Т","У","Ж","В","Ь","Ы","З","Ш","Э","Щ","Ч","Ъ"];

    size_t x = 0;
    int y = 0;
    for (size_t i=0; i < text.length; i+=text.stride(i))
    {
        string chr = text[i..i+text.stride(i)];

        if (chr == "\n")
        {
            y--;
            x=0;
            continue;
        }
        
        size_t code = -1;
        foreach(j, enc; encoding)
        {
            if (chr == enc)
            {
                code = j;
                break;
            }
        }
        
        assert(code != -1, chr);
        float cx = (code%16)/16.0;
        float cy = (code/16)/12.0;

        glBegin(GL_POLYGON);
        glTexCoord2f(cx, cy);
        glVertex3f(x, y, -10.0);
        glTexCoord2f(cx, cy+1.0/12);
        glVertex3f(x, y-1.0, -10.0);
        glTexCoord2f(cx+1.0/16, cy+1.0/12);
        glVertex3f(x+1.0, y-1.0, -10.0);
        glTexCoord2f(cx+1.0/16, cy);
        glVertex3f(x+1.0, y, -10.0);
        glEnd();

        x++;
    }
}


