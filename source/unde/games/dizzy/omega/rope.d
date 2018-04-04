module unde.games.dizzy.omega.rope;

import derelict.assimp3.assimp;
import derelict.opengl3.gl;

import std.algorithm;
import std.conv;
import std.math;
import std.stdio;
import unde.games.object;
import unde.games.renderer;
import unde.games.collision_detector;
import unde.games.object;
import unde.global_state;

class Rope:StaticGameObject
{
    float by, segl;
    float[3][] rope;

    static int num;
    static GLuint rope_texture;
    int number;
    int static_segments;

    int cut_segm = -1;
    
    this(MainGameObject root, float[3] rope_start, float[3] rope_end, float by, uint length, float segl,
         int static_segments = 1)
    {
        x = rope_end[0];
        y = rope_end[1];
        z = rope_end[2];
        
        this.by = by;
        this.segl = segl;
        if (length > 1)
        {
            float rx = rope_start[0];
            float ry = rope_start[1];
            float rz = rope_start[2];
            if (static_segments == 1)
            {
                foreach (i; 0..length)
                {
                    rope ~= [rx + (x-rx)*i/(length-1),
                             ry + (y-ry)*i/(length-1),
                             rz + (z-rz)*i/(length-1)];
                }
            }
            else
            {
                foreach (i; 0..static_segments)
                {
                    rope ~= [rx + (x-rx)*i/(static_segments-1),
                             ry + (y-ry)*i/(static_segments-1),
                             rz + (z-rz)*i/(static_segments-1)];
                }
                
                foreach (i; static_segments..length)
                {
                    rope ~= [x, y, z];
                }
                
                cut_segm = length - 1;
            }
        }

        this.static_segments = static_segments;

        if (num == 0)
        {
            rope_texture = load_texture("models/dizzy/rope.png");
        }
        number = num++;
        
        super(root);
    }

    void reinit()
    {
        if (rope.length > 1)
        {
            float rx = rope[0][0];
            float ry = rope[0][1];
            float rz = rope[0][2];
            
            if (static_segments == 1)
            {
                foreach (i; 0..rope.length)
                {
                    rope[i] = [rx + (x-rx)*i/(rope.length-1),
                             ry + (y-ry)*i/(rope.length-1),
                             rz + (z-rz)*i/(rope.length-1)];
                }
            }
            else
            {
                foreach (i; 0..static_segments)
                {
                    rope [i] = [rx + (x-rx)*i/(static_segments-1),
                             ry + (y-ry)*i/(static_segments-1),
                             rz + (z-rz)*i/(static_segments-1)];
                }
                
                foreach (i; static_segments..rope.length)
                {
                    rope[i] = [x, y, z];
                }
                
                cut_segm = cast(int) rope.length - 1;
            }
        }
    }

    float length(float[3] v)
    {
        return sqrt(v[0]^^2 + v[1]^^2 + v[2]^^2);
    }
    
    void normalize(ref float[3] v)
    {
        float len = length(v);
        v[] /= len;
    }

    float[3] produce(float[3] v1, float[3] v2)
    {
        return [ v1[2]*v2[1] - v1[1]*v2[2], v1[0]*v2[2] - v1[2]*v2[0], v1[1]*v2[0] - v1[0]*v2[1] ];
    }

    void cut(int segm)
    {
        cut_segm = segm;
    }
    
    override void draw(GlobalState gs)
    {
        draw_part(gs, 0, rope.length - 1);
    }

    void draw_part(GlobalState gs, size_t a, size_t b)
    {
        if (rope.length < 2) return;
        
        glEnable(GL_LIGHTING);
        glDisable(GL_COLOR_MATERIAL);
        glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, [0.8f, 0.8f, 0.8f, 1.0f].ptr);
        glBindTexture(GL_TEXTURE_2D, rope_texture);
        
        foreach(i; a..b)
        {
            if (i == cut_segm) continue;
            
            float[3] rs0 = (i>0 ? rope[i-1] : rope[i]);
            float[3] rs1 = rope[i];
            float[3] rs2 = rope[i+1];
            float[3] rs3 = (i<rope.length-2 ? rope[i+2] : rope[i+1]);

            float[3] rs10 = rs0[] - rs1[];
            float[3] rs12 = rs2[] - rs1[];
            if (length(rs10) < 0.001) rs10[] = -rs12[];
            normalize(rs10);
            normalize(rs12);

            float[3] v10, v11, v12, v13;

            float[3] rs10m12 = rs10[] - rs12[];
            float[3] rs10p12 = rs10[] + rs12[];
            if (length(rs10m12) < 0.001 || length(rs10p12) < 0.001)
            {
                //ax+by+cz = 0
                if (abs(rs12[0]) > 0.01 && abs(rs12[1]) > 0.01 && abs(rs12[2]) > 0.01)
                {
                    v10 = [-rs12[1]/rs12[0], 1.0, 0.0];
                    v11 = [-rs12[2]/rs12[0], 0.0, 1.0];
                    normalize(v10);
                    normalize(v11);
                }
                else if (abs(rs12[0]) > 0.01 && abs(rs12[1]) > 0.01)
                {
                    v10 = [-rs12[1]/rs12[0], 1.0, 0.0];
                    v11 = [0.0, 0.0, 1.0];
                    normalize(v10);
                }
                else if (abs(rs12[0]) > 0.01 && abs(rs12[2]) > 0.01)
                {
                    v10 = [-rs12[2]/rs12[0], 0.0, 1.0];
                    v11 = [0.0, 1.0, 0.0];
                    normalize(v10);
                }
                else if (abs(rs12[1]) > 0.01 && abs(rs12[2]) > 0.01)
                {
                    v10 = [1.0, 0.0, 0.0];
                    v11 = [0.0, 1.0, -rs12[1]/rs12[2]];
                    normalize(v11);
                }
                else if (abs(rs12[0]) > 0.01)
                {
                    v10 = [0.0, 1.0, 0.0];
                    v11 = [0.0, 0.0, 1.0];
                }
                else if (abs(rs12[1]) > 0.01)
                {
                    v10 = [1.0, 0.0, 0.0];
                    v11 = [0.0, 0.0, 1.0];
                }
                else if (abs(rs12[2]) > 0.01)
                {
                    v10 = [0.0, 1.0, 0.0];
                    v11 = [1.0, 0.0, 0.0];
                }
            }
            else
            {
                v10 = rs10p12;
                v11 = produce(rs10, rs12);
                normalize(v10);
                normalize(v11);
            }
            
            v12[] = -v10[];
            v13[] = -v11[];

            float[3] rs21 = rs1[] - rs2[];
            float[3] rs23 = rs3[] - rs2[];
            if (length(rs23) < 0.001) rs23[] = -rs21[];
            normalize(rs21);
            normalize(rs23);

            float[3] v20, v21, v22, v23;

            float[3] rs21m23 = rs21[] - rs23[];
            float[3] rs21p23 = rs21[] + rs23[];
            if (length(rs21m23) < 0.001 || length(rs21p23) < 0.001)
            {
                //ax+by+cz = 0
                if (abs(rs21[0]) > 0.01 && abs(rs21[1]) > 0.01 && abs(rs21[2]) > 0.01)
                {
                    v20 = [-rs21[1]/rs21[0], 1.0, 0.0];
                    v21 = [-rs21[2]/rs21[0], 0.0, 1.0];
                    normalize(v20);
                    normalize(v21);
                }
                else if (abs(rs21[0]) > 0.01 && abs(rs21[1]) > 0.01)
                {
                    v20 = [-rs21[1]/rs21[0], 1.0, 0.0];
                    v21 = [0.0, 0.0, 1.0];
                    normalize(v20);
                }
                else if (abs(rs21[0]) > 0.01 && abs(rs21[2]) > 0.01)
                {
                    v20 = [-rs21[2]/rs21[0], 0.0, 1.0];
                    v21 = [0.0, 1.0, 0.0];
                    normalize(v20);
                }
                else if (abs(rs21[1]) > 0.01 && abs(rs21[2]) > 0.01)
                {
                    v20 = [1.0, 0.0, 0.0];
                    v21 = [0.0, 1.0, -rs21[1]/rs21[2]];
                    normalize(v21);
                }
                else if (abs(rs21[0]) > 0.01)
                {
                    v20 = [0.0, 1.0, 0.0];
                    v21 = [0.0, 0.0, 1.0];
                }
                else if (abs(rs21[1]) > 0.01)
                {
                    v20 = [1.0, 0.0, 0.0];
                    v21 = [0.0, 0.0, 1.0];
                }
                else if (abs(rs21[2]) > 0.01)
                {
                    v20 = [0.0, 1.0, 0.0];
                    v21 = [1.0, 0.0, 0.0];
                }
            }
            else
            {
                v20 = rs21p23;
                v21 = produce(rs21, rs23);
                normalize(v20);
                normalize(v21);
            }
            
            v22[] = -v20[];
            v23[] = -v21[];

            v10[] /= 8;
            v11[] /= 8;
            v12[] /= 8;
            v13[] /= 8;
            v20[] /= 8;
            v21[] /= 8;
            v22[] /= 8;
            v23[] /= 8;

            float[3] r10 = v10[] + rs1[];
            float[3] r11 = v11[] + rs1[];
            float[3] r12 = v12[] + rs1[];
            float[3] r13 = v13[] + rs1[];

            float[3] r20 = v20[] + rs2[];
            float[3] r21 = v21[] + rs2[];
            float[3] r22 = v22[] + rs2[];
            float[3] r23 = v23[] + rs2[];

            float tx1 = 1.0*i/(rope.length-1);
            float tx2 = 1.0*(i+1)/(rope.length-1);

            glBegin(GL_POLYGON);
            glTexCoord2f(tx1, 0.0);
            glNormal3fv(v10.ptr);
            glVertex3fv(r10.ptr);

            glTexCoord2f(tx2, 0.0);
            glNormal3fv(v20.ptr);
            glVertex3fv(r20.ptr);

            glTexCoord2f(tx2, 0.25);
            glNormal3fv(v21.ptr);
            glVertex3fv(r21.ptr);

            glTexCoord2f(tx1, 0.25);
            glNormal3fv(v11.ptr);
            glVertex3fv(r11.ptr);
            glEnd();

            glBegin(GL_POLYGON);
            glTexCoord2f(tx1, 0.25);
            glNormal3fv(v11.ptr);
            glVertex3fv(r11.ptr);

            glTexCoord2f(tx2, 0.25);
            glNormal3fv(v21.ptr);
            glVertex3fv(r21.ptr);

            glTexCoord2f(tx2, 0.50);
            glNormal3fv(v22.ptr);
            glVertex3fv(r22.ptr);

            glTexCoord2f(tx1, 0.50);
            glNormal3fv(v12.ptr);
            glVertex3fv(r12.ptr);
            glEnd();

            glBegin(GL_POLYGON);
            glTexCoord2f(tx1, 0.50);
            glNormal3fv(v12.ptr);
            glVertex3fv(r12.ptr);

            glTexCoord2f(tx2, 0.50);
            glNormal3fv(v22.ptr);
            glVertex3fv(r22.ptr);

            glTexCoord2f(tx2, 0.75);
            glNormal3fv(v23.ptr);
            glVertex3fv(r23.ptr);

            glTexCoord2f(tx1, 0.75);
            glNormal3fv(v13.ptr);
            glVertex3fv(r13.ptr);
            glEnd();

            glBegin(GL_POLYGON);
            glTexCoord2f(tx1, 0.75);
            glNormal3fv(v13.ptr);
            glVertex3fv(r13.ptr);

            glTexCoord2f(tx2, 0.75);
            glNormal3fv(v23.ptr);
            glVertex3fv(r23.ptr);

            glTexCoord2f(tx2, 1.00);
            glNormal3fv(v20.ptr);
            glVertex3fv(r20.ptr);

            glTexCoord2f(tx1, 1.00);
            glNormal3fv(v10.ptr);
            glVertex3fv(r10.ptr);
            glEnd();
        }
    }

    override bool tick(GlobalState gs)
    {
        if (rope.length > 1)
        {
            for (size_t i = rope.length-2; i >= static_segments; i--)
            {
                float[3] r1 = rope[i+1];
                float[3] r2 = rope[i];
                float[3] r3 = rope[i-1];

                if (i == cut_segm)
                    r1 = rope[i];
                else if (i+1 == cut_segm)
                    r3 = rope[i];

                bool moved;
                float[3] l12 = r1[] - r2[];
                float[3] l23 = r3[] - r2[];

                if (length(l12) > segl || length(l23) > segl)
                {
                    if (cut_segm >= 0)
                    {
                        float[3] l13 = r1[] - r3[];
                        float len = length(l13);

                        if (i <= cut_segm)
                        {
                            if (r1[1] < r3[1])
                            {
                                rope[i][] = r1[]*segl/len + r3[]*(len-segl)/len;
                                moved = true;
                            }
                        }
                        else
                        {
                            if (r3[1] < r1[1])
                            {
                                rope[i][] = r1[]*(len-segl)/len + r3[]*segl/len;
                                moved = true;
                            }
                        }
                    }
                    else
                    {
                        rope[i][] = (r1[] + r3[])/2;
                        moved = true;
                    }    
                }

                if (!moved && rope[i][1] > by)
                {
                    rope[i][1] -= 0.1;
                    
                    r2 = rope[i];
                    l12[] = r1[] - r2[];
                    l23[] = r3[] - r2[];

                    if (cut_segm < 0)
                    {
                        if (length(l12) > segl || length(l23) > segl)
                        {
                            float dy;
                            
                            if ( length(l12) > length(l23) )
                                dy = sqrt(segl^^2 - l12[0]^^2 - l12[2]^^2) - l12[1];
                            else
                                dy = sqrt(segl^^2 - l23[0]^^2 - l23[2]^^2) - l23[1];
    
                            rope[i][1] -= dy;
                        }
                    }
                    else
                    {
                        if (i <= cut_segm)
                        {
                            if (length(l23) > segl)
                                rope[i][1] -= sqrt(segl^^2 - l23[0]^^2 - l23[2]^^2) - l23[1];
                        }
                        else
                        {
                            if (length(l12) > segl)
                                rope[i][1] -= sqrt(segl^^2 - l12[0]^^2 - l12[2]^^2) - l12[1];
                        }
                    }
                }
            }
        }

        return true;
    }    

    override void load(string[string] s)
    {
        string p = "rope"~number.to!(string);
        if (p~"-cut" in s)
            cut_segm = s[p~"-cut"].to!(int);
        else
            cut_segm = -1;
            
        foreach(i; 0..10)
        {
            tick(null);
        }
    }

    override void save(ref string[string] s)
    {
        string p = "rope"~number.to!(string);
        if (cut_segm >= 0)
            s[p~"-cut"] = cut_segm.to!(string);
    }    
}

