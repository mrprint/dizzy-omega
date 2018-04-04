module unde.lib;

import derelict.sdl2.sdl;
import std.container.dlist;
import std.stdio;
import std.format;
import std.string;
import std.process;
import std.regex;
import std.conv;
import std.utf;
import core.exception;

import derelict.sdl2.sdl;

import unde.global_state;
import unde.slash;

import core.sys.posix.sys.stat;
import core.sys.posix.pwd;
import core.sys.posix.grp;

version(Windows)
{
import core.stdc.time;
alias ulong ulong_t;
}

enum DOUBLE_DELAY=750;

enum PATH_MAX=4096; //from linux/limits.h
enum UUID_MAX=36;
enum MARKS_PATH_MAX=PATH_MAX+UUID_MAX;

char[i] to_char_array(int i)(string str)
{
    char[i] ret;
    size_t l = str.length;
    if (l > i) l = i;
    ret[0..l] = str[0..l];
    return ret;
}

char[i] to_char_array_z(int i)(string str)
{
    char[i] ret;
    size_t l = str.length;
    if (l > i) l = i;
    ret[0..l] = str[0..l];
    ret[l..$] = '\0';
    return ret;
}

string from_char_array(const char[] str)
{
    int i;
    foreach (c; str)
    {
        if (c == char.init) break;
        i++;
    }
    return str[0..i].idup();
}

wstring from_char_array(const wchar[] str)
{
    int i;
    foreach (c; str)
    {
        if (c == wchar.init) break;
        i++;
    }
    return str[0..i].idup();
}

string strip_error(string str)
{
    return str[str.indexOf(":")+2..$];
}

size_t
mystride(T)(ref T str, size_t pos, size_t len = 0)
{
    /* stride falls with OutOfMemoryError Sometimes
       on not correct symbols, so we will use our stride */

    if ((str[pos] & 0b1000_0000) == 0)
        return 1;

    if (len == 0) len = str.length;

    size_t i;
    for (i=pos+1; i < len && (str[i] & 0b1100_0000) == 0b1000_0000; i++)
    {
    }
    return i-pos;
}

size_t
mystrideBack(T)(ref T str, size_t pos)
{
    try
    {
        return str.strideBack(pos);
    }
    catch (UnicodeException e)
    {
    }
    catch (UTFException e)
    {
    }
    catch (OutOfMemoryError e)
    {
    }
    return 1;
}

size_t
myWalkLength(char[] str)
{
    size_t n = 0;
    for (size_t i = 0; i < str.length; i+=mystride(str, i))
        n++;
    return n;
}

