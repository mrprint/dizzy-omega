module unde.games.dizzy.omega.dialogs;

import derelict.opengl3.gl;
import unde.games.dizzy.omega.main;
import unde.games.object;
import unde.games.renderer;
import unde.global_state;

class Dialogs:StaticGameObject
{
    bool inventory;
    string model;
    float[4][] colors;
    int color;

    this(MainGameObject root)
    {
        colors =
        [
            [0.0, 0.0, 1.0, 1.0],
            [1.0, 0.0, 0.0, 1.0],
            [1.0, 0.0, 1.0, 1.0],
            [0.0, 1.0, 0.0, 1.0],
            [0.0, 1.0, 1.0, 1.0],
            [1.0, 1.0, 0.0, 1.0],
            [1.0, 1.0, 1.0, 1.0]
        ];
        
        super(root);
    }
    
    enum DIALOG_COLOR
    {
        BLUE = 0,
        GREEN = 1,
        RED = 2,
        WHITE = 3,
    }

    void show_dialback(int x1, int y1, int x2=-100, int y2=-100,
        DIALOG_COLOR color = DIALOG_COLOR.BLUE)
    {
        if (x2 == -100) x2 = x1;
        if (y2 == -100) y2 = y1;
        
        glBindTexture(GL_TEXTURE_2D, 0);
        glBegin(GL_POLYGON);
        final switch (color)
        {
            case DIALOG_COLOR.BLUE:
                glColor4f(0.0, 0.0, 0.5, 0.8);
                break;
            case DIALOG_COLOR.GREEN:
                glColor4f(0.0, 0.15, 0.0, 0.8);
                break;
            case DIALOG_COLOR.RED:
                glColor4f(0.15, 0.0, 0.0, 0.8);
                break;
            case DIALOG_COLOR.WHITE:
                glColor4f(0.15, 0.15, 0.15, 0.8);
                break;            
        }
        glVertex3f(-x1, -y2, -9.9);
        glVertex3f( x2, -y2, -9.9);
        glVertex3f( x2, y1, -9.9);
        glVertex3f(-x1, y1, -9.9);
        glEnd();
    }

    override void draw(GlobalState gs)
    {
        auto dz = cast(DizzyOmega) root;
        auto lang = dz.lang;
        
        final switch (dz.state)
        {
            case STATE.NO_DIALOGS:
                break;

            case STATE.HELP:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(21, 10);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-20.0, 9.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        print_text("           Help about keys\n"~
                                   "\n"~
                                   "          ESCAPE - this help\n"~
                                   "\n"~
                                   "           Up                K\n"~
                                   "    Left  Down  Right  OR  Z M X\n"~
                                   "\n"~
                                   "              SPACE - Jump\n"~
                                   "         ENTER - Take, Use item\n"~
                                   "              Ctrl+S - Save\n"~
                                   "              Ctrl+L - Load\n"~
                                   "              Ctrl+R - Restart\n"~
                                   "             U - On/Off Music\n"~
                                   "             O - On/Off Sounds\n"~
                                   "\n"~
                                   "             1 - Change suit\n"~
                                   "             2 - Change language\n"~
                                   "               Q - Exit");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(21, 10);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-20.0, 9.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        print_text("           Справка по клавишам\n"~
                                   "\n"~
                                   "           ESCAPE - эта справка\n"~
                                   "\n"~
                                   "           Вверх                K\n"~
                                   "    Влево  Вниз  Вправо  ИЛИ  Z M X\n"~
                                   "\n"~
                                   "             Пробел - прыжок\n"~
                                   "ENTER - Подобрать, Использовать предмет\n"~
                                   "             Ctrl+S - Сохранить\n"~
                                   "             Ctrl+L - Загрузить\n"~
                                   "             Ctrl+R - Сначала\n"~
                                   "            U - Вкл/Выкл Музыку\n"~
                                   "            O - Вкл/Выкл Звуки\n"~
                                   "\n"~
                                   "             1 - Сменить костюм\n"~
                                   "             2 - Сменить язык\n"~
                                   "               Q - Выход");
                        break;
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.INVENTORY:

                glEnable(GL_COLOR_MATERIAL);

                show_dialback(15, 8);

                glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                glTranslatef(-5.0, 7.0, 0.0);
                glColor4f(1.0, 1.0, 0.0, 1.0);
                final switch(lang)
                {
                    case dz.LANG.EN:
                        print_text("Inventory");
                        break;
                    case dz.LANG.RU:
                        print_text("Инвентарий");
                        break;
                }

                glTranslatef(-6.0, 0.0, 0.0);

                foreach(i, inv; dz.inventory)
                {
                    glDisable(GL_COLOR_MATERIAL);
                    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                    glTranslatef(0.0, -2.5, -15.0);
                    recursive_render(gs, dz.models[dz.items[inv].model]);
                    glTranslatef(1.0, 0.5, 15.0);

                    glDisable(GL_LIGHTING);
                    glEnable(GL_COLOR_MATERIAL);
                    glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                    glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                    if (dz.inv_num == i)
                        glColor4fv(colors[(color/16)%7].ptr);
                    else
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                    final switch(lang)
                    {
                        case dz.LANG.EN:
                            print_text(dz.names[dz.items[inv].model]);
                            break;
                        case dz.LANG.RU:
                            print_text(dz.names_ru[dz.items[inv].model]);
                            break;
                    }
                    glTranslatef(-1.0, 0.0, 0.0);
                }

                if (dz.inv_num == -1)
                    glColor4fv(colors[(color/16)%7].ptr);
                else
                    glColor4f(1.0, 1.0, 1.0, 1.0);

                glTranslatef(0.0, -2.0, 0.0);
                final switch(lang)
                {
                    case dz.LANG.EN:
                        print_text("Nothing to drop");
                        break;
                    case dz.LANG.RU:
                        print_text("Ничего не бросать");
                        break;
                }

                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;
            
            case STATE.ENERGY_STAR:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(6, 4);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-5.0, 3.0, 0.0);
                        glColor4f(1.0, 1.0, 0.0, 1.0);
                        print_text("Well Done!");
        
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        glTranslatef(0.0, -2.0, 0.0);
                        print_text("You found\n"~
                                   "an energy\n"~
                                   "  star!");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(8, 4);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-7.0, 3.0, 0.0);
                        glColor4f(1.0, 1.0, 0.0, 1.0);
                        print_text("   Отлично!");
        
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        glTranslatef(0.0, -2.0, 0.0);
                        print_text("  Вы нашли\n"~
                                   "энергетическую\n"~
                                   "  звёздочку!");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.TOO_MANY_ITEMS:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(5, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-4.0, 1.0, 0.0);
                        glColor4f(1.0, 0.0, 0.0, 1.0);
                        print_text("Too many\n"~
                                   "  items");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(8, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-7.0, 1.0, 0.0);
                        glColor4f(1.0, 0.0, 0.0, 1.0);
                        print_text("Слишком много\n"~
                                   "  предметов");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.PIERCED_BY_STALAGMITE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(9, 3);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-8.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        print_text("You was pirced\n"~
                                   " by stalagmite");

                        glTranslatef(0.0, -3.0, 0.0);
                        glColor4f(1.0, 0.0, 0.0, 1.0);
                        print_text("You lose a life");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(9, 3);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-8.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        print_text(" Вы проткнуты\n"~
                                   " сталагмитом");

                        glTranslatef(0.0, -3.0, 0.0);
                        glColor4f(1.0, 0.0, 0.0, 1.0);
                        print_text("Вы теряете жизнь");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.PIERCED_BY_STALACTITE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(9, 3);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-8.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        print_text("You was pierced\n"~
                                   " by stalactite");

                        glTranslatef(0.0, -3.0, 0.0);
                        glColor4f(1.0, 0.0, 0.0, 1.0);
                        print_text("You lose a life");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(9, 3);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-8.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        print_text(" Вы проткнуты\n"~
                                   " сталактитом");

                        glTranslatef(0.0, -3.0, 0.0);
                        glColor4f(1.0, 0.0, 0.0, 1.0);
                        print_text("Вы теряете жизнь");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;
                
            case STATE.HIT_BY_METEORITE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(9, 3);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-8.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        print_text(" You were hit\n"~
                                   " by meteorite");

                        glTranslatef(0.0, -3.0, 0.0);
                        glColor4f(1.0, 0.0, 0.0, 1.0);
                        print_text("You lose a life");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(9, 3);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-8.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        print_text(" Вас прибило\n"~
                                   "  метеоритом");

                        glTranslatef(0.0, -3.0, 0.0);
                        glColor4f(1.0, 0.0, 0.0, 1.0);
                        print_text("Вы теряете жизнь");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.DISSOLVED_IN_ACID:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(9, 3);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-8.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        print_text(" You dissolved\n"~
                                   "    in acid");

                        glTranslatef(0.0, -3.0, 0.0);
                        glColor4f(1.0, 0.0, 0.0, 1.0);
                        print_text("You lose a life");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(9, 3);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-8.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        print_text("Вы растворились\n"~
                                   "  в кислоте");

                        glTranslatef(0.0, -3.0, 0.0);
                        glColor4f(1.0, 0.0, 0.0, 1.0);
                        print_text("Вы теряете жизнь");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.BURNED_IN_LAVA:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(10, 3);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-9.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        print_text("You burned in lava");

                        glTranslatef(0.0, -3.0, 0.0);
                        glColor4f(1.0, 0.0, 0.0, 1.0);
                        print_text(" You lose a life");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(10, 3);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-9.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        print_text("Вы сгорели в лаве");

                        glTranslatef(0.0, -3.0, 0.0);
                        glColor4f(1.0, 0.0, 0.0, 1.0);
                        print_text("Вы теряете жизнь");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;
                
            case STATE.DAMAGED_BY_PIN:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(10, 3);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-9.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        print_text("Your suit damaged\n"~
                                   "     by pin");

                        glTranslatef(0.0, -3.0, 0.0);
                        glColor4f(1.0, 0.0, 0.0, 1.0);
                        print_text(" You lose a life");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(12, 3);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-11.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        print_text("Ваш скафандр повреждён\n"~
                                   "       кнопкой");

                        glTranslatef(0.0, -3.0, 0.0);
                        glColor4f(1.0, 0.0, 0.0, 1.0);
                        print_text("  Вы теряете жизнь");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;
                
            case STATE.HIT_BY_ROCK:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(9, 3);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-8.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        print_text(" You were hit\n"~
                                   "    by rock");

                        glTranslatef(0.0, -3.0, 0.0);
                        glColor4f(1.0, 0.0, 0.0, 1.0);
                        print_text("You lose a life");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(9, 3);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-8.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        print_text(" Вас прибило\n"~
                                   "    скалой");

                        glTranslatef(0.0, -3.0, 0.0);
                        glColor4f(1.0, 0.0, 0.0, 1.0);
                        print_text("Вы теряете жизнь");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.BURNED_IN_FLAME:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(11, 3);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-10.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        print_text("You burned in flame");

                        glTranslatef(0.0, -3.0, 0.0);
                        glColor4f(1.0, 0.0, 0.0, 1.0);
                        print_text("  You lose a life");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(11, 3);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-10.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        print_text("Вы сгорели в пламени");

                        glTranslatef(0.0, -3.0, 0.0);
                        glColor4f(1.0, 0.0, 0.0, 1.0);
                        print_text("  Вы теряете жизнь");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;
                
            case STATE.CRUSHED_BY_PRESSURE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(13, 3);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-12.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        print_text("You crushed by pressure");

                        glTranslatef(0.0, -3.0, 0.0);
                        glColor4f(1.0, 0.0, 0.0, 1.0);
                        print_text("    You lose a life");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(13, 3);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-12.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        print_text("Вас раздавило давлением");

                        glTranslatef(0.0, -3.0, 0.0);
                        glColor4f(1.0, 0.0, 0.0, 1.0);
                        print_text("    Вы теряете жизнь");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;


            case STATE.MARTIAN_AGRONOMIST_HELLO:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(21, 2, 2, 1, DIALOG_COLOR.RED);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-20.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Hi from Earth. I'm...");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(21, 2, 1, 1, DIALOG_COLOR.RED);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-20.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Привет с Земли! Я...\n");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.MARTIAN_AGRONOMIST_HELLO1:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(3, 2, 21, 2, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-2.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Hi, Dizzy. I have seen\n"~
                                   "     your rocket");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(7, 2, 21, 2, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-6.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Привет, Диззи! Да, я видел\n"~
                                   "      твою ракету.");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

           case STATE.MARTIAN_AGRONOMIST_HELLO2:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(21, 2, 9, 1, DIALOG_COLOR.RED);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-20.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Where from you know my name?");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(21, 2, 6, 1, DIALOG_COLOR.RED);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-20.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Откуда ты знаешь моё имя?\n");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.MARTIAN_AGRONOMIST_HELLO3:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(12, 1, 21, 6, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-11.0, 0.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("You are not the first earthman.\n"~
                                   "  Before you here was added\n"~
                                   "    the evil wizard Zaks.\n"~
                                   "He captured the planet, makes\n"~
                                   "     us work for himself");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(11, 1, 21, 6, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-10.0, 0.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Ты не первый землянин на нашей\n"~
                                   "планете. До тебя сюда добрался\n"~
                                   "    злой волшебник Закс.\n"~
                                   "Он захватил планету, застав-\n"~
                                   "    ляет работать на себя.");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.MARTIAN_AGRONOMIST_HELLO4:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(13, 1, 21, 7, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-12.0, 0.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("The population of the planet\n"~
                                   "is falling sharply. My dog now\n"~
                                   "is guarding the secret labora-\n"~
                                   "  tory, and my garden is not\n"~
                                   "protected. The poison completely\n"~
                                   "ceased to act on the wreckers.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(9, 1, 21, 8, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-8.0, 0.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Население планеты резко\n"~
                                   "падает. Моя собака теперь\n"~
                                   "охраняет секретную лабора-\n"~
                                   "торию, а мой огород не\n"~
                                   "охраняется. На вредителей\n"~
                                   "совсем перестала действовать\n"~
                                   "отрава.");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.MARTIAN_AGRONOMIST_HELLO5:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(21, 7, 13, 1, DIALOG_COLOR.RED);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-20.0, 6.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Wow. On our planet he was not\n"~
                                   "so rampant. I will rid your\n"~
                                   "planet of Zaks, It is not the\n"~
                                   "first time for me. But I need\n"~
                                   "in your help. Any adaptions will\n"~
                                   "useful.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(21, 8, 10, 1, DIALOG_COLOR.RED);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-20.0, 7.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Надо же. На нашей планете он\n"~
                                   "    так не свирепствовал.\n"~
                                   "  Я избавлю вашу планету от\n"~
                                   "Закса, мне не впервой. Но мне\n"~
                                   "   нужна ваша помощь. Мне\n"~
                                   "     пригодятся любые\n"~
                                   "      приспособления.");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.MARTIAN_AGRONOMIST_HELLO6:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(10, 1, 21, 5, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-9.0, 0.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("In the bam you can take the\n"~
                                   "fish-rod and bag. In which \n"~
                                   "you will find insecticide.\n"~
                                   "But it don't act more.\n");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(10, 1, 21, 5, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-9.0, 0.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text(" В сарае, ты можешь взять\n"~
                                   " удочку и сумку. В ней ты\n"~
                                   "найдёшь отраву от насекомых.\n"~
                                   "Но она же уже не действует.");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.LOOKING_BOOTH_MESSAGE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(9, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-8.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("You are looking\n"~
                                   "  to the booth");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(9, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-8.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Вы заглядываете\n"~
                                   "    в будку");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;
            case STATE.LOOKING_BOOTH:
                break;
            case STATE.DIZZY_USED_KNIFE_MESSAGE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(9, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-8.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Dizzy used knife\n"~
                                   "     and...");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(11, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-10.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Диззи воспользовался\n"~
                                   "    ножом, и...");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;
            case STATE.DIZZY_USED_KNIFE_ANIM:
            case STATE.THINGS_SWEEP_AWAY_ZAKS_ANIM:
                break;

            case STATE.DIZZY_THROW_BRANCH_MESSAGE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(12, 2, 12, 1);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-11.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Dizzy throw the branch");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(10, 2, 10, 1);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-9.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Диззи бросил ветку");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;
            case STATE.DIZZY_THROW_BRANCH_ANIM:
                break;

            case STATE.DIZZY_CUTS_ROPE_MESSAGE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(11, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-10.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Dizzy cuts the rope");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(13, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-12.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Диззи перерезал верёвку");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;
            case STATE.DIZZY_CUTS_ROPE_ANIM:
                break;
                
            case STATE.MARTIAN_ENGINEER_GET_AWAY:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(1, 2, 20, 2, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-0.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Get away from here,\n"~
                                   "    uninvited");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(3, 2, 21, 1, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-2.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Прочь отсюда, незванец\n");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;
                
            case STATE.MARTIAN_AGRONOMIST_ROPE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(4, 3, 21, 2, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-3.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Thank you for releasing\n"~
                                   " the dog. You can take\n"~
                                   "       this rope.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(4, 3, 21, 2, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-3.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Спасибо за освобождение\n"~
                                   "собаки. Ты можешь взять\n"~
                                   "      эту верёвку.");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;
                
            case STATE.MARTIAN_ENGINEER_TAKES_PLAYER:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(7, 4, 21, 3, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-6.0, 3.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Is it for me? What is it?\n"~
                                   "Music?.. Wow, good music!\n"~
                                   "I will take it to make for\n"~
                                   "me the same thing. You can\n"~
                                   "pass.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(8, 4, 21, 3, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-7.0, 3.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Это мне? Что это? Музыка?..\n"~
                                   "Слушай, хорошая музыка, я,\n"~
                                   "пожалуй, возьму себе это,\n"~
                                   "спаяю себе такой же. А ты\n"~
                                   "    можешь проходить");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;
                
            case STATE.DIZZY_TIED_ROPE_MESSAGE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(9, 2, 8, 1);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-8.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Dizzy tied rope");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(12, 2, 12, 1);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-11.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Диззи привязал верёвку");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;
                
            case STATE.DIZZY_UNTIED_ROPE_MESSAGE:
            case STATE.DIZZY_UNTIED_SHORT_ROPE_MESSAGE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(10, 2, 9, 1);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-9.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Dizzy untied rope");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(12, 2, 12, 1);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-11.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Диззи отвязал верёвку");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.DIZZY_CATCH_GRASSHOPPER_MESSAGE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(18, 3, 17, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-17.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Having driven a grasshopper into\n"~
                                   "a pit, Dizzy was able to catch it\n"~
                                   "     with his bare hands.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(13, 3, 12, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-12.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Загнав кузнечика в яму,\n"~
                                   "Диззи смог поймать его\n" ~
                                   "   голыми руками");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;


            case STATE.MARTIAN_CHEMIST_HELLO:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(21, 2, 7, 2, DIALOG_COLOR.RED);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-20.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Hello! What you know about\n"~
                                   "       the wizard?");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(21, 2, 10, 2, DIALOG_COLOR.RED);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-20.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Здравcтвуйте! А что вы знаете\n"~
                                   "       о волшебнике?");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.MARTIAN_CHEMIST_HELLO1:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(11, 5, 21, 4, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-10.0, 4.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Hi, Dizzy! Zaks ordered me to\n"~
                                   "    maintain in the castle\n"~
                                   "  the atmosphere of a special\n"~
                                   " composition. These conditions\n"~
                                   "was initially as on Earth, but\n"~
                                   "with each day it more and more\n"~
                                   "        distant from it.\n");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(12, 4, 21, 4, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-11.0, 3.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("  Привет, Диззи! Закс наказал\n"~
                                   "   мне поддерживать в замке\n"~
                                   "атмосферу специального состава.\n"~
                                   " Эти условия изначально земные\n"~
                                   "    с каждым днём всё более\n"~
                                   "       отдаляются от них.");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;
                
            case STATE.MARTIAN_CHEMIST_HELLO2:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(21, 2, 8, 2, DIALOG_COLOR.RED);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-20.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Oh. my God! I hope they are\n"~
                                   "   not held in shackles!");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(21, 2, 6, 2, DIALOG_COLOR.RED);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-20.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("  Боже! Надеюсь они там\n"~
                                   "не содержатся в кандалах!");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.MARTIAN_CHEMIST_HELLO3:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(12, 6, 21, 5, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-11.0, 5.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("No, of course. There they have\n"~
                                   "a very good time. But unfortu-\n"~
                                   "nately, only an engineer knows\n"~
                                   "   how to get into the castle.\n"~
                                   " He designed it. Wait, when he\n"~
                                   "   will free. In addition,\n"~
                                   "  surely the entrance to the\n"~
                                   "castle is guarded by the wizard\n"~
                                   "            himself.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(11, 5, 21, 5, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-10.0, 4.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Нет, что ты? Там они весьма\n"~
                                   " неплохо проводят время. Но\n"~
                                   "  к сожалению как попасть в\n"~
                                   " замок знает только инженер,\n"~
                                   " он его проектировал. Жди,\n"~
                                   "   когда он освободиться.\n"~
                                   "   К тому же вход в замок\n"~
                                   "наверняка охраняет сам колдун.");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.MARTIAN_CHEMIST_HELLO4:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(16, 2, 1, 1, DIALOG_COLOR.RED);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-15.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("So, what to do?");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(15, 2, 1, 1, DIALOG_COLOR.RED);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-14.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Что же делать?");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.MARTIAN_CHEMIST_HELLO5:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(12, 5, 21, 5, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-11.0, 4.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("I have the idea. I need poison\n"~
                                   "  for grasshoppers and bugs.\n"~
                                   "And live representatives of the\n"~
                                   "food chain starting with grass-\n"~
                                   " hoppers and bugs. And take it\n"~
                                   "  easy, I see you are nervous.\n"~
                                   "Here's a drink for you to calm\n"~
                                   "             down.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(14, 5, 21, 4, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-13.0, 4.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30  
                        print_text("   Есть одна идея. Мне нужна\n"~
                                   "  отрава от кузнечиков и жуков.\n"~
                                   " И живые представители пищевой\n"~
                                   "     цепочки начинающейся с\n"~
                                   "    кузнечиков и жуков. А так\n"~
                                   "успокойся, я вижу ты нервничаешь.\n"~
                                   " Вот тебе напиток для успокоения.");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.DIZZY_DRINK_STUNNING_MESSAGE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(14, 2, 14, 1);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-13.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Dizzy drunk stunning drink");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(18, 2, 17, 1);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-17.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30   
                        print_text("Диззи выпил сногсшибающий напиток");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;
                
            case STATE.MARTIAN_AGRONOMIST_GIVES_BUCKET:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(16, 2, 1, 1, DIALOG_COLOR.RED);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-15.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Can I help you?");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(19, 2, 1, 2, DIALOG_COLOR.RED);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-18.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("  Не надо ли вам\n"~
                                   "чем-нибудь помочь?");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.MARTIAN_AGRONOMIST_GIVES_BUCKET1:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(10, 2, 21, 2, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-9.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Yes, water please my flowers.\n"~
                                   "     Here's a bucket");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(13, 2, 21, 2, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-12.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Да полей, пожалуйста, мои цветы.\n"~
                                   "         Вот ведро.");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.DIZZY_TRIES_FILL_BUCKET_MESSAGE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(15, 3, 14, 3);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-14.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("With the rope Dizzy dropped\n"~
                                   "  the bucket into the well,\n"~
                                   "but something prevented it\n"~
                                   " from reaching the water.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(15, 3, 14, 3);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-14.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30   
                        print_text("  При помощи верёвки Диззи\n"~
                                   "  спустил ведро в колодец,\n"~
                                   "но что-то мешало достигнуть\n"~
                                   "            воды");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.DIZZY_THROW_METEORITE_MESSAGE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(16, 3, 16, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-15.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Dizzy threw the meteorite into\n"~
                                   " the well. There was a splash\n"~
                                   "         of water.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(17, 2, 17, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-16.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30   
                        print_text("Диззи бросил метеорит в колодец.\n"~
                                   "    Раздался всплеск воды.");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.DIZZY_FILL_BUCKET_MESSAGE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(16, 3, 15, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-15.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text(" With the rope Dizzy dropped\n"~
                                   "  the bucket into the well,\n"~
                                   "  and filled it with water.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(14, 3, 13, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-13.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30   
                        print_text(" При помощи верёвки Диззи\n"~
                                   "спустил ведро в колодец и\n"~
                                   "    наполнил его водой.");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;
                
            case STATE.DIZZY_TRIES_WATER_FLOWERS_MESSAGE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(17, 2, 16, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-16.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Dizzy tried to water flowers,\n"~
                                   "but water in the bucket frozen.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(16, 2, 15, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-15.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30   
                        print_text("Диззи попытался полить цветы,\n"~
                                   "  но вода в ведре замёрзла");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.DIZZY_COVERED_BUCKET_MESSAGE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(13, 2, 12, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-12.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Dizzy covered bucket of\n"~
                                   "  water with blanket");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(10, 2, 10, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-9.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30   
                        print_text("Диззи накрыл ведро\n"~
                                   "  воды одеялом");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.DIZZY_WATER_FLOWERS_MESSAGE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(14, 2, 14, 1);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-13.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Dizzy watered the flowers.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(10, 2, 10, 1);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-9.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30   
                        print_text("Диззи полил цветы.");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.MARTIAN_AGRONOMIST_THANKS:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(10, 4, 21, 3, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-9.0, 3.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("  Thank you, Dizzy! You can\n"~
                                   "leave the bucket for yourself.\n"~
                                   "Also I want to make new booth\n"~
                                   "for the dog. I need materials\n"~
                                   "          and tools.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(8, 4, 21, 3, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-7.0, 3.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Спасибо, Диззи! Ты можешь\n"~
                                   "   оставить ведро себе.\n"~
                                   "Кстати я хочу сделать новую\n"~
                                   "будку для собаки мне нужны\n"~
                                   " материалы и инструменты.");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.MARTIAN_ENGINEER_RETURNS_PLAYER:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(10, 5, 21, 5, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-9.0, 4.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Again thanks for the player,\n"~
                                   " Dizzy. In my model, I have\n"~
                                   "increased headphones, and I'm\n"~
                                   "    returning your ones.\n"~
                                   "By the way, one impudent bug\n"~
                                   "has stolen my protection from\n"~
                                   " pressure. If you find it,\n"~
                                   "     you can take it.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(12, 4, 21, 4, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-11.0, 3.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Ещё раз спасибо за плеер Диззи.\n"~
                                   "  В своей модели я увеличил\n"~
                                   "  наушники, а твой возвращаю.\n"~
                                   "Кстати один наглый жук стащил\n"~
                                   " мою защиту от давления, если\n"~
                                   "  найдёшь, можешь взять себе.");
                }
                                   
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.MARTIAN_ENGINEER_RETURNS_PLAYER1:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(21, 2, 12, 2, DIALOG_COLOR.RED);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-20.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("What do you know about entrance\n"~
                                   "      to the castle?");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(21, 2, 12, 1, DIALOG_COLOR.RED);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-20.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Что, вы знаете о входе в замок?");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;
                
            case STATE.MARTIAN_ENGINEER_RETURNS_PLAYER2:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(9, 3, 21, 3, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-8.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("The entrance is underground.\n"~
                                   "You need to find the secret\n"~
                                   "pass. I can do the spade for\n"~
                                   " you, But I need a material");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(12, 3, 21, 3, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-11.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("    Вход в замок под землёй.\n"~
                                   "Тебе необходимо найти секретный\n"~
                                   "лаз. Я могу сделать лопату для\n"~
                                   " тебя. Но мне нужны материалы");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.MARTIAN_ENGINEER_TAKES_BUCKET:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(21, 2, 7, 1, DIALOG_COLOR.RED);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-20.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Is this material suitable?");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(21, 2, 5, 1, DIALOG_COLOR.RED);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-20.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Такой материал подойдёт?");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;
                
            case STATE.MARTIAN_ENGINEER_TAKES_BUCKET1:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(15, 4, 21, 3, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-14.0, 3.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("What is it? Ice? Oum! It is ideally!\n"~
                                   "I'll do it, everything will be at\n"~
                                   "its best. And while you take care\n"~
                                   "   of the lighting, it's dark\n"~
                                   "           underground");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(13, 3, 21, 3, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-12.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("  Что это? Лёд? Оум! Идеально!\n"~
                                   "Сделаю, всё будет в лучшем виде.\n"~
                                   "    А ты пока позаботься об\n"~
                                   " освещении - под землёй темно.");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.MARTIAN_ENGINEER_RETURNS_BUCKET:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(14, 3, 21, 3, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-13.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("  Do you need a bucket? Take it,\n"~
                                   " please. And the chemist told me\n"~
                                   "about his idea. Come later to me,\n"~
                                   " I will have something for you.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(9, 4, 21, 3, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-8.0, 3.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("  Тебе нужно ведро? Возьми,\n"~
                                   " пожалуйста. И химик сказал\n"~
                                   " мне про его задумку. Зайди\n"~
                                   "позже ко мне. У меня кое-что\n"~
                                   "      для тебя будет.");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;
                
            case STATE.DIZZY_HOLD_BRANCH_UNDER_DROP:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(17, 3);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-16.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("One, two, three... Dizzy counted\n"~
                                   "the drops falling on the branch.\n"~
                                   " On count 100 branch has begun\n"~
                                   "           to shine.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(18, 3, 17, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-17.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("  Раз, два, три... Диззи считал\n"~
                                   "капли, падающие на ветку. На счёт\n"~
                                   "      100 ветка засияла.");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.DIZZY_OPEN_DOOR:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(20, 3);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-19.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Despite the strange shape of the key,\n"~
                                   "   Dizzy tried to insert it into\n"~
                                   "  the keyhole. The door opened in\n"~
                                   "     an incomprehensible way.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(18, 3, 17, 3);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-17.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Несмотря на странную форму ключа\n"~
                                   " Диззи попробовал вставить её в\n"~
                                   "замочную скважину. Непостижимым\n"~
                                   "   образом дверь отворилась.");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;
                
            case STATE.MARTIAN_ENGINEER_GIVES_SPADE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(12, 3, 21, 3, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-11.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("  Your spade is ready, Dizzy!\n"~
                                   "For ice don't worry, processed\n"~
                                   "so that the heat of 500 degrees\n"~
                                   "      is not terrible.\n");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(13, 3, 21, 3, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-12.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("   Твоя лопата готова, Диззи!\n"~
                                   "За лёд не беспокойся, обработано\n"~
                                   "  так что и жара в 500 градусов\n"~
                                   "           не страшна");
                }
                                   
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.MARTIAN_ENGINEER_GIVES_WHISTLE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(12, 3, 21, 3, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-11.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text(" So, take this whistle, Dizzy.\n"~
                                   " Take everything you can carry\n"~
                                   "with you, and go to the wizard,\n"~
                                   "   find shelter and whistle.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(16, 3, 21, 3, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-15.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text(" Вот, возьми этот свисток, Диззи.\n"~
                                   "Бери с собой всё что можешь унести,\n"~
                                   "  и иди к волшебнику, найди себе\n"~
                                   "         укрытие и свистни.");
                }
                                   
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;


            case STATE.DIZZY_DIG_MESSAGE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(12, 2, 11, 1);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-11.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Dizzy started to dig.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(10, 2, 10, 1);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-9.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Диззи начал копать");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.DIZZY_PUT_STONE_MESSAGE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(9, 2, 9, 1);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-8.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Dizzy put stone.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(13, 2, 12, 1);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-12.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Диззи установил камень.");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.DIZZY_TRY_CATCH_BUG_MESSAGE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(16, 3, 15, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-15.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Dizzy tried to put the nettle\n"~
                                   " on the bug, but it was too\n"~
                                   "          provoked.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(17, 3, 17, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-16.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text(" Диззи попытался накинуть сачок\n"~
                                   "на жука, но тот оказался слишком\n"~
                                   "          проворен.");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.DIZZY_CATCH_BUG_MESSAGE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(20, 2, 20, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-19.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("By some miracle, standing with one leg\n"~
                                   "  on the ice, Dizzy caught the bug.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(18, 2, 18, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-17.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Каким-то чудом, стоя на одной ноге\n"~
                                   "    на льду, Диззи поймал жука.");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.DIZZY_CATCH_FISH_MESSAGE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(18, 3, 17, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-17.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Planting the bug as a bait, Dizzy\n"~
                                   "began to fish. Soon it bite, and\n"~
                                   "    Dizzy took out the fish.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(18, 3, 17, 3);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-17.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Насадив жука на крючок в качестве\n"~
                                   " приманки, Диззи начал удить...\n"~
                                   " Вскоре клюнуло и Диззи достал\n"~
                                   "             рыбу.");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.DIZZY_CATCH_SQUID_MESSAGE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(20, 3, 19, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-19.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("By luring squid promising delicacy in\n"~
                                   "   the form of fish, Dizzy deftly\n"~
                                   "    tied its limbs with the rope.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(17, 3, 17, 3);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-16.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Приманив кальмара многообещающим\n"~
                                   " лакомством в виде рыбки, Диззи\n"~
                                   " ловко перевязал ему конечности\n"~
                                   "           верёвкой.");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.BAG_FOUND:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(12, 3, 11, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-11.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("You have found a bag.\n"~
                                   "  Now you can carry\n"~
                                   "      more items");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(12, 3, 12, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-11.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("    Вы нашли сумку.\n"~
                                   "Теперь вы можете нести\n"~
                                   "   больше предметов");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;
                
            case STATE.DIZZY_DIG2_MESSAGE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(9, 2, 8, 1);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-8.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Dizzy dug a pit");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(9, 2, 8, 1);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-8.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Диззи отрыл яму");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.DIZZY_DIG3_MESSAGE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(12, 11, 8, 1);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-11.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Dizzy dug the shelter");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(14, 2, 14, 1);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-13.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Диззи откопал себе укрытие");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;


            case STATE.DIZZY_TRIES_TO_GET_WATER:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(18, 4, 17, 3);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-17.0, 3.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Dizzy tried to collect water, but\n"~
                                   "  it seeped through the metal.\n"~
                                   "   Also Dizzy noticed that on\n"~
                                   "  the ground the water was kept\n"~
                                   "          a little.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(17, 4, 17, 3);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-16.0, 3.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text(" Диззи попытался набрать воды,\n"~
                                   "однако та просачивалась сквозь\n"~
                                   "металл. Но всё же Диззи заметил,\n"~
                                   "  что на почве вода немного\n"~
                                   "         удерживалась");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;
                
            case STATE.DIZZY_PUT_GROUND_TO_THE_BUCKET:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(17, 2, 16, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-16.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Dizzy tightly packed the bottom\n"~
                                   "of the bucket with dense ground.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(16, 2, 15, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-15.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Диззи плотно уложил дно ведра\n"~
                                   "       рыхлой землёй.");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;
                
            case STATE.DIZZY_GET_LIGHT_WATER:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(15, 2, 15, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-14.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Dizzy took a little water to\n"~
                                   "        the bucket.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(18, 2, 18, 1);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-17.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Диззи набрал немного воды в ведро.");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.DIZZY_SPRAYED_BUG_MESSAGE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(12, 2, 12, 1);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-11.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Dizzy sprayed the bug.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(12, 2, 11, 1);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-11.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Диззи побрызгал жука.");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.DIZZY_SPRAYED_GRASSHOPPER_MESSAGE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(16, 2, 16, 1);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-15.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Dizzy sprayed the grasshopper.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(14, 2, 14, 1);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-13.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Диззи побрызгал кузнечика.");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.NOT_ALL_ITEMS_IN_THE_CASTLE_MESSAGE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(18, 2, 18, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-17.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("\"I have not transferred all things\n"~
                                   "  to the castle,\" thought Dizzy.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(14, 2, 14, 2);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-13.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("\"Я перенёс ещё не все вещи\n"~
                                   "в замок\", - подумал Диззи");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.ROPE_NOT_IN_THE_CASTLE_MESSAGE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(12, 2, 12, 1);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-11.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("\"The last thing left!\"");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(14, 2, 14, 1);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-13.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("\"Осталась последняя вещь!\"");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.DIZZY_WHISTLE_MESSAGE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(11, 2, 11, 1);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-10.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Dizzy whistle and...");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(11, 2, 10, 1);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-10.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Диззи свистнул и...");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.STONES_CRASHES_MESSAGE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(17, 2, 16, 1);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-16.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Above heard the roar of stones.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(18, 2, 17, 1);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-17.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Наверху послышался грохот камней.");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.MARTIAN_CHEMIST_NO_BIRD:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(5, 3, 21, 1, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-4.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Grasshopper is good, but\n"~
                                   "      where bird?");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(6, 3, 21, 1, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-5.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Кузнечик - это хорошо, но\n"~
                                   "       где птица?");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.MARTIAN_CHEMIST_NO_GRASSHOPPER:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(4, 3, 21, 1, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-3.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("The poison is good, but\n"~
                                   "   where grasshopper?");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(4, 3, 21, 1, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-3.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Отрава - это хорошо, но\n"~
                                   "   где сам кузнечик?");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.MARTIAN_CHEMIST_NO_GRASSHOPPERS_POISON:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(6, 3, 21, 1, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-5.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("   Bird is good, but\n"~
                                   "where grasshopper poison?");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(7, 3, 21, 1, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-6.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("  Птица - это хорошо, но\n"~
                                   "где отрава для кузнечиков?");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.MARTIAN_CHEMIST_NO_BUG:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(4, 3, 21, 1, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-3.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("The poison is good, but\n"~
                                   "      where bug?");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(4, 3, 21, 1, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-3.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Отрава - это хорошо, но\n"~
                                   "     где сам жук?");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.MARTIAN_CHEMIST_NO_FISH:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(1, 3, 21, 1, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-0.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("The bug is good, but\n"~
                                   "     where fish?");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(1, 3, 21, 1, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-0.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Жук - это хорошо, но\n"~
                                   "     где рыба?");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;
                
            case STATE.MARTIAN_CHEMIST_NO_SQUID:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(2, 3, 21, 1, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-1.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("The fish is good, but\n"~
                                   "     where squid?");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(2, 3, 21, 1, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-1.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Рыба - это хорошо, но\n"~
                                   "     где кальмар?");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.MARTIAN_CHEMIST_NO_BUGS_POISON:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(3, 3, 21, 1, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-2.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("The squid is good, but\n"~
                                   "   where bug poison?");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(5, 3, 21, 1, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-4.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Кальмар - это хорошо, но\n"~
                                   "  где отрава от жуков?");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.MARTIAN_CHEMIST_THANK_YOU:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(10, 2, 21, 1, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-9.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Thank you, it is that needed.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(8, 2, 21, 1, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-7.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Спасибо, это то, что нужно.");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.MARTIAN_CHEMIST_NEED_WATER_FROM_LIGHT_TREE_CAVE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(16, 2, 21, 3, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-15.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("     Well done. Rest the last\n"~
                                   "    ingridient: bring, please,\n"~
                                   "the water from the light tree cave.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(12, 2, 21, 3, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-11.0, 1.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("  Отлично. Остался последний\n"~
                                   "ингридиент: принеси, пожалуйста\n"~
                                   " воды из пещеры сияющего дерева");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.MARTIAN_CHEMIST_GIVES_PSYCHOTROPIC_SPRAY:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(19, 5, 21, 5, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-18.0, 4.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("  Well? Now we will do so... Done!\n"~
                                   " With this thing it is necessary to\n"~
                                   "sprinkle pests, further instructions\n"~
                                   " you will receive from the engineer.\n"~
                                   "But hurry up! A huge meteorite crashed\n"~
                                   " into the castle and broke the wall.\n"~
                                   "I blocked some of the passages, but\n"~
                                   "      the air continues to leak.");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(10, 6, 21, 6, DIALOG_COLOR.GREEN);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-9.0, 5.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("   Что ж? Сейчас мы немного\n"~
                                   "   поколдуем... Вот готово!\n"~
                                   " Этой штукой надо побрызгать\n"~
                                   "   вредителей, дальнейшие\n"~
                                   "  инструкции ты получишь от\n"~
                                   "инженера. Но поспеши! В замок\n"~
                                   "  врезался огромный метеорит\n"~
                                   " и проломил стену. Я перекрыл\n"~
                                   " некоторые ходы, но воздух\n"~
                                   "     продолжает утекать.");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.ZAKS_SAYS_FAREWELL_WORD:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(11, 3, 21, 2, DIALOG_COLOR.RED);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-10.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("    Oh, you little bastard!\n"~
                                   "OK, I'm leaving. But you never\n"~
                                   " get out of here! Ha ha ha ha.\n");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(11, 3, 21, 2, DIALOG_COLOR.RED);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-10.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("Ах ты гадёныш! Хорошо я ухожу.\n"~
                                   " Но тебе никогда не выбраться\n"~
                                   "    отсюда. Ха-ха-ха-ха!");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.TO_BE_CONTINUED_MESSAGE:
                glEnable(GL_COLOR_MATERIAL);

                final switch(lang)
                {
                    case dz.LANG.EN:
                        show_dialback(14, 3, 14, 3);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-13.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("The next screen not ready.\n"~
                                   "  Please save, and check\n"~
                                   " status of new version on\n"~
                                   " site: dizzy-omega.sf.net");
                        break;
                        
                    case dz.LANG.RU:
                        show_dialback(14, 3, 13, 3);
        
                        glBindTexture(GL_TEXTURE_2D, dz.textures["font"]);
                        glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
                        glTranslatef(-13.0, 2.0, 0.0);
                        glColor4f(1.0, 1.0, 1.0, 1.0);
                        //         0    5   10   15   20   25   30
                        print_text("   Далее игра не готова.\n"~
                                   " Сохранитесь и проверяйте\n"~
                                   "  статус новой версии на\n"~
                                   "сайте: dizzy-omega.sf.net");
                }
                
                glDisable(GL_COLOR_MATERIAL);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                break;

            case STATE.DIZZY_DIG_ANIM:
                break;
        }
    }

    override bool tick(GlobalState gs)
    {
        color++;
        return true;
    }
}

