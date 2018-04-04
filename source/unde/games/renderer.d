module unde.games.renderer;

import std.format;
import std.conv;
import std.math;
import std.string;
import std.stdio;

import derelict.sdl2.image;
import derelict.opengl3.gl3;
import derelict.assimp3.assimp;
import derelict.opengl3.gl;
import std.algorithm.comparison;

import std.utf;
import unde.global_state;
/* ---------------------------------------------------------------------------- */
void get_bounding_box_for_node (const (aiScene) *sc,
    const (aiNode)* nd,
	aiVector3D* minv,
	aiVector3D* maxv,
	aiMatrix4x4* trafo
){
	aiMatrix4x4 prev;
	uint n = 0, t;

	prev = *trafo;
	aiMultiplyMatrix4(trafo,&nd.mTransformation);

	for (; n < nd.mNumMeshes; ++n) {
		const (aiMesh)* mesh = sc.mMeshes[nd.mMeshes[n]];
		for (t = 0; t < mesh.mNumVertices; ++t) {

			aiVector3D tmp = mesh.mVertices[t];
			aiTransformVecByMatrix4(&tmp,trafo);

			minv.x = min(minv.x,tmp.x);
			minv.y = min(minv.y,tmp.y);
			minv.z = min(minv.z,tmp.z);

			maxv.x = max(maxv.x,tmp.x);
			maxv.y = max(maxv.y,tmp.y);
			maxv.z = max(maxv.z,tmp.z);
		}
	}

	for (n = 0; n < nd.mNumChildren; ++n) {
		get_bounding_box_for_node(sc, nd.mChildren[n],minv,maxv,trafo);
	}
	*trafo = prev;
}

/* ---------------------------------------------------------------------------- */
void get_bounding_box (const (aiScene) *sc, aiVector3D* minv, aiVector3D* maxv)
{
	aiMatrix4x4 trafo;
	aiIdentityMatrix4(&trafo);

	minv.x = minv.y = minv.z =  1e10f;
	maxv.x = maxv.y = maxv.z = -1e10f;
	get_bounding_box_for_node(sc, sc.mRootNode,minv,maxv,&trafo);
}

/* ---------------------------------------------------------------------------- */
void color4_to_float4(const (aiColor4D) *c, ref float[4] f)
{
	f[0] = c.r;
	f[1] = c.g;
	f[2] = c.b;
	f[3] = c.a;
}

/* ---------------------------------------------------------------------------- */
void set_float4(ref float[4] f, float a, float b, float c, float d)
{
	f[0] = a;
	f[1] = b;
	f[2] = c;
	f[3] = d;
}

private GLuint[string] textures;

/* ---------------------------------------------------------------------------- */
bool apply_material(GlobalState gs, const (aiMaterial) *mtl, string delegate(GlobalState gs, string name) tex_anim = null)
{
	float[4] c;

	GLenum fill_mode;
	int ret1, ret2;
	aiColor4D diffuse = {0,0,0,0};
	aiColor4D specular;
	aiColor4D ambient;
	aiColor4D emission;
	float shininess, strength, opacity;
	int two_sided;
	int wireframe;
	uint max;

        max = 1;
	ret1 = aiGetMaterialFloatArray(mtl, AI_MATKEY_OPACITY, 0, 0, &opacity, &max);
	if(ret1 == aiReturn_SUCCESS) {
        }
        else {
            opacity = 1.0;
	}

        set_float4(c, 0.8f, 0.8f, 0.8f, opacity);
	if(aiReturn_SUCCESS == aiGetMaterialColor(mtl, AI_MATKEY_COLOR_DIFFUSE, 0, 0, &diffuse))
        {
            color4_to_float4(&diffuse, c);
            c[3] = opacity;
        }
        else
            throw new Exception(format("Error while aiGetMaterialColor"));
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, cast(const(float)*)c);

	set_float4(c, 0.0f, 0.0f, 0.0f, 1.0f);
	if(aiReturn_SUCCESS == aiGetMaterialColor(mtl, AI_MATKEY_COLOR_SPECULAR, 0, 0, &specular))
            color4_to_float4(&specular, c);
	glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, cast(const(float)*)c);

	set_float4(c, 0.2f, 0.2f, 0.2f, 1.0f);
	if(aiReturn_SUCCESS == aiGetMaterialColor(mtl, AI_MATKEY_COLOR_AMBIENT, 0, 0, &ambient))
            color4_to_float4(&ambient, c);
	glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, cast(const(float)*)c);

	set_float4(c, 0.0f, 0.0f, 0.0f, 1.0f);
	if(aiReturn_SUCCESS == aiGetMaterialColor(mtl, AI_MATKEY_COLOR_EMISSIVE, 0, 0, &emission))
            color4_to_float4(&emission, c);
	glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, cast(const(float)*)c);

	max = 1;
	ret1 = aiGetMaterialFloatArray(mtl, AI_MATKEY_SHININESS, 0, 0, &shininess, &max);
	if(ret1 == aiReturn_SUCCESS) {
    	    max = 1;
    	    ret2 = aiGetMaterialFloatArray(mtl, AI_MATKEY_SHININESS_STRENGTH, 0, 0, &strength, &max);
            if(ret2 == aiReturn_SUCCESS)
                glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, shininess * strength);
            else
                glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, shininess);
        }
        else {
            glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, 0.0f);
            set_float4(c, 0.0f, 0.0f, 0.0f, 0.0f);
            glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, cast(const(float)*)c);
	}

	max = 1;
	if(aiReturn_SUCCESS == aiGetMaterialIntegerArray(mtl, AI_MATKEY_ENABLE_WIREFRAM, 0, 0, &wireframe, &max))
		fill_mode = wireframe ? GL_LINE : GL_FILL;
	else
		fill_mode = GL_FILL;
	glPolygonMode(GL_FRONT_AND_BACK, fill_mode);

	max = 1;
	if((aiReturn_SUCCESS == aiGetMaterialIntegerArray(mtl, AI_MATKEY_TWOSIDED, 0, 0, &two_sided, &max)) && two_sided)
		glDisable(GL_CULL_FACE);
	else
		glEnable(GL_CULL_FACE);

        

    aiString path;
    bool normals = false;
    if(aiReturn_SUCCESS == aiGetMaterialTexture(mtl, aiTextureType_DIFFUSE, 0, &path))
    {
        string tex_name = (cast(const(char)*)(path.data)).to!(string)();
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

GLuint[const (aiMesh)*] gl_lists;

/* ---------------------------------------------------------------------------- */
void recursive_render (GlobalState gs, const (aiScene) *sc,
    bool delegate(GlobalState gs, string name) anim = null,
    string delegate(GlobalState gs, string name) tex_anim = null,
    bool dontcache = false,
    const (aiNode)* nd = null)
{
    if (!nd) nd = sc.mRootNode;
    uint i;
    int n = 0, t;
    GLuint prev_tex_id_idx = 0;
    
    glPushMatrix();

    bool draw = true;
    string name = (cast(const(char)*)(nd.mName.data)).to!(string)();
    if (anim) draw = anim(gs, name);

    if (draw)
    {
        /* draw all meshes assigned to this node */
        for (; n < nd.mNumMeshes; n++) {
            const (aiMesh)* mesh = sc.mMeshes[nd.mMeshes[n]];

            //writefln("mesh %d. material %d", n, mesh.mMaterialIndex);
            bool is_texture = apply_material(gs, sc.mMaterials[mesh.mMaterialIndex], tex_anim);
    
            if(mesh.mNormals is null) {
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
                for (t = 0; t < mesh.mNumFaces; t++) {
                    const (aiFace)* face = &mesh.mFaces[t];
                    GLenum face_mode;
        
                    switch(face.mNumIndices) {
                        case 1: face_mode = GL_POINTS; break;
                        case 2: face_mode = GL_LINES; break;
                        case 3: face_mode = GL_TRIANGLES; break;
                        default: face_mode = GL_POLYGON; break;
                    }
        
                    glBegin(face_mode);
        
                    for(i = 0; i < face.mNumIndices; i++) {
                        int index = face.mIndices[i];
                        if(mesh.mColors[0] !is null)
                                glColor4fv(cast(GLfloat*)&mesh.mColors[0][index]);
            
                        /*if (t < 5)
                            glColor4fv([0.0f,1.0f,0.0f,1.0f].ptr);
                        else
                            glColor4fv([0.0f,0.0f,0.0f,1.0f].ptr);*/
        
                        if (is_texture && mesh.mTextureCoords[0] !is null)
                            glTexCoord2f(mesh.mTextureCoords[0][index].x, 1.0-mesh.mTextureCoords[0][index].y);
        
                        if(mesh.mNormals !is null)
                        {
                            float[3] normal = [mesh.mNormals[index].x, -mesh.mNormals[index].y, -mesh.mNormals[index].z];
                            glNormal3fv(normal.ptr);
                        }
            
                        float[3] coords = [-mesh.mVertices[index].x, mesh.mVertices[index].y, mesh.mVertices[index].z];
                        glVertex3fv(coords.ptr);
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
    
    /* draw all children */
    for (n = nd.mNumChildren-1; n >= 0; n--) {
        recursive_render(gs, sc, anim, tex_anim, dontcache, nd.mChildren[n]);
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


