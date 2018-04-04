module unde.games.dizzy.omega.save_load;

import std.algorithm;
import std.file;
import std.process;
import std.stdio;

string[string] load()
{
    string[string] s;
    version (Windows)
    {
        string home = environment["APPDATA"];
    }
    else
    {
        string home = environment["HOME"];
    }

    try
    {
        auto f = File(home ~ "/.dizzy_omega/save", "r");
        foreach (line; f.byLine())
        {
            auto eq = find(line, "=");
            if (eq)
            {
                string key = line[0..eq.ptr - line.ptr].idup();
                string str = eq[1..$].idup();
                s[key] = str;
            }
        }
        f.close();
    }
    catch (Exception e)
    {
    }
    return s;
}

void save(ref string[string] s)
{
    version (Windows)
    {
        string home = environment["APPDATA"];
    }
    else
    {
        string home = environment["HOME"];
    }
    mkdirRecurse(home ~ "/.dizzy_omega/");
    
    auto f = File(home ~ "/.dizzy_omega/save", "w");
    foreach(key, str; s)
    {
        f.writef("%s=%s\n", key, str);
    }
    f.close();
}
